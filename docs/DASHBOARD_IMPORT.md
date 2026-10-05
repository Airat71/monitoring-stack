# Dashboards in this repository

The nine dashboards are already in `grafana-dashboards/json/`. Docker Compose and the Ansible playbook provision them. There is nothing to download.

Grafana reads `/etc/grafana/provisioning/dashboards/json`. After a JSON change, restart Grafana or wait for the next provisioning cycle:

```bash
docker compose restart grafana
```

To regenerate the files from the builder:

```bash
./scripts/fetch-dashboards.sh
```

A dashboard file can also be imported by hand: Dashboards → New → Import → Upload dashboard JSON. Select the Prometheus datasource whose uid is `prometheus`.
