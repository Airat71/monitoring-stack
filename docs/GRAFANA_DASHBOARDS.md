# Grafana dashboards

Eight dashboards are provisioned from `grafana-dashboards/json/`. Grafana loads them on startup.

| # | Dashboard | Purpose |
|---|-----------|---------|
| 1 | Node Exporter Full | CPU, RAM, disk, network |
| 2 | Prometheus 2.0 Overview | Prometheus self-monitoring |
| 3 | Blackbox Exporter | HTTP probe results |
| 4 | System Overview | CPU, memory, and disk for this host |
| 5 | Nginx | Nginx metrics (optional) |
| 6 | PostgreSQL Database | PostgreSQL metrics (optional) |
| 7 | RabbitMQ Overview | RabbitMQ (optional) |
| 8 | Redis Overview | Redis (optional) |

Node Exporter Full and System Overview use current Grafana panels.

Nginx, PostgreSQL, RabbitMQ, Redis, Blackbox, and Prometheus 2.0 Overview are the upstream community exports. Several of those files still use the retired `graph` and `singlestat` panels, so Grafana 13 shows the dashboard entry and does not draw those panels. Nginx, PostgreSQL, RabbitMQ, and Redis also stay empty until their exporters are scraped.
