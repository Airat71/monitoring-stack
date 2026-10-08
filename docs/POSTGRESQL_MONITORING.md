# PostgreSQL monitoring (optional)

The PostgreSQL dashboard is in `grafana-dashboards/json/`. It stays empty until PostgreSQL metrics are scraped.

The playbook flag `include_postgresql` does not install an exporter and does not add a scrape job. Run postgres_exporter yourself, with a dedicated user such as `pg_monitor`, add a job to `prometheus.yml`, then reload Prometheus.
