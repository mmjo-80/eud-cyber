#!/bin/bash
set -e

GUACVM="./GUACVM/GUACVM_installer.sh"
OPENVSWITCH="./open-vswitch.sh"
VULN-SRV01="./VULN-SRV01/VULN-SRV01_installer.sh"
echo "Starting Open-vswitch installation and configuration"
bash "$OPENVSWITCH"
echo "Starting Guacamole VM creation..."
bash "$GUACVM"
echo "Starting Vuln-server01 VM creation..."
bash "$VULN-SRV01"


