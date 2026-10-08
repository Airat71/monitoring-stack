# MULTI_SERVER — Adding and managing multiple hosts

- **Monitoring server:** One host runs the full stack (Prometheus, Grafana, Alertmanager, Node Exporter, Blackbox). Set this host in the `monitoring_server` group. Its Node Exporter container publishes `127.0.0.1:9100`. Prometheus scrapes `node-exporter:9100` on the Compose network, so that loopback port is not used for remote scrapes.
- **Monitored nodes:** Other hosts need only Node Exporter. Add them under `monitored_nodes` with `ansible_host` set to an IPv4 address the monitoring server can open. The exporter listens on that address at port 9100. `127.0.0.1:9100` on those hosts would not accept the monitoring server's connection.
- **Firewall:** If `ansible_host` is reachable from networks you do not trust, allow TCP 9100 only from the monitoring server. The repository does not change host firewall rules.
- **Discovery:** The Ansible Prometheus template adds every host in `monitored_nodes` as a scrape target for the `node-exporter` job. Re-run the playbook after adding or removing nodes. The playbook reloads Prometheus.
- **systemd or Docker:** `node_exporter_install_method` is `docker` by default. Set `systemd` on a host that should run the binary instead. The systemd unit listens on `ansible_host` and does not use `/host/proc`.
- **Optional services:** Nginx, PostgreSQL, Redis, and RabbitMQ dashboards ship in the repository. The playbook does not install those exporters. Add the exporter and a scrape job yourself; until then the dashboard is empty.
