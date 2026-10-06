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

Running the exporter as `user: root` violates the principle of least privilege (CIS Docker Benchmark). The correct approach uses a dedicated group with socket access.

### Step 1 — Host setup (required once, for all deployment options)

Create a dedicated system group and configure fail2ban to grant it access to the socket on startup.

```bash
sudo groupadd -r fail2ban-export
getent group fail2ban-export   # note the GID, e.g. 988
```

Create a systemd drop-in that sets socket permissions after fail2ban starts:

```bash
sudo mkdir -p /etc/systemd/system/fail2ban.service.d
sudo tee /etc/systemd/system/fail2ban.service.d/socket-group.conf > /dev/null << 'EOF'
[Service]
ExecStartPost=-/bin/sh -c 'i=0; while [ ! -S /var/run/fail2ban/fail2ban.sock ] && [ $i -lt 20 ]; do sleep 0.5; i=$((i+1)); done; chgrp fail2ban-export /var/run/fail2ban/fail2ban.sock && chmod g+rw /var/run/fail2ban/fail2ban.sock'
EOF
sudo systemctl daemon-reload && sudo systemctl restart fail2ban
```

Verify:

```bash
ls -la /var/run/fail2ban/fail2ban.sock
# srwxrw---- 1 root fail2ban-export 0 ... fail2ban.sock
```

The `-` prefix on `ExecStartPost` means a non-zero exit will not fail the fail2ban service. The loop waits up to 10 seconds for the socket to appear before setting permissions.

### Option A — docker run (standalone)

Suitable when the exporter runs on a host that Prometheus scrapes directly (not inside the same Compose stack).

Replace `988` with the GID from Step 1.

```bash
docker run -d \
  --name fail2ban-exporter \
  --restart unless-stopped \
  -p 127.0.0.1:9191:9191 \
  -v /var/run/fail2ban/fail2ban.sock:/var/run/fail2ban/fail2ban.sock:ro \
  --group-add 988 \
  --read-only \
  --security-opt no-new-privileges:true \
  registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3
```

Add the scrape job to `prometheus.yml` and reload:

```yaml
- job_name: 'fail2ban'
  static_configs:
    - targets: ['host.docker.internal:9191']
      labels:
        instance: 'your-server'
  scrape_interval: 30s
  scrape_timeout: 10s
```

```bash
curl -X POST http://127.0.0.1:9090/-/reload
```

### Option B — Docker Compose (integrated stack)

Add the service to your `docker-compose.yml`. Replace `988` with the GID from Step 1.

```yaml
fail2ban-exporter:
  image: registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3
  container_name: fail2ban-exporter
  restart: unless-stopped
  ports:
    - "127.0.0.1:9191:9191"
  volumes:
    - /var/run/fail2ban/fail2ban.sock:/var/run/fail2ban/fail2ban.sock:ro
  group_add:
    - "988"
  read_only: true
  security_opt:
    - no-new-privileges:true
  networks:
    - monitoring-net
  deploy:
    resources:
      limits:
        memory: 32M
```

Add the scrape job to `prometheus.yml`:

```yaml
- job_name: 'fail2ban'
  static_configs:
    - targets: ['fail2ban-exporter:9191']
      labels:
        instance: 'your-server'
  scrape_interval: 30s
  scrape_timeout: 10s
```

Start and reload:

```bash
docker compose up -d fail2ban-exporter
curl -X POST http://127.0.0.1:9090/-/reload
```
