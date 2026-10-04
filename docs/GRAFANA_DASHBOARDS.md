# Grafana dashboards

Eight dashboards are provisioned from `grafana-dashboards/json/`. Grafana loads them on startup. The JSON is original to this repository and covered by the MIT license. Datasource uid is `prometheus`.

| Dashboard | uid | Shows data when |
|-----------|-----|-----------------|
| Host | `ms-host` | Node Exporter job `node-exporter` is scraped |
| System Overview | `system-overview` | Node Exporter job `node-exporter` is scraped |
| Prometheus | `ms-prometheus` | Prometheus scrapes itself |
| Blackbox | `ms-blackbox` | The `blackbox` probe job has targets |
| Nginx | `ms-nginx` | A scrape job named `nginx` exposes `nginx_up` |
| PostgreSQL | `ms-postgresql` | A scrape job named `postgresql` exposes `pg_up` |
| Redis | `ms-redis` | A scrape job named `redis` exposes `redis_up` |
| RabbitMQ | `ms-rabbitmq` | A scrape job named `rabbitmq` exposes `rabbitmq_up` |

Panels are `gauge`, `stat`, and `timeseries`. Thresholds on the Host dashboard follow the alert rules: CPU 80%, memory 85%, disk 80/90%, load per CPU 1.5.

Nginx, PostgreSQL, Redis, and RabbitMQ stay empty until those exporters are scraped. The stack does not install those exporters.

To change a dashboard, edit `scripts/build-dashboards.py` and run `./scripts/fetch-dashboards.sh`. Do not replace these files with downloads from grafana.com.
