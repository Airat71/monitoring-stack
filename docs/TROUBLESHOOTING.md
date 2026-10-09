# TROUBLESHOOTING

## InstanceDown

- **Cause:** Target not reachable (node-exporter down, network, firewall).
- **Check:** From the monitoring server, `curl http://<inventory-ip>:9100/metrics`. On an extra host the exporter listens on that IP, not on `127.0.0.1`, and iptables drops other sources. A timeout from the monitoring server usually means `node_exporter_allow_from` is not the address that host sees. On the monitoring server itself, Prometheus uses the Docker name `node-exporter:9100`.
- **Fix:** Restart node-exporter on the target; check firewall and inventory `ansible_host`.

## Grafana "No data"

- **Cause:** Prometheus not scraped yet, or wrong datasource/variable.
- **Check:** Prometheus → Status → Targets — is the job UP? Grafana → Connections → Data sources — is Prometheus URL correct?
- **Fix:** Wait for scrape interval; fix Prometheus target or Grafana datasource.

## Alertmanager not receiving

- **Cause:** Wrong Telegram token/chat_id or SMTP config; or Prometheus not pointing to Alertmanager.
- **Check:** `prometheus.yml` has `alerting.alertmanagers` with correct target. Alertmanager logs: `docker compose logs alertmanager`.
- **Fix:** Set Telegram/SMTP in vault or .env; reload Prometheus and Alertmanager.

## High memory/CPU on monitoring server

- **Cause:** Long retention, too many targets, or heavy queries.
- **Fix:** Reduce retention; limit dashboard refresh; add more resources to the monitoring host. With Ansible, set `prometheus_retention` (e.g. `15d`). With plain Docker Compose, change `--storage.tsdb.retention.time=30d` in `prometheus-grafana/docker-compose.yml` and run `docker compose up -d prometheus`.

## Fail2banSocketDown or an empty Fail2ban dashboard

- **Cause:** The exporter is not scraped, or it cannot open the fail2ban socket. A missing socket file that was mounted directly becomes a directory, and fail2ban then fails to start.
- **Check:** `test -S /var/run/fail2ban/fail2ban.sock` and `curl -s http://127.0.0.1:9191/metrics | grep '^f2b_up'`. `f2b_up 0` with a Prometheus target of UP means the process is running and the socket call failed.
- **Fix:** Mount `/var/run/fail2ban` (the directory), scrape `fail2ban-exporter:9191` from the Compose network, and reload Prometheus. Do not chmod the socket. If `f2b_up` stays 0 after `systemctl restart fail2ban`, the container holds a deleted directory: add the `RuntimeDirectoryPreserve=yes` drop-in and restart the exporter once. See FAIL2BAN_ENHANCED.md.

## Blackbox probe failed

- **Cause:** Target URL unreachable (DNS, HTTP error, timeout).
- **Check:** From monitoring server: `curl -I <target_url>`. Blackbox exporter logs.
- **Fix:** Fix target URL or network; adjust Blackbox module (e.g. http_2xx) and timeouts.
