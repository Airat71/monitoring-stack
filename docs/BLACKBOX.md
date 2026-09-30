# Blackbox Exporter (PRO)

- **Purpose:** HTTP/HTTPS (and TCP/ICMP) probes — is the URL/endpoint up?
- **In PRO:** Blackbox container runs on the monitoring server; Prometheus scrapes it with `relabel_configs` to pass target URLs. Example target: `https://example.com`; add more in the Prometheus template or via group_vars.
- **Alerts:** `BlackboxProbeFailed` fires when `probe_success == 0` for 5m. Tune the target list and module (e.g. `http_2xx`) in the scrape config.
