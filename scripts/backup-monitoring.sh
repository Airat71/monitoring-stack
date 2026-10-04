#!/usr/bin/env bash
# Backup Prometheus data, Grafana data, and configs.
# Deploy to server and run via cron (e.g. daily).
# Configure: BACKUP_DIR, RETENTION_DAYS; MONITORING_DIR = path where docker-compose.yml lives.

set -e
MONITORING_DIR="${MONITORING_DIR:-/opt/monitoring}"
BACKUP_DIR="${BACKUP_DIR:-/backup/monitoring}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
mkdir -p "$BACKUP_DIR"
cd "$MONITORING_DIR"

TS=$(date +%Y%m%d-%H%M%S)

# Prometheus TSDB (can be large)
docker compose exec -T prometheus tar czf - -C /prometheus . 2>/dev/null > "$BACKUP_DIR/prometheus-${TS}.tar.gz" || true

# Grafana (dashboards, DB)
docker compose exec -T grafana tar czf - -C /var/lib grafana 2>/dev/null > "$BACKUP_DIR/grafana-${TS}.tar.gz" || true

# Configs (small, useful for restore)
CONFIG_DIR="$BACKUP_DIR/config-$TS"
mkdir -p "$CONFIG_DIR"
cp -a prometheus.yml alerts.yml docker-compose.yml "$CONFIG_DIR/" 2>/dev/null || true
[ -f alertmanager.yml ] && cp -a alertmanager.yml "$CONFIG_DIR/"

# Rotate archives and old config dirs
find "$BACKUP_DIR" -maxdepth 1 -name 'prometheus-*.tar.gz' -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_DIR" -maxdepth 1 -name 'grafana-*.tar.gz' -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_DIR" -maxdepth 1 -type d -name 'config-*' -mtime +"$RETENTION_DAYS" -exec rm -rf {} + 2>/dev/null || true

echo "Backup done: $BACKUP_DIR"
