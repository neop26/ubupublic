#!/bin/bash
# Arch Linux: Static IP configuration (not implemented)

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${WARN} Static IP setup is not automated for Arch yet."
echo -e "${NOTE} Please configure via NetworkManager or systemd-networkd."
exit 0

