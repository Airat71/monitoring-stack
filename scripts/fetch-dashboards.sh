#!/usr/bin/env bash
# Rebuild grafana-dashboards/json/ from scripts/build-dashboards.py.
# The JSON is already committed. Run this after editing the builder.
# Run from anywhere: ./scripts/fetch-dashboards.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 "${ROOT}/scripts/build-dashboards.py"
