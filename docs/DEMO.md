# Multipass Quick Demo Guide

Try the complete monitoring stack **locally** without touching production servers.  
**Two steps:** (1) create 4 VMs with the script (~2 min), (2) deploy the stack with Ansible — then you get working Grafana and Prometheus.

---

## What is This?

A demo in **two steps**:

1. **Script** creates **4 virtual machines** on your Mac (monitoring-server, web-1, web-2, db-1). After this, the VMs are empty — no Grafana or Prometheus yet.
2. **Ansible playbook** deploys the full stack (Prometheus, Grafana, Alertmanager, Node Exporters). After this, dashboards are available.

Result:

- ✅ **monitoring-server** - Prometheus, Grafana, Alertmanager
- ✅ **web-1, web-2** - Simulated web servers with Node Exporter
- ✅ **db-1** - Simulated database server with Node Exporter
- ✅ **Real multi-server monitoring** - Same as in production

**Perfect for:**
- Trying before buying PRO version
- Learning monitoring stack
- Creating screenshots
- Testing configurations
- Portfolio projects

---

## Prerequisites

### System Requirements
- **macOS** (Intel or Apple Silicon)
- **4GB free RAM** (3.5GB for VMs)
- **10GB free disk space**
- **Internet connection** (for VM images)

### Software Required

**1. Install Multipass:**
```bash
# Option A: Homebrew (recommended)
brew install multipass

# Option B: Download from website
open https://multipass.run/install
```

**2. Verify installation:**
```bash
multipass version
# Should show: multipass 1.x.x
```

---

## Quick Start (two steps)

### Step 1: Get the repo and create 4 VMs (~2 min)

```bash
# Clone the repository
git clone https://github.com/Airat71/monitoring-stack.git
cd monitoring-stack

# Make script executable
chmod +x scripts/multipass_quick_demo.sh
```

### Step 2: Run the VM script

```bash
./scripts/multipass_quick_demo.sh
```
*(This only creates and starts the 4 VMs. Dashboards will work after Step 3.)*

**What happens:**
```
🚀 Enterprise Monitoring Stack - Quick Demo
============================================

📋 Demo Configuration:
  - Monitoring Server: 2GB RAM, 2 CPU, 20GB disk
  - Web Server 1: 512MB RAM, 1 CPU, 10GB disk
  - Web Server 2: 512MB RAM, 1 CPU, 10GB disk
  - Database Server: 512MB RAM, 1 CPU, 10GB disk
  Total: ~3.5GB RAM required

🔧 Phase 1: Creating VMs...
⏳ Launching all VMs (this may take 2-3 minutes)...
✅ All VMs created successfully!

🔧 Phase 2: Waiting for VMs to initialize...
✅ All VMs initialized!

🔧 Phase 3: Installing basic packages...
✅ Basic packages installed on all VMs!

🔧 Phase 4: Collecting VM information...
✅ Demo Environment Ready!
==========================

📊 VM Information:
  🖥️  Monitoring Server: 192.168.64.4
  🌐 Web Server 1:      192.168.64.6
  🌐 Web Server 2:      192.168.64.5
  🗄️  Database Server:   192.168.64.7

⏱️  Total Time: 1m 47s

📋 Next Steps:
1. Deploy monitoring stack (see "Advanced: Deploy Full Stack" below)
2. Access Grafana: http://<MONITORING_SERVER_IP>:3001 (IP from "VM Information" above)
3. Access Prometheus: http://<MONITORING_SERVER_IP>:9090

🎬 Ready for screenshots!
```

### Step 3: Deploy the stack with Ansible (required for dashboards)

Without this step, Grafana and Prometheus are not running. Run:

```bash
cd ansible
ansible-playbook playbooks/deploy-monitoring-stack.yml -i inventories/multipass-demo.ini
```

Use the **Monitoring Server IP** from the script output (e.g. 192.168.64.4) for the next section.  
*(Full details: see "Advanced: Deploy Full Stack" below.)*

---

## Accessing the Dashboards

### Option 1: Direct Access (Simple)

If your Mac can reach the VMs directly, use the **Monitoring Server IP** from the script output (e.g. `192.168.64.4` or `192.168.64.9`):

```bash
# Replace <MONITORING_SERVER_IP> with the IP from "VM Information" above
open http://<MONITORING_SERVER_IP>:3001  # Grafana
open http://<MONITORING_SERVER_IP>:9090  # Prometheus
```

### Option 2: SSH Tunnel (Recommended)

Most secure and always works:

```bash
# Replace <MONITORING_SERVER_IP> with the IP from script output
ssh -L 3001:localhost:3001 -L 9090:localhost:9090 ubuntu@<MONITORING_SERVER_IP>

# Then open in browser
open http://localhost:3001  # Grafana
open http://localhost:9090  # Prometheus
```

**Login credentials:**
- Username: `admin`
- Password: from `.env` (GRAFANA_ADMIN_PASSWORD) or docker-compose default — see [QUICK_START](QUICK_START.md). Change on first login.

---

## What You'll See

### 1. Prometheus Targets (http://localhost:9090/targets)

✅ **multipass-demo** section with 4 targets (IPs may differ, see your script output):
- monitoring-server (e.g. 192.168.64.4:9100) - UP 🟢
- web-1, web-2, db-1 - UP 🟢

**Labels visible:**
- `environment="demo"`
- `role="web"` or `"database"` or `"monitoring"`
- `instance="web-1"` etc.

### 2. Grafana Dashboards (http://localhost:3001/dashboards)

Available dashboards:
- **System Metrics** - CPU/Memory/Disk overview
- **Node Exporter Full** - Detailed metrics
- **Prometheus Stats** - Monitoring health
- **Blackbox Exporter** - Website monitoring
- **fail2ban Monitoring** - Security (PRO feature)

### 3. Real-Time Metrics

Click on **System Metrics** dashboard:
- See CPU usage graphs for all 4 servers
- Memory consumption tracking
- Disk space monitoring
- Network traffic
- All updating in real-time!

---

## Advanced: Deploy Full Stack (PRO Demo)

Want to try the complete PRO experience? Deploy with Ansible!

### Prerequisites
```bash
# Install Ansible
brew install ansible

# Verify
ansible --version
```

### Deploy Full Stack

```bash
cd ansible

# Deploy monitoring stack
ansible-playbook playbooks/deploy-monitoring-stack.yml \
  -i inventories/multipass-demo.ini

# Wait ~10 minutes
# ✅ Full production stack deployed!
```

**What gets deployed:**
- ✅ Docker + Docker Compose
- ✅ Prometheus + Grafana + Alertmanager
- ✅ Node Exporter on all 4 VMs
- ✅ 8 professional dashboards
- ✅ 20 production alerts
- ✅ Health monitoring
- ✅ Automated configuration

---

## Demo Tasks & Learning

### 1. Monitor Real Metrics

**Generate some CPU load:**
```bash
# SSH into a VM
multipass shell web-1

# Generate CPU load
stress-ng --cpu 2 --timeout 60s

# Watch metrics in Grafana!
```

### 2. Test Alerts

**Fill up disk space (simulated):**
```bash
multipass shell web-1
dd if=/dev/zero of=/tmp/bigfile bs=1M count=1000

# Check Prometheus alerts for DiskSpaceLow
```

### 3. Add Custom Metrics

**Create custom dashboard:**
- Open Grafana
- Dashboard → New → Add visualization
- Select "Prometheus" datasource
- Query: `node_cpu_seconds_total`
- Save!

### 4. Explore PromQL

Try these queries in Prometheus (http://localhost:9090/graph):

```promql
# CPU usage per server
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk usage
100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100)
```

---

## Managing the Demo

### Check VM Status
```bash
multipass list
```

### Stop VMs (Save Resources)
```bash
multipass stop monitoring-server web-1 web-2 db-1
```

### Start VMs Again
```bash
multipass start monitoring-server web-1 web-2 db-1
```

### Shell Access
```bash
# SSH into any VM
multipass shell monitoring-server
multipass shell web-1
multipass shell db-1
```

### Check Resource Usage
```bash
# See VM resource consumption
multipass info monitoring-server
multipass info web-1
```

---

## Cleanup

### Delete Everything
```bash
# Delete all demo VMs
multipass delete monitoring-server web-1 web-2 db-1
multipass purge

# Verify cleanup
multipass list
# Should show: No instances found
```

**Disk space freed:** ~4GB

---

## Troubleshooting

### VMs Won't Start
```bash
# Check Multipass status
multipass version

# Restart Multipass daemon
sudo launchctl kickstart -k system/com.canonical.multipassd
```

### Can't Access Dashboards
```bash
# Verify VM is running
multipass info monitoring-server

# Check if services are running
multipass exec monitoring-server -- docker compose ps

# Recreate SSH tunnel (use your Monitoring Server IP from script output)
ssh -L 3001:localhost:3001 ubuntu@<MONITORING_SERVER_IP>
```

### "No Data" in Grafana
```bash
# Check Prometheus is scraping
curl http://localhost:9090/api/v1/targets

# Verify Node Exporters are running
multipass exec web-1 -- curl localhost:9100/metrics
```

### VMs Too Slow
```bash
# Allocate more resources
multipass stop monitoring-server
multipass set local.monitoring-server.cpus=4
multipass set local.monitoring-server.memory=4G
multipass start monitoring-server
```

---

## Taking Screenshots

Perfect for portfolios and presentations!

### Recommended Screenshots:

1. **Prometheus Targets** - Shows multi-server setup
   - URL: http://localhost:9090/targets
   - Capture: multipass-demo section (4/4 up)

2. **Grafana Dashboards List** - Shows available dashboards
   - URL: http://localhost:3001/dashboards
   - Capture: Full list with fail2ban highlighted

3. **System Metrics Dashboard** - Real data visualization
   - Select "Node Exporter Full"
   - Set time range: "Last 15 minutes"
   - Capture: Graphs with data

4. **Prometheus Alerts** - Alert rules
   - URL: http://localhost:9090/alerts
   - Capture: Full alert list

5. **fail2ban Dashboard** - Unique feature!
   - Grafana → fail2ban Monitoring
   - Capture: Even with "No data" - shows the feature exists!

---

## Demo Scenarios

### Scenario 1: DevOps Interview Portfolio
"I built a complete monitoring stack with Prometheus and Grafana, deployed across 4 servers using Infrastructure as Code..."

### Scenario 2: Client Demo
"Here's how we'll monitor your infrastructure - real-time metrics, alerting, beautiful dashboards..."

### Scenario 3: Learning Project
Practice:
- Prometheus queries (PromQL)
- Grafana dashboard creation
- Alert configuration
- Multi-server monitoring

---

## What's Next?

After the demo, consider:

1. **[Try Production Deployment](QUICK_START.md#option-2-production-deployment)** - Deploy on real server
2. **[Upgrade to PRO](PURCHASE.md)** - Get automated deployment ($40)
3. **[Read Full Docs](INDEX.md)** - Deep dive into features
4. **[Customize](../README.md#documentation)** - Adapt to your needs

---

## Demo Specifications

**Resources Used:**
- Total RAM: 3.5GB (2GB + 3×512MB)
- Total CPUs: 5 cores (2 + 3×1)
- Total Disk: 50GB (20GB + 3×10GB)
- Network: Internal multipass network

**Components Deployed:**
- Ubuntu 22.04 LTS (4 VMs)
- Docker + Docker Compose
- Prometheus 2.x
- Grafana 10.x
- Node Exporter 1.7.0
- Alertmanager 0.26.x

---

## Support

**Issues with demo?**
- Check [Troubleshooting](#troubleshooting) above
- Search [GitHub Issues](https://github.com/Airat71/monitoring-stack/issues)
- Create new issue with `[DEMO]` tag

**Ready for production?**
- [Get PRO Version](PURCHASE.md) - $40 one-time
- [Request Installation](SERVICES.md) - $150 fully installed

---

**Happy Learning!** 🎉

The demo environment is safe to experiment with - you can always delete and recreate it in 2 minutes!
