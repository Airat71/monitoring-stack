#!/usr/bin/env bash
# Download Grafana dashboards from Grafana.com into grafana-dashboards/json/
# Run from repo root: ./scripts/fetch-dashboards.sh
# Ansible will copy these to the server (grafana/provisioning/dashboards/json).

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/grafana-dashboards/json"
mkdir -p "$OUT_DIR"

# id:revision:output_filename (revision = latest known to work on grafana.com)
DASHBOARDS="
1860:33:node-exporter-full.json
3662:2:prometheus-overview.json
7587:1:blackbox-exporter.json
9628:4:postgresql.json
11835:1:redis.json
10991:3:rabbitmq-overview.json
12708:1:nginx.json
"

for entry in $(echo "$DASHBOARDS" | grep -v '^$'); do
  id="${entry%%:*}"
  rest="${entry#*:}"
  rev="${rest%%:*}"
  out="${rest#*:}"
  url="https://grafana.com/api/dashboards/${id}/revisions/${rev}/download"
  echo "Fetching $id rev $rev -> $out"
  curl -sSL "$url" -o "$OUT_DIR/$out"
done

python3 - "$OUT_DIR" << 'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
replacements = (
    ("${DS_PROMETHEUS-SERVER}", "prometheus"),
    ("${DS_PROMETHEUS}", "prometheus"),
    ("${DS_THEMIS}", "prometheus"),
    ("$DS_PROMETHEUS", "prometheus"),
    ('"uid": "000000001"', '"uid": "prometheus"'),
)
for path in root.glob("*.json"):
    if path.name == "system-overview.json":
        continue
    text = path.read_text()
    updated = text
    for old, new in replacements:
        updated = updated.replace(old, new)
    if updated != text:
        path.write_text(updated)
        print(f"datasource uid set in {path.name}")
PY

echo "Done. Dashboards in $OUT_DIR"
ls -la "$OUT_DIR"
