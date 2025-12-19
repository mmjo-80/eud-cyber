#!/bin/bash
set -e

echo "=== Proxmox VE 9 no-subscription setup ==="

# Hard-fail if not PVE 9
if ! pveversion | grep -q "pve-manager/9"; then
    echo "ERROR: This script is for Proxmox VE 9 only."
    exit 1
fi

DEBIAN_CODENAME="trixie"

echo "Detected Proxmox VE 9 (Debian $DEBIAN_CODENAME)"

# 1. Disable enterprise repo
echo "Disabling enterprise repository..."
rm -f /etc/apt/sources.list.d/pve-enterprise.sources

# 2. Disable Ceph enterprise repo
echo "Disabling Ceph enterprise repository..."
rm -f /etc/apt/sources.list.d/ceph.sources

# 3. Add no-subscription repo
echo "Adding no-subscription repository..."
cat <<EOF > /etc/apt/sources.list.d/pve-no-subscription.list
deb http://download.proxmox.com/debian/pve $DEBIAN_CODENAME pve-no-subscription
EOF

# 4. Disable subscription popup
POPUP_JS="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
if [ -f "$POPUP_JS" ]; then
    echo "Disabling subscription popup..."
    sed -i.bak 's/data.status !== "Active"/false/' "$POPUP_JS"
    systemctl restart pveproxy
else
    echo "WARNING: Popup JS file not found"
fi

# 5. Clean and update APT
echo "Updating package lists..."
apt clean
apt update

echo "=== Done ==="
echo "Enterprise repos disabled, no-subscription enabled."
echo "NOTE: Popup suppression will be reverted after updates."

