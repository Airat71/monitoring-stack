# Quick Start Guide

Get your monitoring stack running in **5 minutes**!

---

## Option 1: FREE — Deploy in 2 minutes (Docker Compose)

Best for trying the stack on your machine or a single server.

### Prerequisites
- Docker and Docker Compose installed
- 2GB+ RAM, 10GB disk

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Airat71/monitoring-stack.git
cd monitoring-stack/prometheus-grafana

# 2. Set your Grafana password
cp .env.example .env
# Edit .env — change GRAFANA_PASSWORD (optional; default is in docker-compose)

# 3. Start the stack
docker compose up -d

# 4. Check status
docker compose ps
```

### Access

- **Grafana:** http://localhost:3001 (user: `admin`, password: from `.env` or default in repo)
- **Prometheus:** http://localhost:9090

**What you get:** Prometheus + Grafana + Node Exporter, 2 dashboards (System Overview, Node Exporter Full), 5 alert rules (visible in Prometheus UI).

---

## Option 2: Production Deployment (FREE on a server)

For running the FREE stack on your own server (Ubuntu 20.04/22.04).

### Prerequisites
- Ubuntu 20.04 or 22.04 LTS, 2GB+ RAM, 2+ CPU cores, sudo access

### Install

```bash
# 1. Install Docker (if not already)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Clone and start (same as Option 1)
git clone https://github.com/Airat71/monitoring-stack.git
cd monitoring-stack/prometheus-grafana
cp .env.example .env
docker compose up -d
```

### Access (from your Mac via SSH tunnel)

**Create SSH Tunnel from your Mac:**
```bash
ssh -L 3001:localhost:3001 -L 9090:localhost:9090 your-user@your-server-ip
```

**Then open in browser:**
- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090

---

## Option 3: PRO Version (One-Command Deployment)

Get the complete solution with Ansible automation.

### Prerequisites
- Ansible 2.9+ installed on your machine
- SSH access to target servers
- PRO version purchased ($40)

### Steps

```bash
# 1. Extract PRO version files
unzip monitoring-stack-pro.zip
cd monitoring-stack-pro

# 2. Configure inventory
nano ansible/inventories/production.ini
# Add your server IPs

# 3. Deploy everything with ONE command
cd ansible
ansible-playbook playbooks/deploy-monitoring-stack.yml -i inventories/production.ini

# ✅ Done! Full stack deployed in ~10 minutes
```

**What gets deployed:**
- ✅ Docker + Docker Compose
- ✅ Prometheus + Grafana + Alertmanager
- ✅ Node Exporter on all servers
- ✅ fail2ban monitoring integration
- ✅ 8 professional dashboards
- ✅ 20 production alerts
- ✅ Automated backups
- ✅ Health checks

---

## Next Steps

### 1. Explore Dashboards

**FREE version (2 dashboards):**
- **System Overview** - CPU, Memory, Disk gauges
- **Node Exporter Full** - Detailed system metrics

**PRO adds:** Prometheus Stats, Blackbox, fail2ban, Nginx, PostgreSQL, RabbitMQ, Redis.

### 2. Configure Alerts

Edit alert rules:
```bash
nano prometheus-grafana/alerts.yml
```

Test alerts:
```bash
# Trigger a test alert
curl -X POST http://localhost:9090/-/reload
```

### 3. Add More Servers

**FREE Version:**
```bash
# Install Node Exporter on target server
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
# Create systemd service...

# Add to prometheus.yml
nano prometheus-grafana/prometheus.yml
# Add new target under scrape_configs
```

**PRO Version:**
```bash
# Just run the playbook!
ansible-playbook playbooks/install-node-exporter.yml -i inventories/production.ini
```

### 4. Setup Notifications (PRO only)

FREE has 5 alert rules in Prometheus UI only (no notifications). PRO adds Alertmanager with Telegram/Email.

**Telegram (PRO):**
```bash
# Edit alertmanager.yml
nano prometheus-grafana/alertmanager.yml

# Add your bot token and chat ID
telegram_configs:
  - bot_token: 'YOUR_BOT_TOKEN'
    chat_id: YOUR_CHAT_ID
```

**Email:**
```bash
# Configure SMTP in alertmanager.yml
email_configs:
  - to: 'airat71@proton.me'
    from: 'alerts@your-domain.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'your-email@gmail.com'
    auth_password: 'your-app-password'
```

---

## Common Tasks

### Check System Status
```bash
docker compose ps                    # All containers
docker compose logs -f prometheus   # Prometheus logs
docker compose logs -f grafana      # Grafana logs
```

### Restart Services
```bash
docker compose restart prometheus
docker compose restart grafana
docker compose restart              # All services
```

### Update Configuration
```bash
# Edit prometheus.yml
nano prometheus-grafana/prometheus.yml

# Reload Prometheus (no restart needed!)
curl -X POST http://localhost:9090/-/reload
```

### Backup Data
```bash
# Backup volumes
docker compose down
sudo tar -czf monitoring-backup.tar.gz \
  /var/lib/docker/volumes/prometheus-grafana_*

# Start again
docker compose up -d
```

---

## Troubleshooting

### docker compose pull fails (timeout / TLS error)
Network or Docker Hub may be slow or blocked. Try again later, or pull manually:
```bash
docker compose pull
# If it still fails, check your network and Docker Hub status
```

### Grafana shows "No data"
```bash
# Check Prometheus is running
curl http://localhost:9090/-/healthy

# Check datasource
# Grafana → Configuration → Data Sources → Prometheus
# URL should be: http://prometheus:9090
```

### Alerts not firing
```bash
# Check alert rules loaded
curl http://localhost:9090/api/v1/rules

# Check Alertmanager
curl http://localhost:9093/api/v1/alerts
```

### Can't access dashboards
```bash
# Check SSH tunnel is active
ps aux | grep ssh

# Recreate tunnel
ssh -L 3001:localhost:3001 -L 9090:localhost:9090 user@server
```

---

## Performance Tips

### For Small Servers (2GB RAM)
```yaml
# Reduce retention in prometheus.yml
storage:
  tsdb:
    retention.time: 7d  # Instead of 15d
```

### For Production (4GB+ RAM)
```yaml
# Increase retention for longer history
storage:
  tsdb:
    retention.time: 30d
```

---

## What's Next?

1. **Read the docs** - [Full Documentation](../README.md#documentation)
2. **Customize dashboards** - Import from [Grafana.com](https://grafana.com/grafana/dashboards/)
3. **Add more servers** - Scale your monitoring
4. **Setup backups** - Automate data protection
5. **Upgrade to PRO** - Get advanced features [$40](PURCHASE.md)

---

## Getting Help

**FREE Version:**
- GitHub Issues
- Community discussions

**PRO Version:**
- Direct email support: airat71@proton.me
- Priority bug fixes
- Custom configuration help

---

**Happy Monitoring!** 🎉

If this helped you, please ⭐ star the repository!
