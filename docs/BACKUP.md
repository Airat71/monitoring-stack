# BACKUP — Automated backups

## What to back up

- **Prometheus data:** `prometheus-data` volume (TSDB). Large; consider retention vs backup size.
- **Grafana:** `grafana-data` volume (dashboards, users). Smaller than Prometheus data in a long-running install, but the archive includes the `plugins` directory (about 150 MB on a fresh install).
- **Configs:** the script copies `prometheus.yml`, `alerts.yml`, `docker-compose.yml` and, when it exists, `alertmanager.yml`. It does not copy `blackbox.yml` or `.env` (it holds the Grafana password): copy those yourself. `alertmanager.yml` can hold the Telegram token and the copy keeps the source file mode, so restrict access to `BACKUP_DIR`.

## Script and Ansible

**`scripts/backup-monitoring.sh`** backs up Prometheus TSDB, Grafana data, and configs into a timestamped dir and rotates by `RETENTION_DAYS` (default 7).

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

The script writes `prometheus-<ts>.tar.gz`, `grafana-<ts>.tar.gz` and `config-<ts>/` into `BACKUP_DIR`. The Grafana archive has a top-level `grafana/` directory and the Prometheus archive does not, so they are unpacked differently. Extracting the Grafana archive into the wrong path leaves the old data in place without an error.

Volume names are `<project>_grafana-data` and `<project>_prometheus-data`, where the project is the name of the directory that holds `docker-compose.yml` (`monitoring` for `/opt/monitoring`). Check with `docker volume ls`.

```bash
cd /opt/monitoring
TS=20261009-130129                 # timestamp of the archives to restore
docker compose down

# Grafana: clear the volume, unpack without the top-level grafana/ directory
docker run --rm -v monitoring_grafana-data:/data -v /backup/monitoring:/backup:ro alpine \
  sh -c "rm -rf /data/* /data/.[!.]*; tar xzf /backup/grafana-$TS.tar.gz -C /data --strip-components=1"

# Prometheus: clear the volume, unpack as is
docker run --rm -v monitoring_prometheus-data:/data -v /backup/monitoring:/backup:ro alpine \
  sh -c "rm -rf /data/* /data/.[!.]*; tar xzf /backup/prometheus-$TS.tar.gz -C /data"

docker compose up -d
```

Copy configs from `config-<ts>/` if you need them. Afterwards open Grafana and check that your dashboards and folders are back, and that all Prometheus targets are up.
