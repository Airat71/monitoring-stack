# Blackbox Exporter

- **Purpose:** HTTP/HTTPS (and TCP/ICMP) probes — is the URL/endpoint up?
- Blackbox runs on the monitoring server. Prometheus scrapes it with `relabel_configs` and passes target URLs. The shipped target is `https://example.com`. Add more in `prometheus-grafana/prometheus.yml` or in the Ansible template.
- **Alerts:** `BlackboxProbeFailed` fires when `probe_success == 0` for 5m. Tune the target list and module (e.g. `http_2xx`) in the scrape config.

## Dashboard

The Blackbox dashboard (`grafana-dashboards/json/blackbox.json`) has two variables:

| Variable | Query | Description |
|----------|-------|-------------|
| `$job` | `label_values(probe_success, job)` | Selects which Prometheus job(s) to show. Supports multi-select and All. |
| `$instance` | `label_values(probe_success{job=~"$job"}, instance)` | Filters targets within the selected job(s). |

This means the dashboard works with **any job name** — you are not required to name your scrape job `blackbox`. If you have `job_name: website-monitoring` in your `prometheus.yml`, select it in the `$job` dropdown and the dashboard will populate.

## prometheus.yml — naming the scrape job

The template ships with `job_name: 'blackbox'` pointing at `https://example.com`. Replace the target with your own URL:

```yaml
- job_name: 'blackbox'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
        - https://your-domain.com
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

You can add as many targets as needed. Each `target` becomes one row in the dashboard.
