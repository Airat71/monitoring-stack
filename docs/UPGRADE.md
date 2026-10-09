# Upgrading the stack

- **Images:** On the monitoring server, `cd /opt/monitoring` (or your path), then `docker compose pull` and `docker compose up -d`. Pull uses the tags pinned in `docker-compose.yml`.
- **Config:** After updating playbook or templates, re-run the playbook so Prometheus/Grafana/Alertmanager configs are updated; then restart or reload services as in OPERATIONS.md.
- **Retention:** To change Prometheus retention with Ansible, set `prometheus_retention` in group_vars (e.g. `15d`) and re-run the playbook. With plain Docker Compose, change `--storage.tsdb.retention.time` in `prometheus-grafana/docker-compose.yml` and run `docker compose up -d prometheus`.
