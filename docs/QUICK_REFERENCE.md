# QUICK REFERENCE — PRO

## Ports (default)

| Service        | Port  | Binding    |
|----------------|-------|------------|
| Prometheus     | 9090  | 127.0.0.1  |
| Grafana        | 3001  | 127.0.0.1  |
| Alertmanager   | 9093  | 127.0.0.1  |
| Node Exporter  | 9100  | 127.0.0.1  |
| Blackbox       | 9115  | 127.0.0.1  |

## Commands

```bash
# Run playbook
ansible-playbook -i inventory.yml playbook.yml

# Restart stack (on server)
cd /opt/monitoring && docker compose restart

# Reload Prometheus
curl -X POST http://127.0.0.1:9090/-/reload

# SSH tunnel to Grafana
ssh -L 3001:127.0.0.1:3001 user@monitoring-server
# Then open http://localhost:3001
```

## URLs (local after tunnel)

- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

## Variables (group_vars)

- `include_nginx`, `include_postgresql`, `include_redis`, `include_rabbitmq` — optional services
- `monitoring_install_dir` — path on server (default `/opt/monitoring`)
- `deploy_alertmanager`, `deploy_blackbox` — enable/disable components
- `prometheus_image`, `grafana_image`, etc. — pinned image tags (production)
- `prometheus_memory_limit`, `grafana_memory_limit` — resource limits
- `telegram_bot_token`, `telegram_chat_id` — for Alertmanager (use vault)

See **PRODUCTION_CHECKLIST.md** for production readiness.
