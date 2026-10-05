# Grafana dashboards

Nine dashboards are provisioned from `grafana-dashboards/json/`. Grafana loads them on startup. The JSON is original to this repository and covered by the MIT license. Datasource uid is `prometheus`.

| Dashboard | uid | Shows data when |
|-----------|-----|-----------------|
| Host | `ms-host` | Any Node Exporter job is scraped — select it in the `$job` dropdown |
| System Overview | `system-overview` | Any Node Exporter job is scraped — select it in the `$job` dropdown |
| Prometheus | `ms-prometheus` | Prometheus scrapes itself — select the job in the `$job` dropdown |
| Blackbox | `ms-blackbox` | Any Blackbox probe job has targets — select it in the `$job` dropdown |
| Nginx | `ms-nginx` | Any scrape job exposes `nginx_up` — select it in the `$job` dropdown |
| PostgreSQL | `ms-postgresql` | Any scrape job exposes `pg_up` — select it in the `$job` dropdown |
| Redis | `ms-redis` | Any scrape job exposes `redis_up` — select it in the `$job` dropdown |
| RabbitMQ | `ms-rabbitmq` | Any scrape job exposes `rabbitmq_up` — select it in the `$job` dropdown |
| Fail2ban | `ms-fail2ban` | Any scrape job exposes `f2b_up` — select it in the `$job` dropdown |

Panels are `gauge`, `stat`, and `timeseries`. Thresholds on the Host dashboard follow the alert rules: CPU 80%, memory 85%, disk 80/90%, load per CPU 1.5.

Nginx, PostgreSQL, Redis, RabbitMQ, and Fail2ban stay empty until those exporters are scraped. The stack does not install those exporters.

To change a dashboard, edit `scripts/build-dashboards.py` and run `./scripts/fetch-dashboards.sh`. Do not replace these files with downloads from grafana.com.
