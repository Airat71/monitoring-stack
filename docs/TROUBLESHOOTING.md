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

- **Cause:** Wrong Telegram token or `chat_id`, an invalid `email_configs` block, or Prometheus not pointing to Alertmanager.
- **Check:** `prometheus.yml` has `alerting.alertmanagers` with correct target. Alertmanager logs: `docker compose logs alertmanager`.
- **Fix:** Set `telegram_bot_token` and `telegram_chat_id` in Ansible vault, or edit `alertmanager.yml` for Telegram or email. `.env` holds only `GRAFANA_PASSWORD`. Then run `docker compose restart alertmanager` and reload Prometheus.

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

## Port already in use, or a container stuck in Created

- **Cause:** Another process holds one of the published ports (9090, 3001, 9093, 9100, 9115) on `127.0.0.1`. `docker compose up -d` stops with `failed to bind host port ... address already in use` but leaves the other containers running; the ones that did not start stay in `Created`. On Docker 29.1 and 29.9 a second `up -d` can then show a container as `Up (healthy)` that has no network and no published port: its healthcheck queries `localhost` inside the container and still passes. Not seen on Docker 27.5.1; 28.x was not tested.
- **Check:** `docker compose ps -a` (plain `ps` hides `Created` containers). `sudo ss -ltnp | grep -E ':(9090|3001|9093|9100|9115)\b'` shows who owns each port. `bash scripts/smoke-check.sh` fails on such a stack.
- **Fix:** Stop the other process, or change the host side of the port in `docker-compose.yml` (for example `127.0.0.1:9091:9090`; `smoke-check.sh` then needs `PROMETHEUS_URL`, `ALERTMANAGER_URL` or `GRAFANA_URL`; the host ports 9100 and 9115 are not used by it, the targets are checked through Prometheus). That edit changes a tracked file: run `git stash` before `git checkout <tag>` for an upgrade and `git stash pop` after it. Then run `docker compose down` and `docker compose up -d`. Run `down` first: re-running `up -d` over a half-started stack is what leaves the unreachable "healthy" container.

## Grafana rejects the password from `.env`

- **Cause:** Grafana reads `GRAFANA_PASSWORD` only when it creates its database in the `grafana-data` volume. Changing `.env` later, or installing over an old volume, keeps the old password.
- **Check:** `curl -s -o /dev/null -w '%{http_code}\n' -u 'admin:<password>' http://127.0.0.1:3001/api/org` returns `401`.
- **Fix:** Reset it in the running container and put the same value in `.env`. Read the password into a variable so it stays out of your shell history (it is still visible in the process list while the command runs):
  ```bash
  read -rs NEW_PASSWORD
  docker compose exec -T grafana grafana cli admin reset-admin-password "$NEW_PASSWORD"
  ```
  Or recreate the volume (next section), which also removes everything created in the Grafana UI.

## Dashboards missing or old after an upgrade

- **Cause:** Upgrading from v2.2.0 to v2.3.0 over an existing Grafana volume. `nginx.json`, `postgresql.json` and `redis.json` kept their file names but got new dashboard UIDs. Grafana 13.2.3 does not save them, keeps the v2.2.0 versions and the four old dashboards whose files were removed. `up -d` still exits 0; the only sign is the Grafana log.
- **Check:** `docker compose logs grafana | grep "failed to save dashboard"`. In this upgrade Grafana lists 13 dashboards instead of 9.
- **Fix:** Recreate the Grafana volume (commands run in `prometheus-grafana/`; checked on the Docker Compose path only, the Ansible path was not tested). This deletes Grafana's own database (users, preferences, anything made in the UI); the dashboards come back from the files. Prometheus and Alertmanager data are not touched.
  ```bash
  VOLUME=$(docker inspect grafana --format '{{range .Mounts}}{{.Name}}{{end}}')
  echo "$VOLUME"   # must print only the Grafana data volume, for example prometheus-grafana_grafana-data
  docker compose stop grafana
  docker compose rm -f grafana
  docker volume rm "$VOLUME"
  docker compose up -d grafana
  ```

## Ansible fails on a host that already runs a stack or a Node Exporter

- **Cause:** Option A (Compose in `prometheus-grafana/`) and Option B (playbook) create containers with the same names. The playbook then fails at "Start monitoring stack" with `Conflict. The container name "/..." is already in use`. A Node Exporter already listening on 9100 (for example `prometheus-node-exporter` from apt) gives `failed to bind host port 127.0.0.1:9100`. After the failure the playbook leaves a network, three volumes (`monitoring_*-data`) and `/opt/monitoring` behind. On Docker 29.9.2 (the only version tested) a second playbook run after the 9100 error can finish with `failed=0` while the `node-exporter` target is down.
- **Check:** After every playbook run, on the monitoring server: `curl -fsS http://127.0.0.1:9090/api/v1/targets | jq -e '(.data.activeTargets | length > 0) and all(.data.activeTargets[]; .health == "up")'` prints `true` when there are targets and all of them are up; no output, an error or `false` means they are not (`jq -r '.data.activeTargets[] | select(.health != "up") | .scrapeUrl'` lists the ones that are down). `docker ps -a` shows the container names; `sudo ss -ltnp | grep ':9100'` shows who owns 9100.
- **Fix:** Use one option per host. Stop the Compose stack (`docker compose down` in `prometheus-grafana`) or the other Node Exporter (`sudo systemctl disable --now prometheus-node-exporter`, only if nothing else scrapes it). If the failed run was the first install on this host, remove what it left with `cd /opt/monitoring && sudo docker compose down -v` and run the playbook again. `-v` deletes that stack's volumes: if the host ran this stack before, use `docker compose down` without `-v` and back up first ([BACKUP.md](BACKUP.md)).
