# Changelog

All notable changes to Monitoring Stack are documented here.

---

## [Unreleased]

### Changed
- Replaced imported Grafana.com dashboards with nine original dashboards in `grafana-dashboards/json/`. Panels are `gauge`, `stat`, and `timeseries`.
- `scripts/fetch-dashboards.sh` rebuilds those files from `scripts/build-dashboards.py` and no longer downloads JSON.
- Fail2ban dashboard queries use `f2b_up`, `f2b_jail_banned_current`, `f2b_jail_failed_current`, and `f2b_jail_banned_total` from `registry.gitlab.com/hctrdev/fail2ban-prometheus-exporter:0.10.3`. The exporter is still installed separately.
- `HighLoadAverage` now matches `node_load1` to the CPU count on `instance`. Extra target labels such as `hostname` no longer drop the series.
- Blackbox dashboard: added `$job` variable (`label_values(probe_success, job)`) so the dashboard works with any Prometheus job name, not just `job="blackbox"`. The `$instance` variable now filters within the selected job(s). All panel queries updated accordingly.
- Every dashboard has a `$job` variable as the primary filter. `$instance` cascades from `$job`. Hardcoded job names (`node-exporter`, `prometheus`, `nginx`, `postgresql`, `redis`, `rabbitmq`) removed from every panel query. Dashboards work with any job name configured in `prometheus.yml`.
- Removed `docs/PRODUCTION_CHECKLIST.md` (was in Russian, content covered by SECURITY.md and OPERATIONS.md).
- Added `grafana-dashboards/json/fail2ban.json` (`ms-fail2ban`): current bans, failed attempts, ban rate per jail, failed attempts per jail. Provisioned automatically; select the scrape job in `$job`. `docs/FAIL2BAN_ENHANCED.md` updated accordingly.

---

## [2.2.0] - 2026-10-04

### Fixed
- `docker compose up` in `prometheus-grafana/` starts the full stack: Prometheus, Grafana, Alertmanager, Node Exporter, and Blackbox. Grafana stays on host port 3001.
- Alert rules live in `prometheus-grafana/alerts.yml` (the names listed in `docs/MONITORING.md`). Ansible copies that file.
- Ansible reads `.env.example` from `prometheus-grafana/` and checks Prometheus config with `promtool --entrypoint`.
- Alertmanager starts without a Telegram token. The Telegram example uses a numeric `chat_id`.
- `docs/QUICK_START.md` uses Grafana port 3001.
- Provisioned dashboards use the Prometheus datasource uid `prometheus`.

### Security
- Compose does not start unless `GRAFANA_PASSWORD` is set. There is no default password.
- Image tags are pinned to current stable releases: Prometheus 3.14.0, Grafana 13.2.3, Alertmanager 0.34.1, Node Exporter 1.12.1, Blackbox Exporter 0.28.0.
- Published dashboard files cannot be overwritten from the Grafana UI.

---

## [2.1.0] - 2026-10-02

### Security
- Added `security.yml` workflow: TruffleHog `--only-verified` scans full git history on every push and PR (no path filters — secrets scan always runs)
- Separated secrets scanning from functional CI so it cannot be skipped by docs-only path filters

### CI
- Split CI into two workflows: `security.yml` (secrets) and `ci.yml` (linting/validation)
- Added `paths-ignore` to `ci.yml`: docs-only changes no longer trigger stack validation
- Added `concurrency: cancel-in-progress` to `security.yml`
- Added `permissions: contents: read` to all workflows (principle of least privilege)
- Added `release.yml`: auto-creates GitHub Release with generated notes on `v*.*.*` tags
- Added Dependabot config: weekly updates for GitHub Actions versions

### Changed
- Dashboard table in README now includes Source column with original grafana.com links and license attribution

---

## [2.0.0] - 2026-09-30

### Changed
- Open-sourced full stack: Ansible automation, 7 Grafana dashboards, 20 alert rules, 20 guides
- Dropped FREE/PRO split — everything is now available in one repository
- Rewrote README: community-first, clear Quick Start, architecture diagram
- Updated INSTALLATION_GUIDE to cover both Docker Compose and Ansible paths
- Replaced commercial docs (PURCHASE, SERVICES, FEATURES comparison) with technical guides
- Added docs/INDEX.md — full documentation navigation

### Added
- `ansible/` — Ansible playbook + roles for one-command deployment
- `grafana-dashboards/json/` — 7 pre-built dashboard JSON files
- `alerts/alertmanager.example.yml` — alert routing configuration template
- `scripts/backup-monitoring.sh` — automated backup with optional cron
- `scripts/fetch-dashboards.sh` — download dashboards from grafana.com
- `fail2ban/` — fail2ban integration guide
- docs: ALERTMANAGER, BACKUP, BLACKBOX, DASHBOARD_IMPORT, DEPLOYMENT,
  FAIL2BAN_ENHANCED, GRAFANA_DASHBOARDS, MONITORING, MULTI_SERVER,
  NGINX_MONITORING, OPERATIONS, POSTGRESQL_MONITORING, PRODUCTION_CHECKLIST,
  QUICK_REFERENCE, RABBITMQ_MONITORING, REDIS_MONITORING, RUNBOOK, SECURITY,
  TROUBLESHOOTING, UPGRADE

### CI
- Added `concurrency` group (cancel-in-progress on same ref)
- Added YAML validation job (Ansible configs + alerts)
- Added ShellCheck job for scripts/

---

## [1.0.2] - 2026-01-18

### 🎉 Production Ready Release - Open Core Launch

**Major Milestone:** First public release with Open Core model!

### Added
- ✅ **GitHub Release Structure** - Complete FREE version for public
- ✅ **Professional Screenshots** - 5 high-quality dashboard screenshots
- ✅ **Multipass Quick Demo** - 2-minute demo environment script
- ✅ **Complete Documentation** - 8 FREE docs + 20 PRO docs
- ✅ **Open Core Model** - FREE vs PRO version split
- ✅ **Purchase System** - Integrated sales documentation

### Enhanced
- ✨ **fail2ban Monitoring** - Enhanced with 5 jails + Prometheus integration
- ✨ **Grafana Dashboards** - Automated provisioning, no manual import
- ✨ **Documentation** - Professional structure with INDEX navigation
- ✨ **Security** - Comprehensive security guide (PRO)

### FREE Version Features
- 2 Basic Grafana dashboards
- 5 Basic alert rules
- Docker Compose deployment
- Basic documentation (README, QUICK_START, DEMO)
- Multipass demo script

### PRO Version Features (New!)
- 8 Professional dashboards (system, fail2ban, Prometheus, Blackbox, Nginx, PostgreSQL, RabbitMQ, Redis)
- 20 production-ready alert rules
- Ansible automation (one-command deployment)
- 20 comprehensive documentation guides
- Direct email support
- Lifetime updates

---

## [1.0.1] - 2026-01-17

### Improved
- 🔧 **Automated Maintenance** - Log rotation and disk management scripts
- 🔧 **Monitoring Reliability** - Health checks and cleanup automation

---

## [1.0.0] - 2026-01-12

### 🎊 First Production-Ready Release!

### Added
- ✅ **Complete Monitoring Stack** - Prometheus + Grafana + Alertmanager
- ✅ **fail2ban Integration** - 5 jails with real-time security monitoring
- ✅ **Production Documentation** - 20 comprehensive guides
- ✅ **Security Framework** - Complete security best practices guide
- ✅ **Operations Runbook** - Daily operations and emergency procedures
- ✅ **Ansible Automation** - One-command deployment across multiple servers

### Security
- 🔒 5 fail2ban jails (sshd, nginx-http-auth, nginx-limit-req, nginx-botsearch, recidive)
- 🔒 Prometheus metrics exporter for fail2ban statistics
- 🔒 Grafana security dashboard
- 🔒 SSH tunnel access (localhost-only binding policy)

---

## [0.9.0] - 2026-01-11

### Added
- ✅ Ansible automation (one-command full stack deployment)
- ✅ Node Exporter automated installation on multiple servers
- ✅ Idempotent playbooks (safe to run multiple times)
- ✅ Production-ready configuration management

---

## [0.8.0] - 2026-01-10

### Added
- ✅ Alertmanager integration
- ✅ 13 production alert rules
- ✅ Telegram and email notifications
- ✅ Alert grouping and smart routing

---

## [0.7.0] - 2025-12-29

### Added
- ✅ Backup automation scripts
- ✅ DEPLOYMENT.md - Complete deployment guide
- ✅ PROMETHEUS_SETUP.md - Prometheus configuration
- ✅ BACKUP.md - Backup procedures
- ✅ QUICK_REFERENCE.md - Command cheat sheet

### Enhanced
- 🔧 Docker Compose optimization
- 🔧 Resource usage optimization
- 🔧 Health check improvements

---

## [0.6.0] - 2025-12-15

### Added
- ✅ Grafana dashboard provisioning
- ✅ Automated datasource configuration
- ✅ Basic alert rules
- ✅ Node Exporter full dashboard

---

## [0.5.0] - 2025-12-01

### Added - Initial Prometheus Stack
- ✅ Prometheus server
- ✅ Grafana dashboards
- ✅ Node Exporter
- ✅ Blackbox Exporter
- ✅ Basic Docker Compose setup

---

## Release Statistics

**Total Releases:** 6 major versions
**Days in Development:** 48 days (Dec 1, 2025 - Jan 18, 2026)
**Total Documentation:** 30+ files
**Total Code:** 2000+ lines of Ansible/YAML/Scripts
**fail2ban Events Processed:** 321,060 attacks blocked

---

## Future

Ideas we may explore (no fixed dates or promises):
- Kubernetes / cloud integrations
- Log aggregation (Loki)
- Video walkthroughs

Existing PRO customers get all future updates as part of lifetime access.

---

## Version Naming Convention

We use [Semantic Versioning](https://semver.org/):

**MAJOR.MINOR.PATCH**

- **MAJOR:** Breaking changes, architecture changes
- **MINOR:** New features, backward compatible
- **PATCH:** Bug fixes, documentation updates

---

## How to Upgrade

### FREE Version
```bash
# Pull latest changes
git pull origin main

# Restart services
cd prometheus-grafana
docker compose pull
docker compose up -d
```

---

## Contributors

This project is maintained by [Airat](https://github.com/Airat71).

---

## Support

- GitHub Issues: [Report a bug](https://github.com/Airat71/monitoring-stack/issues)
- GitHub Discussions: [Ask questions](https://github.com/Airat71/monitoring-stack/discussions)

---

**Last Updated:** 2026-10-02
**Latest Version:** 2.1.0
