# fail2ban monitoring

fail2ban metrics are optional. The repository includes alert rules, a Grafana dashboard (`grafana-dashboards/json/fail2ban.json`, uid `ms-fail2ban`), and this guide. It does not install fail2ban or the exporter. Add the exporter with the steps below.

## Components

- **Exporter image:** `registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3`. It listens on port 9191. This image has no `USER` instruction, so the process runs as **uid 0**. `group_add` does not change the uid. Do not describe this container as non-root.
- **What it reads:** the fail2ban control socket, not log files. The socket accepts the same commands as `fail2ban-client` (status, ban, unban, stop). A mount of the socket is not a read-only view of the logs.
- **Metrics:** counts and the jail name (`f2b_up`, `f2b_jail_banned_current`, `f2b_jail_failed_current`, `f2b_jail_banned_total`, plus config gauges). Banned IP addresses are not metric labels.
- **Prometheus:** scrape `fail2ban-exporter:9191` on the Compose network `monitoring-net`. The job name can be anything.
- **Dashboard:** select that job in the `$job` dropdown.
- **Alerts:** `Fail2banHighAttackRate` fires when `increase(f2b_jail_banned_total[5m]) > 10`. `Fail2banSocketDown` fires when `f2b_up == 0` for 5 minutes. Both stay inactive until the exporter is scraped.

## Do not weaken the socket

The default socket is `srw-------` and owned by root. uid 0 inside the container can open it. Do not `chgrp` or `chmod g+rw` the socket for this image. A group-writable socket gives every member of that group the full control API, and this image does not need that change.

Do not mount the socket **file**. If the file is missing when the container is created, Docker creates a directory at that path and fail2ban can no longer bind its socket. Mount the runtime **directory** instead. After `systemctl restart fail2ban` the new socket appears in that directory.

## Jails (example)

- **sshd** — SSH brute-force
- **nginx-http-auth** — HTTP auth failures
- **nginx-limit-req** — rate limiting
- **recidive** — repeat offenders (long ban)

## Enable on this Compose stack

Prometheus in `prometheus-grafana/docker-compose.yml` runs on `monitoring-net`. It cannot open the host's `127.0.0.1:9191`, and this stack does not define `host.docker.internal`. Scrape the exporter by its Compose service name.

### 1. Confirm the socket exists

```bash
test -S /var/run/fail2ban/fail2ban.sock && ls -l /var/run/fail2ban/fail2ban.sock
```

Stop if that path is missing or is a directory. Install and start fail2ban first. Expected mode is owner-only, for example `srw------- root root`.

### 2. Add the service

`read_only`, `no-new-privileges`, the localhost port, and the memory limit are the controls this image actually honors. They do not drop uid 0.

```yaml
fail2ban-exporter:
  image: registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3
  container_name: fail2ban-exporter
  restart: unless-stopped
  ports:
    - "127.0.0.1:9191:9191"
  volumes:
    - /var/run/fail2ban:/var/run/fail2ban:ro
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

### 3. Scrape it from Prometheus

Add this job to `prometheus.yml`:

```yaml
- job_name: 'fail2ban'
  static_configs:
    - targets: ['fail2ban-exporter:9191']
      labels:
        instance: 'your-server'
  scrape_interval: 30s
  scrape_timeout: 10s
```

### 4. Start and check

```bash
docker compose up -d fail2ban-exporter
curl -s http://127.0.0.1:9191/metrics | grep '^f2b_up'
curl -X POST http://127.0.0.1:9090/-/reload
```

`f2b_up` must be `1`. The Prometheus target can show UP while `f2b_up` is `0`: the process is serving metrics but cannot use the socket. `Fail2banSocketDown` covers that case. `docker exec fail2ban-exporter id` reports uid 0 with this image.

In `docker logs fail2ban-exporter`, a successful start prints the fail2ban version. An IP list appears in those logs only when the exporter cannot parse a socket reply.

## Standalone container

Use this only when the program that scrapes metrics runs on the host and opens `127.0.0.1:9191` itself. The Prometheus service in this repository does not.

```bash
test -S /var/run/fail2ban/fail2ban.sock
docker run -d \
  --name fail2ban-exporter \
  --restart unless-stopped \
  -p 127.0.0.1:9191:9191 \
  -v /var/run/fail2ban:/var/run/fail2ban:ro \
  --read-only \
  --security-opt no-new-privileges:true \
  registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3
```

Scrape `127.0.0.1:9191` from the host. Do not point a containerized Prometheus at `host.docker.internal:9191`: the published port is bound to host loopback, and `host.docker.internal` is a bridge address.
