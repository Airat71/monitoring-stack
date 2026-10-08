# TROUBLESHOOTING

## InstanceDown

- **Cause:** Target not reachable (node-exporter down, network, firewall).
- **Check:** From the monitoring server, `curl http://<inventory-ip>:9100/metrics`. On an extra host the exporter listens on that IP, not on `127.0.0.1`. On the monitoring server itself, Prometheus uses the Docker name `node-exporter:9100`.
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
- **Fix:** Reduce `prometheus_retention` (e.g. 15d); limit dashboard refresh; add more resources to the monitoring host.

## Blackbox probe failed

- **Cause:** Target URL unreachable (DNS, HTTP error, timeout).
- **Check:** From monitoring server: `curl -I <target_url>`. Blackbox exporter logs.
- **Fix:** Fix target URL or network; adjust Blackbox module (e.g. http_2xx) and timeouts.
