# PostgreSQL monitoring (optional)

The PostgreSQL dashboard is in `grafana-dashboards/json/`. It stays empty until PostgreSQL metrics are scraped.

The playbook does not install a PostgreSQL exporter and does not add a scrape job for it. Run postgres_exporter yourself, with a dedicated user such as `pg_monitor`, add a job to `prometheus.yml`, then reload Prometheus.
