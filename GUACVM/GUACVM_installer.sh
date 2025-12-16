#!/bin/bash
set -e

# ===== CONFIGURATION =====
START_VMID=100
VM_NAME="ubuntu-24-04-3"
ISO_NAME="ubuntu-24.04.3-live-server-amd64.iso"
ISO_URL="https://releases.ubuntu.com/24.04/${ISO_NAME}"
ISO_STORAGE="local"
DISK_STORAGE="local-lvm"
MEMORY=4096       # in MB
CORES=4
DISK_SIZE=32G
BRIDGE="vmbr0"
# =========================

# ===== Find next available VMID =====
VMID=$START_VMID
while qm status $VMID &>/dev/null; do
    VMID=$((VMID + 1))
done
echo "Selected free VMID: $VMID"

# ===== Download ISO if missing =====
ISO_PATH="/var/lib/vz/template/iso/${ISO_NAME}"
if [ ! -f "$ISO_PATH" ]; then
    echo "Downloading Ubuntu 24.04.3 ISO..."
    wget --show-progress -O "$ISO_PATH" "$ISO_URL"
else
    echo "ISO already exists: $ISO_PATH"
fi

# ===== Create VM =====
echo "Creating VM $VMID..."
qm create $VMID \
  --name "${VM_NAME}-${VMID}" \
  --memory $MEMORY \
  --cores $CORES \
  --cpu host \
  --net0 virtio,bridge=$BRIDGE \
  --ostype l26

# ===== Add disk =====
qm set $VMID \
  --scsihw virtio-scsi-pci \
  --scsi0 ${DISK_STORAGE}:size=${DISK_SIZE}

# ===== Attach ISO =====
qm set $VMID \
  --cdrom ${ISO_STORAGE}:iso/${ISO_NAME}

# ===== Boot order & console =====
qm set $VMID \
  --boot order=scsi0,ide2 \
  --vga serial0 \
  --serial0 socket

# ===== Enable QEMU Guest Agent =====
qm set $VMID --agent enabled=1

echo "VM $VMID (${VM_NAME}-${VMID}) created successfully!"
echo "Start the VM with: qm start $VMID"
