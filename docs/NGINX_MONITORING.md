# Nginx monitoring (optional)

The Nginx dashboard is in `grafana-dashboards/json/`. It stays empty until Nginx metrics are scraped.

The playbook does not install a nginx exporter and does not add a scrape job for it. Run nginx-prometheus-exporter (or stub_status) yourself and add a job to `prometheus.yml`, then reload Prometheus.
