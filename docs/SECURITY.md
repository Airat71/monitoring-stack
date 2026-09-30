# SECURITY — Best practices (PRO)

## Binding and access

- **Localhost-only:** Prometheus, Grafana, Alertmanager and Blackbox are bound to `127.0.0.1` in the PRO docker-compose. Do not expose them directly to the internet.
- **Access from outside:** Use **SSH tunnel** (see SSH_TUNNEL_ACCESS.md). Example: `ssh -L 3001:127.0.0.1:3001 user@monitoring-server`.
- **Grafana:** Change default admin password; use strong `GRAFANA_PASSWORD` in `.env`. Enable HTTPS if you put a reverse proxy in front.

## Secrets

- Store secrets in `.env` on the server (not in git). Use **Ansible Vault** for `group_vars` that contain Telegram token, SMTP password, etc.
- Do not commit `.env`, `inventory.yml` (if it contains real IPs/hostnames), or vault passwords. The repo includes only `inventory.example.yml` and `.env.example` with placeholders.

## Hardening

- Run containers as non-root where possible (image-dependent).
- Keep images updated: `docker compose pull` and restart periodically.
- Restrict firewall to allow only SSH (and optionally reverse proxy ports) from trusted IPs.

## fail2ban

- PRO includes optional fail2ban monitoring. Ensure fail2ban is configured with sensible bantime and findtime; see FAIL2BAN_ENHANCED.md.
