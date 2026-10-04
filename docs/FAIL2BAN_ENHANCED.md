# fail2ban monitoring

fail2ban metrics are optional. The repository includes the alert rule and this guide. It does not include a fail2ban exporter or a fail2ban dashboard.

## Components

- **fail2ban-exporter:** Exposes Prometheus metrics (`fail2ban_banned_total`, `fail2ban_jail_current_bans`). Use a community exporter such as `braedon/fail2ban-prometheus-exporter`.
- **Prometheus:** Add a scrape job for the exporter (for example `localhost:9199` when the exporter runs on the monitoring server).
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
