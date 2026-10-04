# Upgrading the stack

- **Images:** On the monitoring server, `cd /opt/monitoring` (or your path), then `docker compose pull` and `docker compose up -d`. Pull uses the tags pinned in `docker-compose.yml`.
- **Config:** After updating playbook or templates, re-run the playbook so Prometheus/Grafana/Alertmanager configs are updated; then restart or reload services as in OPERATIONS.md.
- **Retention:** To change Prometheus retention, set `prometheus_retention` in group_vars (e.g. `15d`) and re-run the playbook.
