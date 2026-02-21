# Which Dashboards Load and What If Nginx/PostgreSQL Are Missing (PRO)

Short reference for PRO: list of dashboards, data sources, and behavior when optional services (Nginx, PostgreSQL, Redis, RabbitMQ) are not present.

---

## 1. Dashboards Included (PRO)

The PRO bundle and deployed stack include **all 8 dashboards** from the `dashboards/` folder:

| # | File | Purpose |
|---|------|---------|
| 1 | node-exporter-full | System metrics (CPU, RAM, disk, network) |
| 2 | prometheus-stats | Prometheus self-monitoring |
| 3 | fail2ban-monitoring | fail2ban security monitoring |
| 4 | blackbox-exporter | Website/URL checks (availability, TTFB) |
| 5 | nginx-monitoring | Nginx metrics |
| 6 | postgresql-database | PostgreSQL metrics |
| 7 | rabbitmq-overview | RabbitMQ metrics |
| 8 | redis-overview | Redis metrics |

Grafana loads all JSON dashboards from one folder; there is no conditional “load only if Nginx exists” — **all 8 dashboards are always loaded**.

---

## 2. Where Data Comes From

Data depends on **Prometheus scrape jobs**, controlled by variables in `group_vars` (e.g. `monitoring_servers_product.yml`):

- **Node Exporter, Prometheus, Blackbox, fail2ban** — enabled by default in the product (one node-exporter host, one example URL, fail2ban if enabled on server).
- **Nginx** — only if `include_nginx: true` (default in product: **false**).
- **PostgreSQL** — only if `include_postgresql_*` is true (default: **false**).
- **Redis** — only if `include_redis_n8n: true` (default: **false**).
- **RabbitMQ** — only if `include_rabbitmq_taiga: true` (default: **false**).

So in the **default product build**, metrics exist only for Node Exporter, Prometheus, Blackbox, and fail2ban.

---

## 3. If the Client Has No Nginx or PostgreSQL

- **Nginx, PostgreSQL, Redis, and RabbitMQ dashboards still load** — they appear in the Grafana dashboard list.
- Panels query metrics (e.g. `nginx_up{job="nginx"}`, `pg_stat_database_*`). With no corresponding Prometheus targets, queries return **no data**.
- **In the UI you see “No data”** in those panels. Grafana does not error; dashboards do not crash.

The client can ignore these dashboards until they install the service, or enable the service (install exporter, set the right `include_*: true`, re-run the playbook) so jobs and data appear. PRO docs include guides (e.g. HOWTO_ADD_SERVER, NGINX_DASHBOARD, POSTGRESQL_DASHBOARD).

---

## 4. Summary (Minimal Client: No Nginx, PostgreSQL, Redis, RabbitMQ)

| Dashboard | Loaded? | Data in default product? |
|-----------|---------|---------------------------|
| Node Exporter Full | Yes | Yes |
| Prometheus Stats | Yes | Yes |
| Blackbox Exporter | Yes | Yes (example.com) |
| fail2ban Monitoring | Yes | Yes if fail2ban enabled on server |
| Nginx Monitoring | Yes | No → “No data” |
| PostgreSQL Database | Yes | No → “No data” |
| RabbitMQ Overview | Yes | No → “No data” |
| Redis Overview | Yes | No → “No data” |

**Bottom line:** All 8 dashboards load; if Nginx, PostgreSQL, Redis, or RabbitMQ are not present, those dashboards show empty panels (“No data”) without errors.
