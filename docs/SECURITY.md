# SECURITY — Best practices

## Binding and access

- **Localhost-only:** Prometheus, Grafana, Alertmanager, Blackbox, and the monitoring server's Node Exporter are bound to `127.0.0.1` in `prometheus-grafana/docker-compose.yml`. `127.0.0.1:9100` is this loopback publish. It is not a server address, and Prometheus reaches that exporter on the Docker network as `node-exporter:9100`. Do not publish these ports on a public address.
- **Remote Node Exporter:** On hosts in `monitored_nodes`, port 9100 listens on the inventory IPv4 address. The playbook adds an iptables chain that accepts that port only from the monitoring server (`node_exporter_allow_from`, otherwise that server's `ansible_host`) and drops other sources. SSH and every other port stay on the host's existing policy. Docker publishes the port through its own chain, so the rule is attached to both `INPUT` and `DOCKER-USER`. IPv6 to that port is dropped. Metrics still include hostnames, mount points, and interface addresses.
- **Access from outside:** Open an SSH tunnel. Example: `ssh -L 3001:127.0.0.1:3001 -L 9090:127.0.0.1:9090 -L 9093:127.0.0.1:9093 user@monitoring-server`.
- **Grafana:** The stack does not start without `GRAFANA_PASSWORD` in `.env`. Do not use `admin` or any password from an example. Enable HTTPS if you put a reverse proxy in front.

## Secrets

- Store secrets in `.env` on the server (not in git). Use **Ansible Vault** for `group_vars` that contain Telegram token, SMTP password, etc.
- Do not commit `.env`, `inventory.yml` (if it contains real IPs/hostnames), or vault passwords. The repo includes only `inventory.example.yml` and `.env.example` with placeholders.

## Hardening

- Run containers as non-root where possible (image-dependent).
- Keep images updated: `docker compose pull` and restart periodically.
- Restrict firewall to allow only SSH (and optionally reverse proxy ports) from trusted IPs.

## fail2ban

- fail2ban monitoring is optional. Dashboard `ms-fail2ban` and the fail2ban alerts stay empty until an exporter exposes `f2b_up`. See FAIL2BAN_ENHANCED.md.
- Image `registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3` runs as uid 0. `group_add` does not drop that uid. The socket is the fail2ban control API. Leave the socket mode owner-only, and mount the directory `/var/run/fail2ban` read-only only after the socket file exists.
