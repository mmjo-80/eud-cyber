#!/bin/bash
set -e

START_VMID=100
VMN_AME="win11"
STORAGE="local-lvm"
BRIDGE="lan1"
ISO_DIR="/var/lib/vz/template/iso"
WIN_ISO="$ISO_DIR/Win11.iso"
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"

# ===== Find next free VMID =====
VMID=$START_VMID
while qm status $VMID &>/dev/null; do
    VMID=$((VMID + 1))
done
echo "Selected free VMID: $VMID"

# ===== Handle VM name collision =====
VM_NAME="$BASE_NAME"
COUNT=1
while qm list | awk '{print $2}' | grep -x "$VM_NAME" &>/dev/null; do
    VM_NAME="${BASE_NAME}-${COUNT}"
    COUNT=$((COUNT + 1))
done
echo "VM name to use: $VM_NAME"

# ===== Download IMG if missing =====
if [ ! -f "$IMG_PATH" ]; then
    echo "Downloading $IMG_NAME IMG..."
    wget --show-progress -O "$IMG_PATH" "$IMG_URL"
else
    echo "IMG already exists: $IMG_PATH"
fi


echo "[+] Downloading Windows 11 ISO"
wget -O "$WIN_ISO" \
https://software-download.microsoft.com/download/pr/Windows11_23H2_English_x64.iso

echo "[+] Downloading VirtIO drivers"
wget -O "$VIRTIO_ISO" \
https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

echo "[+] Creating VM $VMID"

qm create $VMID \
  --name "$VMNAME" \
  --memory 8192 \
  --cores 4 \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 $STORAGE:1,version=v2.0 \
  --scsihw virtio-scsi-pci \
  --scsi0 $STORAGE:64 \
  --net0 virtio,bridge=$BRIDGE \
  --vga std \
  --ostype win11

qm set $VMID --ide2 local:iso/Win11.iso,media=cdrom
qm set $VMID --ide3 local:iso/virtio-win.iso,media=cdrom

# Attach Autounattend.xml as floppy
qm set $VMID --floppy0 local:snippets/autounattend.xml

qm set $VMID --boot order=scsi0

echo "✅ VM created. Starting installation…"
qm start $VMID
