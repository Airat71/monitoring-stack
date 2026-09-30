# Grafana dashboards (PRO) — 8 dashboards

PRO includes 8 dashboards. All are provisioned from the `dashboards/` folder; Grafana loads them automatically.

| # | Dashboard | Purpose |
|---|-----------|---------|
| 1 | Node Exporter Full | CPU, RAM, disk, network |
| 2 | Prometheus Stats | Prometheus self-monitoring |
| 3 | fail2ban Monitoring | Security (bans, jails) |
| 4 | Blackbox Exporter | HTTP/HTTPS probe results |
| 5 | Nginx Monitoring | Nginx metrics (optional) |
| 6 | PostgreSQL Database | PostgreSQL metrics (optional) |
| 7 | RabbitMQ Overview | RabbitMQ (optional) |
| 8 | Redis Overview | Redis (optional) |

If Nginx/PostgreSQL/RabbitMQ/Redis are not enabled, those dashboards show "No data". See DASHBOARDS_AND_OPTIONAL_SERVICES in the public repo docs.
