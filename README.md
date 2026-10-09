# Monitoring Stack

[![CI](https://github.com/Airat71/monitoring-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/Airat71/monitoring-stack/actions/workflows/ci.yml)
[![Security](https://github.com/Airat71/monitoring-stack/actions/workflows/security.yml/badge.svg)](https://github.com/Airat71/monitoring-stack/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Stars](https://img.shields.io/github/stars/Airat71/monitoring-stack?style=social)](https://github.com/Airat71/monitoring-stack/stargazers)

Self-hosted monitoring for Linux servers — Prometheus · Grafana · Alertmanager · Ansible · fail2ban.

One-command deploy, 9 original dashboards, optional Telegram alerts, multi-server support. Ready in 15 minutes.

If this saved you time, a [⭐ star](https://github.com/Airat71/monitoring-stack) helps others find it.

---

## What's included

| Component | Details |
|-----------|---------|
| **Core stack** | Prometheus · Grafana · Alertmanager · Node Exporter · Blackbox Exporter |
| **Security** | fail2ban dashboard and alert; the exporter is installed separately |
| **Ansible automation** | One-command full deployment + Node Exporter on remote hosts |
| **Dashboards** | 9 original JSON dashboards (see below) |
| **Alerts** | 17 alert rules (see docs/MONITORING.md) |
| **Multi-server** | Monitor N servers from one Grafana instance |
| **Backups** | Automated backup script with optional cron |
| **Documentation** | 20 guides: deployment, security, operations, runbook, troubleshooting |

---

## Dashboards

9 original dashboards — written for this stack, current panel types, render on Grafana 13 without additional configuration. MIT licensed, datasource uid `prometheus`.

| Dashboard | What it covers | After `docker compose up` |
|-----------|----------------|--------------------------|
| Host | CPU, memory, disk, network per host | Live |
| System Overview | CPU, memory, disk, load, uptime | Live |
| Prometheus | Scrape duration, TSDB, Alertmanager link | Live |
| Blackbox | Probe success, HTTP status, TLS expiry | Live |
| Nginx | Connections and request rate | Empty until an exporter exposes `nginx_up` |
| PostgreSQL | Sessions, transactions, database size | Empty until an exporter exposes `pg_up` |
| Redis | Memory, hit ratio, commands/sec | Empty until an exporter exposes `redis_up` |
| RabbitMQ | Connections and queue depth | Empty until an exporter exposes `rabbitmq_up` |
| Fail2ban | Current bans, failed attempts, ban rate | Empty until an exporter exposes `f2b_up` |

---

## Quick Start (Docker Compose — 5 minutes)

```bash
git clone https://github.com/Airat71/monitoring-stack.git
cd monitoring-stack/prometheus-grafana
cp .env.example .env          # set GRAFANA_PASSWORD (required)
docker compose up -d
# Grafana → http://localhost:3001  (admin / your password)
# Prometheus → http://localhost:9090
# Alertmanager → http://localhost:9093
```

---

## Full Deploy with Ansible (single command)

Deploys the stack to your server. Extra hosts are commented out in the example inventory; add them when you want multi-server metrics.

```bash
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
cp ansible/inventory.example.yml ansible/inventory.yml
# replace 192.168.1.10 with your server IP
cd ansible && ansible-playbook -i inventory.yml playbook.yml
```

The first run generates a Grafana admin password and prints it when `.env` does not already have one. Node Exporter on the monitoring server stays at `127.0.0.1:9100`. An extra host listens on its inventory IP, port 9100.

Step-by-step: [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

---

## Architecture

```
  [Monitored hosts]
    Node Exporter  ──┐
    fail2ban        ──┤
                     │
              [Prometheus] ──→ [Alertmanager] ──→ Telegram / Email
                     │
              [Blackbox]   (HTTP/TCP probes)
                     │
               [Grafana]   (Dashboards + Alerts UI)
```

---

## Alerts

17 alert rules covering:

- Host down / unreachable
- CPU · memory · disk thresholds
- Service unavailable (HTTP, TCP probes)
- fail2ban ban events and a dead exporter socket (`f2b_up == 0`)
- Prometheus self-monitoring

See [`alerts/alertmanager.example.yml`](alerts/alertmanager.example.yml) for routing configuration.

---

## Documentation

| Guide | Topic |
|-------|-------|
| [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) | Getting started, prerequisites |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Deployment options |
| [docs/MULTI_SERVER.md](docs/MULTI_SERVER.md) | Monitor multiple servers |
| [docs/ALERTMANAGER.md](docs/ALERTMANAGER.md) | Alert routing and receivers |
| [docs/GRAFANA_DASHBOARDS.md](docs/GRAFANA_DASHBOARDS.md) | Dashboard import and usage |
| [docs/SECURITY.md](docs/SECURITY.md) | Security hardening |
| [docs/PRODUCTION_CHECKLIST.md](docs/PRODUCTION_CHECKLIST.md) | Pre-production checklist |
| [docs/BACKUP.md](docs/BACKUP.md) | Backup and restore |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues and fixes |
| [docs/RUNBOOK.md](docs/RUNBOOK.md) | Operations runbook |
| [docs/UPGRADE.md](docs/UPGRADE.md) | Upgrade guide |

Full index: [docs/INDEX.md](docs/INDEX.md)

---

## Requirements

| Target | What you need |
|--------|---------------|
| Monitoring server | Docker Engine with the Compose plugin (`docker compose`) · SSH access |
| Monitored hosts | `iptables` (port 9100 is opened only to the monitoring server) · Docker at `/usr/bin/docker` (default method) or systemd (binary) |
| Ansible control node | ansible-core 2.12 or newer · Python 3 · SSH key access to all hosts |

Tested on Ubuntu 22.04, 24.04 and 26.04 with Docker Engine 29.9, Compose 5.6 and ansible-core 2.12, 2.14, 2.16, 2.18, 2.19 and 2.20. Ansible 2.9 fails on Ubuntu 24.04 targets, so it is not supported. To install Docker, follow the [Docker Engine install guide](https://docs.docker.com/engine/install/).

---

## Repository structure

```
monitoring-stack/
├── prometheus-grafana/     # Docker Compose stack (Prometheus, Grafana, Alertmanager, Blackbox)
├── ansible/                # Playbook + roles for full automated deployment
├── grafana-dashboards/     # Original dashboard JSON files
├── alerts/                 # Alertmanager routing config example
├── scripts/                # Backup and dashboard builder
├── fail2ban/               # fail2ban integration guide
├── docs/                   # 20 guides
└── INSTALLATION_GUIDE.md   # Getting started
```

---

## Contributing

PRs and issues are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

[MIT](LICENSE.md) — free for personal and commercial use.

The dashboard JSON files in `grafana-dashboards/json/` are original works included in this repository and covered by the same MIT license.

---

## Author

Built and maintained by [Airat](https://t.me/Airat71).
