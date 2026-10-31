# Upgrading the stack

Read the [CHANGELOG](../CHANGELOG.md) for the versions you skip. The data of Prometheus, Alertmanager and Grafana lives in named Docker volumes and is kept.

## Docker Compose (`prometheus-grafana/`)

```bash
git fetch --tags && git checkout <new version tag>   # for example v2.3.0
cd prometheus-grafana
docker compose pull
docker compose up -d
bash ../scripts/smoke-check.sh
```

`up -d` exits 0 even when Grafana cannot save a dashboard, and the smoke check does not look at dashboards. `docker compose logs grafana | grep "failed to save dashboard"` prints nothing when all of them were applied. If it prints lines or the dashboards look wrong after an upgrade (v2.2.0 to v2.3.0), see [TROUBLESHOOTING](TROUBLESHOOTING.md#dashboards-missing-or-old-after-an-upgrade).

CI runs `scripts/upgrade-check.sh` on every change that touches the stack: it starts the latest release with data, switches to the new commit on the same volumes and checks the result. To run it yourself on a machine where ports 9090, 3001, 9093, 9100 and 9115 are free and no containers named `prometheus`, `grafana`, `alertmanager`, `node-exporter` or `blackbox-exporter` exist, stopped ones included (not next to a stack you use; the script stops with a message if it finds them): `git worktree add ../old <tag> && bash scripts/upgrade-check.sh ../old .` It uses its own Compose project and password, does not touch your `.env`, and removes only its own containers and volumes.

## Ansible (`/opt/monitoring`)

- **Images:** On the monitoring server, `cd /opt/monitoring` (or your path), then `docker compose pull` and `docker compose up -d`. Pull uses the tags pinned in `docker-compose.yml`.
- **Config:** After updating playbook or templates, re-run the playbook so Prometheus/Grafana/Alertmanager configs are updated; then restart or reload services as in OPERATIONS.md.
- **Retention:** To change Prometheus retention with Ansible, set `prometheus_retention` in group_vars (e.g. `15d`) and re-run the playbook. With plain Docker Compose, change `--storage.tsdb.retention.time` in `prometheus-grafana/docker-compose.yml` and run `docker compose up -d prometheus`.
