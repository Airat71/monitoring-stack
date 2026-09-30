# MULTI_SERVER — Adding and managing multiple hosts (PRO)

- **Monitoring server:** One host runs the full stack (Prometheus, Grafana, Alertmanager, Node Exporter, Blackbox). Set this host in the `monitoring_server` group.
- **Monitored nodes:** Other hosts need only Node Exporter. Add them to the `monitored_nodes` group with `ansible_host: <IP or hostname>`.
- **Discovery:** The PRO Prometheus template automatically adds all `monitored_nodes` as scrape targets for the `node-exporter` job. Re-run the playbook after adding or removing nodes.
- **Optional services:** If a node runs PostgreSQL, Redis, or RabbitMQ, set the corresponding `include_*` and host vars (e.g. `postgresql_host`) so the playbook can add the right scrape configs (when implemented in the template).
