# Installation Guide

## Prerequisites

- **Monitoring server:** Docker · Docker Compose · SSH access
- **Ansible control node:** Ansible 2.9+ · Python 3 · SSH key access to all hosts
- **Monitored hosts:** Docker or systemd (for Node Exporter)

---

## Option A — Docker Compose (5 minutes)

```bash
cd prometheus-grafana
cp .env.example .env
# set GRAFANA_PASSWORD — compose will not start while it is empty
docker compose up -d
```

Grafana → http://localhost:3001 (admin / your password)
Prometheus → http://localhost:9090
Alertmanager → http://localhost:9093

Telegram is optional. Copy `alerts/alertmanager.example.yml` over `prometheus-grafana/alertmanager.yml`, set `bot_token` and a numeric `chat_id`, then `docker compose up -d alertmanager`.

---

## Option B — Full deploy with Ansible

1. **Copy and edit environment**
   ```bash
   cd prometheus-grafana
   cp .env.example .env
   # set GRAFANA_PASSWORD
   ```

2. **Configure inventory**
   ```bash
   cp ansible/inventory.example.yml ansible/inventory.yml
   ```
   Replace `192.168.1.10` with the IP of the machine that will run Grafana. Leave `monitored_nodes` empty until you want extra hosts. For an extra host, set `ansible_host` to the IPv4 address the monitoring server can open. Node Exporter on that host listens on that address at port 9100. Do not commit `inventory.yml`.

3. **Configure variables**
   ```bash
   cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
   ```
   For automated backups set `deploy_backup_script: true`.
   Nginx, PostgreSQL, Redis, and RabbitMQ flags do not install exporters.
   Telegram is optional. Set `telegram_bot_token` and numeric `telegram_chat_id` in Ansible Vault. Leave them unset to start Alertmanager without Telegram. Never commit `all.yml`.
   If `GRAFANA_PASSWORD` in `.env` is empty, the first playbook run generates one and prints it. Later runs keep the value already in `.env`.

4. **Dashboards**
   The nine dashboards in `grafana-dashboards/json/` are already in the repository. The playbook copies them. Run `./scripts/fetch-dashboards.sh` only after editing `scripts/build-dashboards.py`.

5. **Run the playbook**
   ```bash
   cd ansible && ansible-playbook -i inventory.yml playbook.yml
   ```

6. **Access**
   Open an SSH tunnel to reach Grafana from your local machine:
   ```bash
   ssh -L 3001:127.0.0.1:3001 user@<monitoring-server>
   ```
   Then open http://localhost:3001 (admin / your password).

---

## Next steps

- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) — detailed deployment walkthrough
- [docs/SECURITY.md](docs/SECURITY.md) — hardening checklist
- [docs/ALERTMANAGER.md](docs/ALERTMANAGER.md) — configure Telegram/email alerts
- [docs/MULTI_SERVER.md](docs/MULTI_SERVER.md) — add more hosts
- [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) — command cheat sheet
