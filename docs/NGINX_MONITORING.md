# Nginx monitoring (optional, PRO)

- Enable with `include_nginx: true` in group_vars. Deploy nginx-exporter (or use stub_status) and add a Prometheus scrape job for it. The Nginx dashboard JSON is included in the PRO bundle; it will show "No data" until the job and exporter are configured.
- See the public repo docs for nginx stub_status or nginx-exporter setup.
