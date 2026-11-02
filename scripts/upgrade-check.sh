#!/usr/bin/env bash
# Upgrade check for the Docker Compose stack: start an older checkout, put data in it,
# switch to a newer checkout on the same volumes and verify nothing was lost or left unapplied.
# Usage: upgrade-check.sh OLD_DIR NEW_DIR   (two checkouts of this repository)
# Checks after the upgrade: smoke check passes, the Grafana folder created before the upgrade
# is still there, every dashboard file of the new version is provisioned, Grafana logs no
# provisioning errors, Prometheus kept the data that was written before the upgrade.
# The script uses its own Compose project ("upgrade-check") and a throw-away password kept in a
# temporary env file, so it neither reads nor changes the .env of either checkout. It publishes
# the usual ports on 127.0.0.1 (9090, 3001, 9093, 9100, 9115): run it where they are free.
# SMOKE_TIMEOUT and DASHBOARD_TIMEOUT are in seconds.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 OLD_DIR NEW_DIR" >&2
  exit 2
fi

OLD_DIR="$(cd "$1" && pwd)"
NEW_DIR="$(cd "$2" && pwd)"
PROJECT="upgrade-check"
PROMETHEUS_URL="http://127.0.0.1:9090"
ALERTMANAGER_URL="http://127.0.0.1:9093"
GRAFANA_URL="http://127.0.0.1:3001"
DASHBOARD_TIMEOUT="${DASHBOARD_TIMEOUT:-90}"
MARKER="upgrade-check-marker"
PASSWORD="upgrade-check-$(openssl rand -hex 8)"
WORK="$(mktemp -d)"
ENV_FILE="$WORK/env"
failed=0

printf 'GRAFANA_PASSWORD=%s\n' "$PASSWORD" >"$ENV_FILE"

compose() {
  local dir="$1"
  shift
  docker compose -p "$PROJECT" --env-file "$ENV_FILE" -f "$dir/prometheus-grafana/docker-compose.yml" "$@"
}

remove_stack() {
  compose "$NEW_DIR" down -v --remove-orphans >/dev/null 2>&1 ||
    echo "WARN: could not remove the stack; run: docker compose -p ${PROJECT} down -v --remove-orphans" >&2
}

cleanup() {
  local rc=$?
  if ((rc != 0)); then
    # The stack is about to be deleted: keep its state and logs in the job output.
    compose "$NEW_DIR" ps -a >&2 || true
    compose "$NEW_DIR" logs --no-color --tail=50 >&2 || true
  fi
  remove_stack
  rm -rf "$WORK"
}
trap cleanup EXIT

# The address variables are set explicitly: smoke-check.sh would otherwise read the ones exported in the caller's shell.
smoke() {
  PROMETHEUS_URL="$PROMETHEUS_URL" ALERTMANAGER_URL="$ALERTMANAGER_URL" GRAFANA_URL="$GRAFANA_URL" \
    SMOKE_TIMEOUT="${SMOKE_TIMEOUT:-180}" bash "$NEW_DIR/scripts/smoke-check.sh"
}

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "OK: $label"
  else
    echo "FAIL: $label" >&2
    failed=1
  fi
}

# The password goes through a curl config read from a pipe, not through the argument list.
grafana_api() {
  curl -fsS -K <(printf 'user = "admin:%s"\n' "$PASSWORD") "$GRAFANA_URL$1" "${@:2}"
}

tsdb_min_time() {
  curl -fsS "$PROMETHEUS_URL/api/v1/status/tsdb" | jq -e '.data.headStats.minTime'
}

folder_exists() {
  grafana_api /api/folders | jq -e --arg title "$MARKER" 'any(.[]; .title == $title)'
}

dashboards_match() {
  local expected
  expected="$(jq -r '.uid' "$NEW_DIR"/grafana-dashboards/json/*.json | sort)"
  [[ "$(grafana_api '/api/search?type=dash-db' | jq -r '.[].uid' | sort)" == "$expected" ]]
}

echo "Old: $(git -C "$OLD_DIR" describe --tags --always 2>/dev/null || echo "$OLD_DIR")"
echo "New: $(git -C "$NEW_DIR" describe --tags --always 2>/dev/null || echo "$NEW_DIR")"

# A previous run that was killed can leave its stack and volumes behind.
remove_stack

# The services have fixed container names, so a stack on this host (even a stopped one) would collide.
taken="$( (compose "$OLD_DIR" config --format json; compose "$NEW_DIR" config --format json) |
  jq -r '.services[].container_name // empty' | sort -u |
  grep -Fx -f <(docker ps -a --format '{{.Names}}') || true)"
if [[ -n "$taken" ]]; then
  echo "ERROR: containers with the names this stack uses already exist: $(tr '\n' ' ' <<<"$taken")" >&2
  echo "Remove them or run the check on a host without this stack." >&2
  exit 2
fi

compose "$OLD_DIR" up -d
smoke

grafana_api /api/folders -H "Content-Type: application/json" -d "{\"title\":\"${MARKER}\"}" >/dev/null
# Let Prometheus write a few scrapes so there is data to lose.
sleep 45
min_before="$(tsdb_min_time)"
echo "Before the upgrade: Prometheus data starts at ${min_before}"

compose "$NEW_DIR" up -d
smoke
check "Grafana folder created before the upgrade is still there" folder_exists

deadline=$((SECONDS + DASHBOARD_TIMEOUT))
until dashboards_match >/dev/null 2>&1; do
  if ((SECONDS >= deadline)); then
    break
  fi
  sleep 3
done
if dashboards_match >/dev/null 2>&1; then
  echo "OK: every dashboard file of the new version is provisioned"
else
  echo "FAIL: dashboards in Grafana differ from the files of the new version" >&2
  echo "UIDs: < only in the files of the new version, > only in Grafana" >&2
  diff <(jq -r '.uid' "$NEW_DIR"/grafana-dashboards/json/*.json | sort) \
    <(grafana_api '/api/search?type=dash-db' | jq -r '.[].uid' | sort) >&2 || true
  failed=1
fi

# Read the log into a file first: "grep -q" in a pipe can end the writer early (exit 141 under pipefail).
grafana_log="$WORK/grafana.log"
compose "$NEW_DIR" logs --no-color grafana >"$grafana_log" 2>&1 || true
if grep -q "failed to save dashboard" "$grafana_log"; then
  echo "FAIL: Grafana logs dashboard provisioning errors" >&2
  grep "failed to save dashboard" "$grafana_log" | tail -3 >&2
  failed=1
else
  echo "OK: no dashboard provisioning errors in the Grafana log"
fi

min_after="$(tsdb_min_time)"
if ((min_after <= min_before)); then
  echo "OK: Prometheus kept the data written before the upgrade"
else
  echo "FAIL: Prometheus data starts later than before the upgrade (${min_before} -> ${min_after})" >&2
  failed=1
fi

if ((failed)); then
  echo "Upgrade check failed" >&2
  exit 1
fi
echo "Upgrade check passed"
