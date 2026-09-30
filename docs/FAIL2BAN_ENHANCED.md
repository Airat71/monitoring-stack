# fail2ban — Enhanced monitoring (PRO)

PRO includes optional **fail2ban** monitoring: metrics from fail2ban jails (bans, attack rate) and a Grafana dashboard.

## Components

- **fail2ban-exporter:** Exposes Prometheus metrics (e.g. `fail2ban_banned_total`, `fail2ban_jail_current_bans`). Use a community exporter (e.g. braedon/fail2ban-prometheus-exporter) or similar.
- **Prometheus:** Add a scrape job for the exporter (e.g. `localhost:9199` if exporter runs on the monitoring server).
- **Grafana:** PRO bundle includes a fail2ban dashboard JSON; provision it in `grafana/provisioning/dashboards`.

## Jails (example)

Common jails to monitor:

- **sshd** — SSH brute-force
- **nginx-http-auth** — HTTP auth failures
- **nginx-limit-req** — rate limiting
- **recidive** — repeat offenders (long ban)

## Alerts

- `Fail2banHighAttackRate` in `alerts-product.yml` fires when `increase(fail2ban_banned_total[5m]) > 10`. Tune threshold in group_vars or in the alert file.

## Enable in PRO

1. Install fail2ban and the exporter on the target host(s).
2. Set a variable (e.g. `deploy_fail2ban_exporter: true`) and add the exporter to docker-compose or as a systemd service.
3. Add the scrape job to the Prometheus template and the dashboard to Grafana provisioning.
