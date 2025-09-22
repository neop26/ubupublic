#!/bin/bash
# Arch Linux: Install Apache (httpd)

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm apache >>"$LOG" 2>&1
sudo systemctl enable --now httpd >>"$LOG" 2>&1 || true
echo "Hello world from $(hostname) $(hostname -I)" | sudo tee /srv/http/index.html >/dev/null
echo -e "${OK} Apache installed."

