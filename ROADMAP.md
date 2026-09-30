# Roadmap

## Done

- [x] Prometheus + Grafana + Alertmanager + Node Exporter (Docker Compose)
- [x] Blackbox Exporter — HTTP/TCP endpoint probes
- [x] fail2ban integration — ban events in Grafana
- [x] Ansible automation — one-command full deployment
- [x] Node Exporter on multiple hosts via Ansible
- [x] 7 pre-built Grafana dashboards (Node Exporter, Prometheus, Blackbox, Nginx, PostgreSQL, Redis, RabbitMQ)
- [x] 20 production-ready alert rules
- [x] Telegram + email alert routing
- [x] Automated backup script
- [x] 20 guides (deployment, security, operations, multi-server, runbook, troubleshooting)
- [x] Production checklist

## Planned

### Near-term
- [ ] Loki integration — log aggregation alongside metrics
- [ ] MySQL / MariaDB dashboard and alerts
- [ ] Docker container metrics (cAdvisor)
- [ ] Demo screencast — full deploy from zero to Grafana

### Later
- [ ] Kubernetes monitoring (kube-state-metrics + node-exporter DaemonSet)
- [ ] Grafana alerting v2 (replace Alertmanager for simpler setups)
- [ ] Ansible role for automatic Let's Encrypt + reverse proxy (Caddy)

## Contributing

PRs are welcome. If you have a dashboard or alert rule that's missing — open an issue or submit a PR.
