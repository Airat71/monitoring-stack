# fail2ban monitoring

fail2ban metrics are optional. The repository includes the alert rule, a Grafana dashboard (`grafana-dashboards/json/fail2ban.json`, uid `ms-fail2ban`), and this guide. It does not include a fail2ban exporter — install one separately (see Enable below).

## Components

- **fail2ban-exporter:** Exposes Prometheus metrics (`fail2ban_current_bans`, `fail2ban_banned_total`, `fail2ban_failed_current`). Use a community exporter such as `braedon/fail2ban-prometheus-exporter` or any exporter that exposes these metric names.
- **Prometheus:** Add a scrape job for the exporter (for example `localhost:9199` when the exporter runs on the monitoring server).
- **Dashboard:** `grafana-dashboards/json/fail2ban.json` — provisioned automatically. Select the scrape job in the `$job` dropdown. Shows current bans, failed attempts, ban rate per jail.
- **Alert:** `Fail2banHighAttackRate` in `prometheus-grafana/alerts.yml` fires when `increase(fail2ban_banned_total[5m]) > 10`.

## Jails (example)

- **sshd** — SSH brute-force
- **nginx-http-auth** — HTTP auth failures
- **nginx-limit-req** — rate limiting
- **recidive** — repeat offenders (long ban)

## Enable

1. Install fail2ban and the exporter on the target host.
2. Add the exporter to Compose or systemd, and add a scrape job to `prometheus.yml`.
3. Reload Prometheus: `curl -X POST http://127.0.0.1:9090/-/reload`.
