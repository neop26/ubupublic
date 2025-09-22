#!/bin/bash
# Arch Linux: Install NVIDIA drivers (proprietary)

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Installing NVIDIA drivers (kernel modules will require reboot)..."
sudo pacman -S --needed --noconfirm nvidia nvidia-utils >>"$LOG" 2>&1 || true
echo -e "${WARN} For DKMS or LTS kernels, adjust packages accordingly."
echo -e "${OK} NVIDIA driver installation step completed."

