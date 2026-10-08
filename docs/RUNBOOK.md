# Runbook — Alert response

| Alert | What to check | Action |
|-------|----------------|--------|
| InstanceDown | Target reachable? Port 9100 open? | Restart node-exporter on target; check firewall and inventory. |
| HighCPUUsage | Top processes on host | Identify and tune or scale; see TROUBLESHOOTING. |
| HighMemoryUsage | Memory and swap on host | Free memory or add RAM; check for leaks. |
| DiskSpaceLow/Critical | Disk usage on host | Clean logs, rotate; expand disk or add storage. |
| BlackboxProbeFailed | URL reachable from monitoring server? | Fix target URL or network; check Blackbox config. |
| PrometheusConfigReloadFailure | prometheus.yml syntax | Fix config and reload; check Prometheus logs. |
| Fail2banHighAttackRate | fail2ban status and logs | Confirm jails; adjust bantime if needed. |
| Fail2banSocketDown | `f2b_up` and the socket path | Prometheus can show the target UP while `f2b_up` is 0. Confirm `/var/run/fail2ban/fail2ban.sock` is a socket and the container mounts the directory `/var/run/fail2ban`. |

Detailed steps: **TROUBLESHOOTING.md**.
