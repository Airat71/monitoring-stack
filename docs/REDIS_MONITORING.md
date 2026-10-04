# Redis monitoring (optional)

- Enable with `include_redis: true` and set `redis_host`. Deploy redis-exporter and add a Prometheus scrape job. The Redis Overview dashboard is included; it shows data once the exporter is scraped.
