# PostgreSQL monitoring (optional, PRO)

- Enable with `include_postgresql: true` and set `postgresql_host` (and credentials via vault). Add a postgres-exporter container or systemd service and a Prometheus scrape job. The PostgreSQL dashboard is included; it shows "No data" until the exporter is running and scraped.
- Use a dedicated DB user with limited privileges (e.g. pg_monitor).
