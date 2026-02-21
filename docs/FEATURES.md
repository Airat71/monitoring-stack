# Features Comparison: FREE vs PRO

Complete comparison of features between FREE and PRO versions.

---

## 🎯 Quick Summary

| | FREE Version | PRO Version |
|---|---|---|
| **Price** | $0 | **$40** one-time |
| **Deployment Time** | 2-4 hours manual setup | **10 minutes** automated |
| **Dashboards** | 2 basic | **8 professional** |
| **Alerts** | 5 basic rules | **20 production-ready** |
| **Documentation** | Basic README | **20 detailed guides** |
| **Support** | Community only | **Direct email** |
| **Updates** | Manual | **Automated scripts** |

**[👉 Get PRO Version - $40](PURCHASE.md)**

---

## 📊 Detailed Feature Comparison

### 1. Deployment & Installation

| Feature | FREE | PRO |
|---------|------|-----|
| **Installation Method** | Manual Docker Compose | ✅ Ansible automation (1 command) |
| **Setup Time** | 2-4 hours | ✅ **10 minutes** |
| **Node Exporter Installation** | Manual on each server | ✅ Automated via playbook |
| **Configuration Management** | Manual YAML editing | ✅ Template-based automation |
| **Multi-server Setup** | Manual config for each | ✅ Auto-discovery from inventory |
| **Docker Installation** | You handle it | ✅ Automated by playbook |
| **Service Configuration** | Manual | ✅ Idempotent playbooks |
| **Health Checks** | Basic | ✅ Advanced with auto-restart |

---

### 2. Dashboards & Visualization

| Dashboard | FREE | PRO |
|-----------|------|-----|
| **System Metrics** | ✅ Basic | ✅ Enhanced with annotations |
| **Node Exporter Full** | ✅ Standard | ✅ Optimized queries |
| **Prometheus Stats** | ❌ | ✅ Monitoring system health |
| **Blackbox Exporter** | ❌ | ✅ Website/service monitoring |
| **fail2ban Monitoring** | ❌ | ✅ **UNIQUE! Security threats** |
| **Custom Panels** | Basic | ✅ 35+ professional panels |
| **Auto-refresh** | Manual | ✅ 30s intervals configured |
| **Variables & Filters** | Limited | ✅ Advanced filtering |

**Dashboard Count:**
- FREE: **2 dashboards**
- PRO: **8 dashboards** (system, fail2ban, Prometheus, Blackbox, Nginx, PostgreSQL, RabbitMQ, Redis)

Which dashboards load and what happens if you don't have Nginx or PostgreSQL: **[DASHBOARDS_AND_OPTIONAL_SERVICES.md](DASHBOARDS_AND_OPTIONAL_SERVICES.md)**.

---

### 3. Alerting System

| Alert Type | FREE | PRO |
|------------|------|-----|
| **High CPU Usage** | ✅ Basic (>80%) | ✅ Tiered (>70%, >90%) |
| **High Memory Usage** | ✅ Basic (>80%) | ✅ Advanced with swap check |
| **Disk Space Low** | ✅ Basic (<20%) | ✅ Multi-level (<30%, <10%) |
| **Service Down** | ✅ Simple | ✅ With context & runbook links |
| **High Load Average** | ❌ | ✅ Per-CPU threshold |
| **Filesystem Readonly** | ❌ | ✅ Critical alert |
| **Instance Down** | ❌ | ✅ With notification grouping |
| **Blackbox Probe Failed** | ❌ | ✅ Website monitoring |
| **Prometheus Config Error** | ❌ | ✅ Self-monitoring |
| **fail2ban Attack Detected** | ❌ | ✅ Security monitoring |
| **Alert Grouping** | None | ✅ Smart grouping & routing |
| **Notification Channels** | Manual setup | ✅ Pre-configured (Telegram, Email) |
| **Runbook URLs** | Not included | ✅ Direct links to solutions |

**Alert Count:**
- FREE: **5 basic alerts**
- PRO: **20 production alerts**

---

### 4. fail2ban Security Monitoring (PRO EXCLUSIVE!)

This is a **UNIQUE FEATURE** not found in standard monitoring solutions!

| Feature | FREE | PRO |
|---------|------|-----|
| **fail2ban Dashboard** | ❌ | ✅ **Real-time security monitoring** |
| **Banned IPs Tracking** | ❌ | ✅ Current & historical |
| **Failed Attempts Graph** | ❌ | ✅ Attack rate visualization |
| **Jail Statistics** | ❌ | ✅ Per-jail detailed stats |
| **Attack Rate Calculation** | ❌ | ✅ 5-minute rolling average |
| **Multi-Jail Support** | ❌ | ✅ SSH, nginx, recidive |
| **Prometheus Integration** | ❌ | ✅ Automated metrics export |
| **Security Alerts** | ❌ | ✅ High attack rate alerts |

**Jails Monitored (PRO):**
1. **sshd** - SSH attack protection
2. **nginx-http-auth** - HTTP brute-force
3. **nginx-limit-req** - Rate limiting/DDoS
4. **nginx-botsearch** - Bot/scanner blocking
5. **recidive** - Persistent attacker bans (4 weeks!)

---

### 5. Documentation & Support

| Resource | FREE | PRO |
|----------|------|-----|
| **README** | ✅ Basic overview | ✅ Comprehensive |
| **Quick Start Guide** | ✅ Simple | ✅ Detailed with examples |
| **Installation Guide** | Basic Docker steps | ✅ Complete Ansible guide |
| **Security Best Practices** | ❌ | ✅ **Comprehensive guide** (CRITICAL!) |
| **Operations Runbook** | ❌ | ✅ Daily operations & emergency procedures |
| **Troubleshooting Guide** | Basic | ✅ Advanced diagnostics |
| **Alert Configuration** | ❌ | ✅ Complete alert guide |
| **Backup Procedures** | ❌ | ✅ Automated backup setup |
| **fail2ban Setup Guide** | ❌ | ✅ Complete security integration |
| **Architecture Documentation** | ❌ | ✅ ADR & design decisions |
| **PromQL Query Examples** | ❌ | ✅ 50+ ready-to-use queries |
| **Support Channel** | GitHub Issues only | ✅ **Direct email support** |
| **Response Time** | Community-based | ✅ **Priority (24-48h)** |
| **Custom Configuration Help** | ❌ | ✅ Included |

**Documentation Pages:**
- FREE: **3 documents** (README, QUICK_START, DEMO)
- PRO: **20 documents** (6.7x more!)

---

### 6. Backup & Data Protection

| Feature | FREE | PRO |
|---------|------|-----|
| **Backup Scripts** | Not included | ✅ Automated shell scripts |
| **Backup Schedule** | Manual | ✅ Daily automated backups |
| **Backup Retention** | You configure | ✅ 7-day rotation |
| **Prometheus Data Backup** | Manual | ✅ Automated |
| **Grafana Config Backup** | Manual | ✅ Automated |
| **Restore Procedures** | Not documented | ✅ Step-by-step guide |
| **Disaster Recovery Plan** | ❌ | ✅ Complete DRP document |

---

### 7. Automation & Maintenance

| Task | FREE | PRO |
|------|------|-----|
| **Initial Deployment** | Manual (2-4 hours) | ✅ One command (10 minutes) |
| **Add New Server** | Manual config editing | ✅ Add to inventory + run playbook |
| **Update Dashboards** | Manual JSON editing | ✅ Version-controlled templates |
| **Update Alerts** | Manual YAML editing | ✅ Template-based updates |
| **Service Restart** | Manual Docker commands | ✅ Automated health checks |
| **Configuration Validation** | Trial & error | ✅ Ansible check mode |
| **Rollback Capability** | Manual | ✅ Playbook rollback tasks |

---

### 8. Monitoring Scope

| Target | FREE | PRO |
|--------|------|-----|
| **System Metrics** | ✅ CPU, Memory, Disk | ✅ Extended (30+ metrics) |
| **Network Metrics** | ✅ Basic | ✅ Advanced (bandwidth, errors) |
| **Process Monitoring** | Limited | ✅ Top processes tracking |
| **Website Monitoring** | ❌ | ✅ Blackbox Exporter |
| **SSL Certificate Check** | ❌ | ✅ Expiry monitoring |
| **DNS Monitoring** | ❌ | ✅ Resolution time |
| **Security Monitoring** | ❌ | ✅ **fail2ban integration** |
| **Multi-server Support** | Manual setup | ✅ Automated discovery |

---

### 9. Production Readiness

| Aspect | FREE | PRO |
|--------|------|-----|
| **Security Hardening** | Basic localhost binding | ✅ **Complete security guide** |
| **SSH Tunnel Setup** | Not documented | ✅ Step-by-step with examples |
| **Secrets Management** | Manual .env | ✅ Ansible vault integration |
| **Service Monitoring** | Basic | ✅ Self-monitoring with alerts |
| **Resource Optimization** | Default settings | ✅ Tuned for production |
| **Logging** | Docker logs | ✅ Centralized log management |
| **Compliance** | Not addressed | ✅ Best practices documented |

---

### 10. Learning & Training

| Resource | FREE | PRO |
|----------|------|-----|
| **Getting Started** | ✅ Basic README | ✅ Comprehensive tutorial |
| **Multipass Demo** | ✅ Simple script | ✅ Complete learning environment |
| **Examples** | Limited | ✅ 20+ real-world examples |
| **Best Practices** | Not documented | ✅ DevOps best practices guide |
| **Troubleshooting Scenarios** | None | ✅ Common issues & solutions |
| **Video Tutorials** | ❌ | 🔜 Coming soon |

---

## 💰 Pricing Breakdown

### FREE Version - $0
**Perfect for:**
- Personal projects
- Learning DevOps
- Testing concepts
- Small deployments (1-2 servers)

**What you get:**
- 2 basic dashboards
- 5 basic alerts
- Community support
- Basic documentation

**Time investment:** 2-4 hours setup + ongoing manual maintenance

---

### PRO Version - $40 (One-time!)

**Perfect for:**
- Production environments
- Professional projects
- Client work
- Portfolios
- 3+ servers

**What you get:**
- ✅ One-command deployment (saves 2-4 hours!)
- ✅ 8 professional dashboards
- ✅ 20 production alerts
- ✅ **fail2ban security monitoring** (UNIQUE!)
- ✅ 20 documentation guides
- ✅ Direct email support
- ✅ Lifetime updates
- ✅ No subscription!

**ROI Calculation:**
- Setup time saved: **2-4 hours** × $50/hour = **$100-200**
- Documentation time saved: **5-10 hours** × $50/hour = **$250-500**
- Support value: **Priceless** when things break at 3 AM

**Total value: $350-700** for just **$40**!

**[👉 Get PRO Version Now](PURCHASE.md)**

---

### Installation Service - $150

**Perfect for:**
- Busy professionals
- Complex environments
- Need it done right first time

**What you get:**
- ✅ Professional deployment on your servers
- ✅ Custom alert configuration
- ✅ Knowledge transfer session (1 hour)
- ✅ 30-day support included
- ✅ PRO version included ($40 value)

**Time saved:** 4-8 hours + eliminates trial-and-error

**[Request Installation Service →](SERVICES.md)**

---

## 🎯 Which Version is Right for You?

### Choose FREE if:
- ✅ You're learning monitoring concepts
- ✅ Personal/hobby project
- ✅ Have time for manual setup (2-4 hours)
- ✅ Monitoring 1-2 servers max
- ✅ Don't need advanced features

### Choose PRO if:
- ✅ Production environment
- ✅ Professional/client work
- ✅ Value your time ($40 vs 2-4 hours)
- ✅ Need security monitoring (fail2ban)
- ✅ Want comprehensive documentation
- ✅ Monitoring 3+ servers
- ✅ Need email support

### Choose Installation Service if:
- ✅ Need it done professionally
- ✅ Complex environment
- ✅ Want knowledge transfer
- ✅ Don't have time to learn details

---

## 📈 Possible future directions

Ideas we may explore (no fixed dates or promises):

- Kubernetes / cloud integrations (AWS, Azure, GCP)
- Log aggregation (e.g. Loki), APM, extra dashboard templates
- Video walkthroughs

If we ship new PRO features, existing PRO customers get them as part of lifetime updates. No roadmap dates until we commit to delivery.

---

## ❓ FAQ

**Q: Is PRO a subscription?**
A: **No!** One-time payment of $40, lifetime access including all future updates.

**Q: Can I upgrade from FREE to PRO later?**
A: Yes! Your existing setup will work with PRO playbooks.

**Q: Do I get source code with PRO?**
A: Yes! Complete Ansible playbooks, scripts, and configurations.

**Q: What if I'm not satisfied?**
A: 30-day money-back guarantee, no questions asked.

**Q: Can I use PRO for client projects?**
A: Yes! Commercial use is allowed.

**Q: How many servers can I monitor?**
A: Unlimited! Both FREE and PRO have no server limits.

---

## 🎁 Pricing and offers

Current price, bundle (PRO + installation), and any limited-time offers: **[PURCHASE.md](PURCHASE.md)**. We keep pricing in one place to avoid drift.

**[Get PRO Version →](PURCHASE.md)**
