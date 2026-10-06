# Changelog

All notable changes to this project are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- `grafana-dashboards/json/fail2ban.json` (`ms-fail2ban`): 7 panels — current bans (sparkline), failed attempts (sparkline), attacks last 24 h (sparkline), total attacks blocked (cumulative counter), ban rate per jail, failed attempts per jail, and active bans per jail. Provisioned automatically; select the exporter scrape job in `$job`.
- `scripts/build-dashboards.py`: `stat()` accepts an optional `graph_mode` parameter (`"area"` for sparklines, `"none"` for raw counters).

### Changed
- All nine dashboards replaced with original JSON in `grafana-dashboards/json/`. Source of truth is `scripts/build-dashboards.py`; `scripts/fetch-dashboards.sh` regenerates them instead of downloading from grafana.com.
- Every dashboard has a `$job` variable as the primary filter; `$instance` cascades from `$job`. Hardcoded job names removed from all panel queries. Dashboards work with any job name configured in `prometheus.yml`.
- Fail2ban dashboard metrics use `f2b_*` naming (`f2b_up`, `f2b_jail_banned_current`, `f2b_jail_failed_current`, `f2b_jail_banned_total`) matching `hctrdev/fail2ban-prometheus-exporter`.
- `HighLoadAverage` alert matches `node_load1` to the CPU count on `instance`; extra target labels no longer drop the series.
- Nginx, PostgreSQL, Redis, and RabbitMQ panel descriptions no longer reference fixed job names.
- `Fail2banHighAttackRate` alert expression updated to `increase(f2b_jail_banned_total[5m]) > 10`.

### Removed
- `docs/PRODUCTION_CHECKLIST.md` — content covered by SECURITY.md and OPERATIONS.md.

---

## [2.2.0] - 2026-10-04

### Fixed
- `docker compose up` in `prometheus-grafana/` starts the full stack: Prometheus, Grafana, Alertmanager, Node Exporter, and Blackbox. Grafana stays on host port 3001.
- Alert rules live in `prometheus-grafana/alerts.yml`. Ansible copies that file.
- Ansible reads `.env.example` from `prometheus-grafana/` and validates the Prometheus config with `promtool --entrypoint`.
- Alertmanager starts without a Telegram token; the example config uses a numeric `chat_id`.
- `docs/QUICK_START.md` uses Grafana port 3001.
- Provisioned dashboards use the Prometheus datasource UID `prometheus`.

### Security
- Docker Compose refuses to start unless `GRAFANA_PASSWORD` is set. No default password.
- Image tags pinned to stable releases: Prometheus 3.14.0, Grafana 13.2.3, Alertmanager 0.34.1, Node Exporter 1.12.1, Blackbox Exporter 0.28.0.
- `allowUiUpdates: false` in Grafana provisioning; dashboard JSON cannot be overwritten from the UI.

---

## [2.1.0] - 2026-10-02

### Added
- `security.yml` workflow: TruffleHog `--only-verified` scans full git history on every push and PR with no path filters — secrets scan always runs.
- `release.yml` workflow: auto-creates a GitHub Release with generated notes on `v*.*.*` tags.
- Dependabot config: weekly updates for GitHub Actions versions.
- `paths-ignore` in `ci.yml`: docs-only changes skip stack validation.
- `concurrency: cancel-in-progress` in both CI workflows.
- `permissions: contents: read` on all workflows (principle of least privilege).

### Changed
- CI split into two workflows: `security.yml` (secrets scan) and `ci.yml` (linting and validation). Separating them ensures secrets scanning cannot be bypassed by path filters.
- Dashboard table in README includes a Source column with grafana.com links and license attribution.

---

## [2.0.0] - 2026-09-30

### Added
- `ansible/` — Ansible playbook and roles for one-command deployment.
- `grafana-dashboards/json/` — 7 pre-built dashboard JSON files, provisioned automatically.
- `alerts/alertmanager.example.yml` — alert routing configuration template.
- `scripts/backup-monitoring.sh` — automated backup script with optional cron setup.
- `scripts/fetch-dashboards.sh` — dashboard management script.
- `fail2ban/` — fail2ban integration guide and configuration.
- 20 documentation guides: ALERTMANAGER, BACKUP, BLACKBOX, DASHBOARD_IMPORT, DEPLOYMENT, FAIL2BAN_ENHANCED, GRAFANA_DASHBOARDS, MONITORING, MULTI_SERVER, NGINX_MONITORING, OPERATIONS, POSTGRESQL_MONITORING, QUICK_REFERENCE, RABBITMQ_MONITORING, REDIS_MONITORING, RUNBOOK, SECURITY, TROUBLESHOOTING, UPGRADE, INDEX.
- CI: YAML validation job for Ansible configs and alert rules; ShellCheck job for `scripts/`.
- CI: `concurrency` group with cancel-in-progress.

### Changed
- Full stack open-sourced: Ansible, dashboards, alert rules, and all documentation in one repository.
- README rewritten: community-first structure, Quick Start section, architecture diagram.
- INSTALLATION_GUIDE covers both Docker Compose and Ansible deployment paths.

### Removed
- Commercial documentation (PURCHASE, SERVICES, FEATURES comparison).

---

## [1.0.2] - 2026-01-18

### Added
- Dashboard screenshots.
- Multipass quick-demo script.

### Changed
- fail2ban monitoring: 5 jails configured, Prometheus exporter integrated.
- Grafana dashboards use automated provisioning — no manual import required.

---

## [1.0.1] - 2026-01-17

### Added
- Log rotation and disk management scripts.
- Health check automation.

---

## [1.0.0] - 2026-01-12

### Added
- Initial production stack: Prometheus, Grafana, Alertmanager via Docker Compose.
- fail2ban integration: 5 jails (sshd, nginx-http-auth, nginx-limit-req, nginx-botsearch, recidive) with Prometheus metrics exporter.
- Ansible playbook for multi-server deployment.
- Operations runbook and security guide.

### Security
- fail2ban Prometheus exporter exposes ban and failure counts per jail.
- Grafana binds to localhost only; access via SSH tunnel.

---

## [0.9.0] - 2026-01-11

### Added
- Ansible automation for full stack deployment.
- Automated Node Exporter installation on multiple servers.
- Idempotent playbooks.

---

## [0.8.0] - 2026-01-10

### Added
- Alertmanager with 13 alert rules.
- Telegram and email notification channels.
- Alert grouping and routing.

---

## [0.7.0] - 2025-12-29

### Added
- Backup automation scripts.
- DEPLOYMENT.md, BACKUP.md, QUICK_REFERENCE.md.

### Changed
- Docker Compose configuration optimised for production resource usage.

---

## [0.6.0] - 2025-12-15

### Added
- Grafana dashboard provisioning with automated datasource configuration.
- Basic alert rules.
- Node Exporter full dashboard.

---

## [0.5.0] - 2025-12-01

### Added
- Initial stack: Prometheus, Grafana, Node Exporter, Blackbox Exporter, Docker Compose setup.
