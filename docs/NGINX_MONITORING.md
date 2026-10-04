# Nginx monitoring (optional)

- Enable with `include_nginx: true` in group_vars. Deploy nginx-exporter (or use stub_status) and add a Prometheus scrape job for it. The Nginx dashboard JSON is in `grafana-dashboards/json/`. It shows "No data" until the exporter is scraped.
- See the public repo docs for nginx stub_status or nginx-exporter setup.
