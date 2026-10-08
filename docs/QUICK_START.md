# Quick Start

Get your monitoring stack running in **5 minutes**.

---

## Option A — Docker Compose (fastest)

### Prerequisites
- Docker and Docker Compose
- 2GB+ RAM, 10GB disk

```bash
git clone https://github.com/Airat71/monitoring-stack.git
cd monitoring-stack/prometheus-grafana
cp .env.example .env
# Edit .env — set GRAFANA_PASSWORD. Compose will not start while it is empty.
docker compose up -d
docker compose ps   # verify all containers are healthy
```

**Access** (bound to 127.0.0.1):
- Grafana: http://localhost:3001 (admin / your password)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

**On a remote server** — open an SSH tunnel first:
```bash
ssh -L 3001:127.0.0.1:3001 -L 9090:127.0.0.1:9090 -L 9093:127.0.0.1:9093 user@your-server-ip
```

---

## Option B — Same stack on a server, with Ansible

Deploys this stack to your server. Additional hosts stay out of the example until you add them.

```bash
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
cp ansible/inventory.example.yml ansible/inventory.yml
# replace 192.168.1.10 with your server IP
cd ansible && ansible-playbook -i inventory.yml playbook.yml
```

If `GRAFANA_PASSWORD` is empty, the playbook generates it and prints it once. Full steps: [INSTALLATION_GUIDE.md](../INSTALLATION_GUIDE.md).

---

## Common operations

### Status and logs
```bash
docker compose ps
docker compose logs -f prometheus
docker compose logs -f grafana
```

### Restart
```bash
docker compose restart prometheus
docker compose restart grafana
docker compose restart        # all services
```

### Reload Prometheus config (no restart)
```bash
curl -X POST http://localhost:9090/-/reload
```

### Add more servers
```bash
# Option 1 — Ansible (recommended)
# Edit ansible/inventory.yml, add host under monitored_nodes
cd ansible && ansible-playbook -i inventory.yml playbook.yml

# Option 2 — manual Node Exporter on the new host, then update prometheus.yml
```

### Configure alerts (Telegram)
```bash
# Edit alerts/alertmanager.example.yml — set bot_token and a numeric chat_id
# Copy it over prometheus-grafana/alertmanager.yml, then:
# docker compose up -d alertmanager
```

---

## Troubleshooting

**docker compose pull fails:** slow or blocked Docker Hub — retry, or `docker pull` images individually.

**Grafana shows "No data":**
```bash
curl http://localhost:9090/-/healthy   # check Prometheus
# In Grafana → Connections → Data Sources → Prometheus: URL = http://prometheus:9090
```

**Alerts not firing:**
```bash
curl http://localhost:9090/api/v1/rules    # check rules loaded
curl http://localhost:9093/api/v1/alerts  # check Alertmanager
```

**SSH tunnel drops:** restart with the same `-L` flags or use autossh for persistence.

---

## What's next

- [docs/DEPLOYMENT.md](DEPLOYMENT.md) — production deployment guide
- [docs/MULTI_SERVER.md](MULTI_SERVER.md) — monitor multiple servers
- [docs/ALERTMANAGER.md](ALERTMANAGER.md) — configure Telegram/email alerts
- [docs/GRAFANA_DASHBOARDS.md](GRAFANA_DASHBOARDS.md) — the nine shipped dashboards
- [docs/SECURITY.md](SECURITY.md) — hardening checklist

---

If this project helped you, a ⭐ on GitHub is appreciated.
