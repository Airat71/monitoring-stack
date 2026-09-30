# OPERATIONS — Daily runbook (PRO)

## Daily checks

- **Grafana:** Open dashboards, confirm panels show data (no "No data" on critical panels).
- **Prometheus:** Status → Targets — all targets UP.
- **Alertmanager:** Alerts → check for firing alerts; silence or fix as needed.

## Health and readiness

- All stack containers have **healthchecks** (Prometheus `/-/healthy`, Grafana `/api/health`, Alertmanager `/-/healthy`, Node Exporter and Blackbox metrics endpoint). Grafana starts only after Prometheus is healthy (`depends_on: condition: service_healthy`).
- Check container health: `docker compose ps` (state should be "Up (healthy)" where applicable).

## Common tasks

### Restart a service

```bash
cd /opt/monitoring   # or your monitoring_base_dir
docker compose restart prometheus
docker compose restart grafana
docker compose restart alertmanager
```

### Reload Prometheus config

```bash
curl -X POST http://127.0.0.1:9090/-/reload
```

### Add a new monitored host

1. Add the host to Ansible inventory under `monitored_nodes` with `ansible_host`.
2. Run playbook: `ansible-playbook -i inventory.yml playbook.yml`.
3. Prometheus will scrape the new node-exporter; no need to edit prometheus.yml by hand if using the PRO template.

### View logs

```bash
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f alertmanager
```

## Backup

See BACKUP.md for automated backup of Prometheus data and Grafana config.
