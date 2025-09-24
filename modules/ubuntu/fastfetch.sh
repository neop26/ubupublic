#!/bin/bash
# Install and configure Fastfetch on Ubuntu

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Installing Fastfetch..."
sudo apt-get update >>"$LOG" 2>&1
if ! install_package fastfetch; then
  echo -e "${ERROR} Fastfetch package installation failed."
  exit 1
fi

CFG_DIR="$HOME/.config/fastfetch"
CFG_FILE="$CFG_DIR/config.jsonc"

create_directory "$CFG_DIR" 755
if [ -f "$CFG_FILE" ]; then
  backup_file "$CFG_FILE"
fi

if [ -f "$ASSETS_DIR/fastfetchconfig.jsonc" ]; then
  cp "$ASSETS_DIR/fastfetchconfig.jsonc" "$CFG_FILE" >>"$LOG" 2>&1
  echo -e "${OK} Fastfetch configured (${CFG_FILE})"
else
  echo -e "${WARN} Missing asset: $ASSETS_DIR/fastfetchconfig.jsonc"
fi

echo -e "${OK} Fastfetch installation complete."
