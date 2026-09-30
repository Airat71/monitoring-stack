# BACKUP — Automated backups (PRO)

## What to back up

- **Prometheus data:** `prometheus-data` volume (TSDB). Large; consider retention vs backup size.
- **Grafana:** `grafana-data` volume (dashboards, users). Smaller.
- **Configs:** `prometheus.yml`, `alerts.yml`, `alertmanager.yml`, `docker-compose.yml` — keep in git or copy to a safe path.

## Script and Ansible

PRO includes **`scripts/backup-monitoring.sh`**. It backs up Prometheus TSDB, Grafana data, and configs into a timestamped dir; rotates by `RETENTION_DAYS` (default 7).

**Deploy via Ansible:** in `group_vars/all.yml` set:
```yaml
deploy_backup_script: true
backup_dir: /backup/monitoring
backup_retention_days: 7
backup_cron_enabled: true
```
Then run the playbook. The script is copied to `{{ monitoring_base_dir }}/scripts/backup-monitoring.sh` and a daily cron (02:00) is added.

**Manual run:** on the server:
```bash
MONITORING_DIR=/opt/monitoring BACKUP_DIR=/backup/monitoring RETENTION_DAYS=7 /opt/monitoring/scripts/backup-monitoring.sh
```

## Restore

Stop stack, restore Prometheus/Grafana volumes from the `.tar.gz` archives, copy configs from `config-<ts>/` if needed, then `docker compose up -d`.
