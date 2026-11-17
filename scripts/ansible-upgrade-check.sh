#!/usr/bin/env bash
# Upgrade check for the Ansible deployment: install an older checkout with the playbook, put a
# dashboard made in the Grafana UI into it, run the playbook of a newer checkout over it and verify
# the result. Same idea as upgrade-check.sh, which covers the Docker Compose path.
# Usage: ansible-upgrade-check.sh OLD_DIR NEW_DIR   (two checkouts of this repository)
# Checks after the upgrade: smoke check passes, the UI dashboard is still there, every dashboard
# file of the new version is provisioned and nothing else is left over, Grafana logs no dashboard
# provisioning errors, a second playbook run changes nothing.
# The playbook runs with a local connection and installs into /opt/monitoring with sudo, the stack
# publishes the usual ports on 127.0.0.1 and nothing is removed afterwards: use a throw-away host
# (the CI runner). The script stops if /opt/monitoring already exists.
# DASHBOARD_TIMEOUT is in seconds.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 OLD_DIR NEW_DIR" >&2
  exit 2
fi

OLD_DIR="$(cd "$1" && pwd)"
NEW_DIR="$(cd "$2" && pwd)"
INSTALL_DIR="/opt/monitoring"
GRAFANA_URL="${GRAFANA_URL:-http://127.0.0.1:3001}"
DASHBOARD_TIMEOUT="${DASHBOARD_TIMEOUT:-90}"
UI_DASHBOARD_UID="upgrade-check-ui"
WORK="$(mktemp -d)"
INVENTORY="$WORK/inventory.yml"
failed=0

if [[ -e "$INSTALL_DIR" ]]; then
  echo "ERROR: $INSTALL_DIR already exists. Run this check on a throw-away host." >&2
  exit 2
fi

trap 'rm -rf "$WORK"' EXIT

cat >"$INVENTORY" <<YAML
all:
  children:
    monitoring_server:
      hosts:
        monitor:
          ansible_host: 127.0.0.1
          ansible_connection: local
      vars:
        monitoring_install_dir: ${INSTALL_DIR}
    monitored_nodes:
      hosts: {}
YAML

run_playbook() {
  (cd "$1/ansible" && ansible-playbook -i "$INVENTORY" playbook.yml)
}

smoke() {
  bash "$NEW_DIR/scripts/smoke-check.sh"
}

# The password goes through a curl config read from a pipe, not through the argument list.
grafana_api() {
  local password
  password="$(sudo awk -F= '/^GRAFANA_PASSWORD=/{print substr($0, index($0,"=")+1)}' "$INSTALL_DIR/.env")"
  curl -fsS -K <(printf 'user = "admin:%s"\n' "$password") "$GRAFANA_URL$1" "${@:2}"
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

ui_dashboard_exists() {
  grafana_api "/api/dashboards/uid/${UI_DASHBOARD_UID}" | jq -e '.dashboard.uid'
}

# The dashboard made in the UI is not provisioned and must stay; everything else has to be a file of the new version.
dashboards_match() {
  local expected
  expected="$(jq -r '.uid' "$NEW_DIR"/grafana-dashboards/json/*.json | sort)"
  [[ "$(grafana_api '/api/search?type=dash-db' | jq -r --arg ui "$UI_DASHBOARD_UID" '.[].uid | select(. != $ui)' | sort)" == "$expected" ]]
}

echo "Old: $(git -C "$OLD_DIR" describe --tags --always 2>/dev/null || echo "$OLD_DIR")"
echo "New: $(git -C "$NEW_DIR" describe --tags --always 2>/dev/null || echo "$NEW_DIR")"

run_playbook "$OLD_DIR"
smoke
grafana_api /api/dashboards/db -H "Content-Type: application/json" \
  -d "{\"dashboard\":{\"uid\":\"${UI_DASHBOARD_UID}\",\"title\":\"Created in the UI\",\"panels\":[]},\"overwrite\":true}" >/dev/null

run_playbook "$NEW_DIR"
smoke
check "Dashboard created in the UI before the upgrade is still there" ui_dashboard_exists

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
  echo "UIDs: < only in the files of the new version, > only in Grafana (the UI dashboard is left out)" >&2
  diff <(jq -r '.uid' "$NEW_DIR"/grafana-dashboards/json/*.json | sort) \
    <(grafana_api '/api/search?type=dash-db' | jq -r --arg ui "$UI_DASHBOARD_UID" '.[].uid | select(. != $ui)' | sort) >&2 || true
  failed=1
fi

# Read the log into a file first: "grep -q" in a pipe can end the writer early (exit 141 under pipefail).
grafana_log="$WORK/grafana.log"
(cd "$INSTALL_DIR" && sudo docker compose logs --no-color grafana) >"$grafana_log" 2>&1 || true
if grep -q -E 'logger=provisioning\.dashboard .*level=error' "$grafana_log"; then
  echo "FAIL: Grafana logs dashboard provisioning errors" >&2
  grep -E 'logger=provisioning\.dashboard .*level=error' "$grafana_log" | tail -3 >&2
  failed=1
else
  echo "OK: no dashboard provisioning errors in the Grafana log"
fi

second_run="$WORK/second-run.log"
run_playbook "$NEW_DIR" | tee "$second_run"
if grep -q -E '^monitor +: ok=[0-9]+ +changed=0 +unreachable=0 +failed=0' "$second_run"; then
  echo "OK: a second run of the new playbook changes nothing"
else
  echo "FAIL: a second run of the new playbook changed something" >&2
  failed=1
fi

if ((failed)); then
  echo "Ansible upgrade check failed" >&2
  exit 1
fi
echo "Ansible upgrade check passed"
