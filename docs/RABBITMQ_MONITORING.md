# RabbitMQ monitoring (optional)

- Enable with `include_rabbitmq: true` and set `rabbitmq_host`. Deploy rabbitmq-exporter (or enable Prometheus plugin on RabbitMQ) and add a scrape job. The RabbitMQ Overview dashboard is in the bundle; it shows data once the job is configured.
