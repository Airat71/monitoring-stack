# Redis monitoring (optional)

The Redis dashboard is in `grafana-dashboards/json/`. It stays empty until Redis metrics are scraped.

The playbook flag `include_redis` does not install an exporter and does not add a scrape job. Run redis_exporter yourself and add a job to `prometheus.yml`, then reload Prometheus.
