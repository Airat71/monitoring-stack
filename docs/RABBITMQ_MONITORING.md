# RabbitMQ monitoring (optional)

The RabbitMQ dashboard is in `grafana-dashboards/json/`. It stays empty until RabbitMQ metrics are scraped.

The playbook does not install a RabbitMQ exporter and does not add a scrape job for it. Enable the RabbitMQ Prometheus plugin or run an exporter yourself, add a job to `prometheus.yml`, then reload Prometheus.
