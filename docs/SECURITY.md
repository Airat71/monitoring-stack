# SECURITY — Best practices

## Binding and access

- **Localhost-only:** Prometheus, Grafana, Alertmanager and Blackbox are bound to `127.0.0.1` in `prometheus-grafana/docker-compose.yml`. Do not expose them directly to the internet.
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

- fail2ban monitoring is optional. Dashboard `ms-fail2ban` and alert `Fail2banHighAttackRate` stay empty until an exporter exposes `f2b_up`. See FAIL2BAN_ENHANCED.md.
