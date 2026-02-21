#!/bin/bash

# Multipass Quick Demo - Enterprise Monitoring Stack
# Creates 6 VMs for demonstration and scaling tests (does NOT touch production)
# Version: 1.1
# Date: 2026-02-20

set -e  # Exit on error

echo "🚀 Enterprise Monitoring Stack - Quick Demo (6 VMs, scaling test)"
echo "=================================================================="
echo "  ⚠️  Demo only — does NOT touch your real monitoring or production server."
echo ""

# Configuration
MONITORING_VM="monitoring-server"
WEB1_VM="web-1"
WEB2_VM="web-2"
WEB3_VM="web-3"
DB_VM="db-1"
DB2_VM="db-2"

# Timestamp for logs
START_TIME=$(date +%s)

echo "📋 Demo Configuration:"
echo "  - Monitoring Server: 2GB RAM, 2 CPU, 20GB disk"
echo "  - Web 1/2/3: 512MB RAM, 1 CPU, 10GB disk each"
echo "  - Database 1/2: 512MB RAM, 1 CPU, 10GB disk each"
echo "  Total: 6 VMs, ~4.5GB RAM required"
echo ""

# Function to create VM
create_vm() {
    local name=$1
    local cpus=$2
    local mem=$3
    local disk=$4

    echo "⏳ Creating VM: $name ($cpus CPU, $mem RAM, $disk disk)..."
    multipass launch --name "$name" --cpus "$cpus" --memory "$mem" --disk "$disk" 22.04
    echo "✅ VM created: $name"
}

# Function to wait for VM to be ready
wait_for_vm() {
    local name=$1
    echo "⏳ Waiting for $name to be ready..."
    sleep 5
    multipass exec "$name" -- cloud-init status --wait
    echo "✅ $name is ready!"
}

# Function to install basic packages
install_basics() {
    local name=$1
    echo "📦 Installing basic packages on $name..."
    multipass exec "$name" -- bash -c "
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get install -y -qq curl wget htop > /dev/null 2>&1
    "
    echo "✅ Basic packages installed on $name"
}

echo "🔧 Phase 1: Creating VMs..."
echo "================================"
echo ""

# Create VMs in parallel for speed
echo "⏳ Launching all VMs (this may take 3-5 minutes)..."
create_vm "$MONITORING_VM" 2 2G 20G &
create_vm "$WEB1_VM" 1 512M 10G &
create_vm "$WEB2_VM" 1 512M 10G &
create_vm "$WEB3_VM" 1 512M 10G &
create_vm "$DB_VM" 1 512M 10G &
create_vm "$DB2_VM" 1 512M 10G &

# Wait for all background jobs to complete
wait

echo ""
echo "✅ All VMs created successfully!"
echo ""

# Wait for VMs to be ready
echo "🔧 Phase 2: Waiting for VMs to initialize..."
echo "=============================================="
echo ""

wait_for_vm "$MONITORING_VM"
wait_for_vm "$WEB1_VM"
wait_for_vm "$WEB2_VM"
wait_for_vm "$WEB3_VM"
wait_for_vm "$DB_VM"
wait_for_vm "$DB2_VM"

echo ""
echo "✅ All VMs initialized!"
echo ""

# Install basic packages
echo "🔧 Phase 3: Installing basic packages..."
echo "=========================================="
echo ""

install_basics "$MONITORING_VM" &
install_basics "$WEB1_VM" &
install_basics "$WEB2_VM" &
install_basics "$WEB3_VM" &
install_basics "$DB_VM" &
install_basics "$DB2_VM" &

wait

echo ""
echo "✅ Basic packages installed on all VMs!"
echo ""

# Get VM IPs
echo "🔧 Phase 4: Collecting VM information..."
echo "=========================================="
echo ""

MONITORING_IP=$(multipass info "$MONITORING_VM" | grep IPv4 | awk '{print $2}')
WEB1_IP=$(multipass info "$WEB1_VM" | grep IPv4 | awk '{print $2}')
WEB2_IP=$(multipass info "$WEB2_VM" | grep IPv4 | awk '{print $2}')
WEB3_IP=$(multipass info "$WEB3_VM" | grep IPv4 | awk '{print $2}')
DB_IP=$(multipass info "$DB_VM" | grep IPv4 | awk '{print $2}')
DB2_IP=$(multipass info "$DB2_VM" | grep IPv4 | awk '{print $2}')

# Calculate total time
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_TIME / 60))
SECONDS=$((TOTAL_TIME % 60))

echo "✅ Demo Environment Ready!"
echo "=========================="
echo ""
echo "📊 VM Information:"
echo "  🖥️  Monitoring Server: $MONITORING_IP"
echo "  🌐 Web 1: $WEB1_IP  Web 2: $WEB2_IP  Web 3: $WEB3_IP"
echo "  🗄️  DB 1: $DB_IP  DB 2: $DB2_IP"
echo ""
echo "⏱️  Total Time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "📝 Ansible Inventory (copy to ansible/inventories/multipass-demo.ini):"
echo "========================================"
echo ""
echo "# Ansible Inventory for Multipass Demo - 6 VMs (scaling test)"
echo "# Replace file ansible/inventories/multipass-demo.ini with this block"
echo ""
echo "[monitoring_servers]"
echo "$MONITORING_VM ansible_host=$MONITORING_IP ansible_user=ubuntu"
echo ""
echo "[web_servers]"
echo "$WEB1_VM ansible_host=$WEB1_IP ansible_user=ubuntu"
echo "$WEB2_VM ansible_host=$WEB2_IP ansible_user=ubuntu"
echo "$WEB3_VM ansible_host=$WEB3_IP ansible_user=ubuntu"
echo ""
echo "[databases]"
echo "$DB_VM ansible_host=$DB_IP ansible_user=ubuntu"
echo "$DB2_VM ansible_host=$DB2_IP ansible_user=ubuntu"
echo ""
echo "[monitored_nodes:children]"
echo "web_servers"
echo "databases"
echo ""
echo "[all:vars]"
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
echo "ansible_python_interpreter=/usr/bin/python3"
echo ""
echo "📋 Next Steps (demo only — does not touch production):"
echo "=============="
echo "1. Update ansible/inventories/multipass-demo.ini with the block above"
echo "2. From project root: cd ansible && ansible-playbook playbooks/install-node-exporter.yml -i inventories/multipass-demo.ini"
echo "3. Add the printed monitored_hosts snippet to ansible/inventories/group_vars/monitoring_servers.yml (monitored_hosts list)"
echo "4. Deploy stack: ansible-playbook playbooks/deploy-monitoring-stack.yml -i inventories/multipass-demo.ini"
echo "5. Grafana: http://$MONITORING_IP:3001  Prometheus: http://$MONITORING_IP:9090"
echo ""
echo "🎬 Ready for scaling test!"
echo ""
