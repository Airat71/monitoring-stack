# Nginx monitoring (optional)

The Nginx dashboard is in `grafana-dashboards/json/`. It stays empty until Nginx metrics are scraped.

The playbook flag `include_nginx` does not install an exporter and does not add a scrape job. Run nginx-prometheus-exporter (or stub_status) yourself and add a job to `prometheus.yml`, then reload Prometheus.
