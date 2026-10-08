# MONITORING — Alerts and configuration

## Alert rules

The stack ships these alert rules in `prometheus-grafana/alerts.yml`:

- **Instance/Service:** InstanceDown, ServiceDown
- **Resources:** HighCPUUsage, HighCPUUsageCritical, HighMemoryUsage, DiskSpaceLow, DiskSpaceCritical, HighLoadAverage, FilesystemReadonly
- **Probes:** BlackboxProbeFailed
- **Self-monitoring:** PrometheusConfigReloadFailure, PrometheusNotConnectedToAlertmanager
- **fail2ban:** Fail2banHighAttackRate, Fail2banSocketDown (inactive until an exporter exposes `f2b_up`)
- **Optional:** PostgreSQLDown, RabbitMQDown, RedisDown (when those exporters are enabled)

## Alertmanager

- Config file: `alertmanager.yml` in the monitoring directory.
- **Receivers:** Telegram and/or Email. Set `telegram_bot_token`, `telegram_chat_id` (and SMTP vars if using email) in group_vars or vault.
- **Routing:** Critical alerts can go to a separate receiver; repeat_interval and group_interval are set in the template.

## Adding a custom alert

1. Edit `prometheus-grafana/alerts.yml` (or the copy Ansible places next to `prometheus.yml`).
2. Add a new rule under the appropriate group (or create a new group).
3. Reload Prometheus: `curl -X POST http://127.0.0.1:9090/-/reload`.
4. Optionally add a runbook URL in the rule's annotations.
