# Blackbox Exporter

- **Purpose:** HTTP/HTTPS (and TCP/ICMP) probes — is the URL/endpoint up?
- Blackbox runs on the monitoring server. Prometheus scrapes it with `relabel_configs` and passes target URLs. The shipped target is `https://example.com`. Add more in `prometheus-grafana/prometheus.yml` or in the Ansible template.
- **Alerts:** `BlackboxProbeFailed` fires when `probe_success == 0` for 5m. Tune the target list and module (e.g. `http_2xx`) in the scrape config.
