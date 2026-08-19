#!/bin/bash
# Arch Linux: Install Cockpit

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm cockpit >>"$LOG" 2>&1 || true
sudo systemctl enable --now cockpit.socket >>"$LOG" 2>&1 || true
echo -e "${OK} Cockpit installed (socket activated)."

