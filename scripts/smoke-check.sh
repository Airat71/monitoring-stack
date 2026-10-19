#!/usr/bin/env bash
# Smoke check for a running monitoring stack on loopback ports.
# Waits until Prometheus, Alertmanager and Grafana answer, alert rules are loaded
# and every Prometheus scrape target is up. Exit 1 with a reason otherwise.
# Override addresses with PROMETHEUS_URL, ALERTMANAGER_URL, GRAFANA_URL; SMOKE_TIMEOUT is in seconds.

set -euo pipefail

PROMETHEUS_URL="${PROMETHEUS_URL:-http://127.0.0.1:9090}"
ALERTMANAGER_URL="${ALERTMANAGER_URL:-http://127.0.0.1:9093}"
GRAFANA_URL="${GRAFANA_URL:-http://127.0.0.1:3001}"
SMOKE_TIMEOUT="${SMOKE_TIMEOUT:-180}"

deadline=$((SECONDS + SMOKE_TIMEOUT))

wait_until() {
  local label="$1"
  shift
  until "$@" >/dev/null 2>&1; do
    if ((SECONDS >= deadline)); then
      echo "FAIL: $label not ready after ${SMOKE_TIMEOUT}s" >&2
      return 1
    fi
    sleep 3
  done
  echo "OK: $label"
}

rules_loaded() {
  curl -fsS "$PROMETHEUS_URL/api/v1/rules" | jq -e '[.data.groups[].rules[]] | length > 0'
}

targets_up() {
  curl -fsS "$PROMETHEUS_URL/api/v1/targets" |
    jq -e '.data.activeTargets | length > 0 and all(.health == "up")'
}

grafana_ok() {
  curl -fsS "$GRAFANA_URL/api/health" | jq -e '.database == "ok"'
}

wait_until "Prometheus /-/ready" curl -fsS "$PROMETHEUS_URL/-/ready"
wait_until "Alertmanager /-/ready" curl -fsS "$ALERTMANAGER_URL/-/ready"
wait_until "Grafana /api/health" grafana_ok
wait_until "alert rules loaded" rules_loaded

if ! wait_until "all scrape targets up" targets_up; then
  curl -fsS "$PROMETHEUS_URL/api/v1/targets" |
    jq -r '.data.activeTargets[] | select(.health != "up") | "DOWN: \(.scrapePool) \(.scrapeUrl) \(.lastError)"' >&2 || true
  exit 1
fi

echo "Smoke check passed"
