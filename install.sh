#!/bin/bash
set -e

GUACVM="./GUACVM/create-GUAC-VM.sh"

echo "Starting Guacamole VM creation..."
bash "$GUACVM"

echo "Guacamole VM creation script finished."
