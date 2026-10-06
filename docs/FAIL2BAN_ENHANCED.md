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

### Option A — systemd (simplest)

Run the exporter as a systemd service on the target host. Suitable when Prometheus scrapes the host directly.

```bash
docker run -d \
  --name fail2ban-exporter \
  --restart unless-stopped \
  -p 127.0.0.1:9191:9191 \
  -v /var/run/fail2ban/fail2ban.sock:/var/run/fail2ban/fail2ban.sock:ro \
  --group-add $(getent group fail2ban-export | cut -d: -f3) \
  --read-only \
  --security-opt no-new-privileges:true \
  registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3
```

Then add the scrape job to `prometheus.yml` and reload:

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

### Option B — Docker Compose (production, least-privilege)

Running the exporter as `user: root` is a security anti-pattern (violates CIS Docker Benchmark). The correct approach is `group_add` with a dedicated group that has read-write access to the fail2ban socket.

#### Step 1 — Create a dedicated system group on the host

```bash
sudo groupadd -r fail2ban-export
getent group fail2ban-export   # note the GID, e.g. 988
```

#### Step 2 — systemd drop-in: set socket group on fail2ban startup

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

#### Step 3 — Add to docker-compose.yml

Replace `988` with the actual GID from Step 1.

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

#### Step 4 — Add scrape job to prometheus.yml

```yaml
- job_name: 'fail2ban'
  static_configs:
    - targets: ['fail2ban-exporter:9191']
      labels:
        instance: 'your-server'
  scrape_interval: 30s
  scrape_timeout: 10s
```

#### Step 5 — Start and reload

```bash
docker compose up -d fail2ban-exporter
curl -X POST http://127.0.0.1:9090/-/reload
```
