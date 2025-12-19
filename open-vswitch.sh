#!/bin/bash
set -e

### VARIABLES (EDIT THESE) ###
BRIDGE1="lan1"
BRIDGE2="lan2"

### CHECK ROOT ###
if [[ $EUID -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

echo "Installing Open vSwitch..."
apt update
apt install -y openvswitch-switch ifupdown2

systemctl enable --now openvswitch-switch

echo "Backing up network config..."
cp /etc/network/interfaces /etc/network/interfaces.bak.$(date +%F_%T)

echo "Writing OVS network configuration..."

cat > /etc/network/interfaces <<EOF

auto $BRIDGE1
iface $BRIDGE1 inet manuel
    ovs_type OVSBridge

auto $BRIDGE2
iface $BRIDGE2 inet manuel
    ovs_type OVSBridge
EOF

echo "Reloading network configuration..."
ifreload -a

echo "OVS configuration complete."
echo "Verifying:"
ovs-vsctl show
ip addr show $BRIDGE
