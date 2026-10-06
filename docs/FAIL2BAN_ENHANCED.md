# fail2ban monitoring

fail2ban metrics are optional. The repository includes the alert rule, a Grafana dashboard (`grafana-dashboards/json/fail2ban.json`, uid `ms-fail2ban`), and this guide. It does not include a fail2ban exporter — install one separately (see Enable below).

## Components

- **fail2ban-exporter:** Exposes Prometheus metrics `f2b_up`, `f2b_jail_banned_current`, `f2b_jail_failed_current`, and `f2b_jail_banned_total`. The image is `registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3`. It listens on port 9191.
- **Prometheus:** Add a scrape job for the exporter. The job name can be anything. Example target: `fail2ban-exporter:9191`.
- **Dashboard:** `grafana-dashboards/json/fail2ban.json` — provisioned automatically. Select the scrape job in the `$job` dropdown. Panels: current bans (sparkline), failed attempts (sparkline), attacks last 24 h (sparkline), total attacks blocked (cumulative since restart), ban rate per jail, failed attempts per jail, active bans per jail.
- **Alert:** `Fail2banHighAttackRate` in `prometheus-grafana/alerts.yml` fires when `increase(f2b_jail_banned_total[5m]) > 10`.

## Jails (example)

- **sshd** — SSH brute-force
- **nginx-http-auth** — HTTP auth failures
- **nginx-limit-req** — rate limiting
- **recidive** — repeat offenders (long ban)

## Enable

1. Install fail2ban and the exporter on the target host.
2. Add the exporter to Compose or systemd, and add a scrape job to `prometheus.yml`.
3. Reload Prometheus: `curl -X POST http://127.0.0.1:9090/-/reload`.
