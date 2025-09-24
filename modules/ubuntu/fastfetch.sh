#!/bin/bash
# Install and configure Fastfetch on Ubuntu

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Installing Fastfetch..."
ARCHITECTURE=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
if [ "$ARCHITECTURE" != "amd64" ]; then
  echo -e "${ERROR} This installer currently supports only amd64. Detected: $ARCHITECTURE"
  exit 1
fi

TMP_DEB="/tmp/fastfetch-linux-amd64.deb"
FASTFETCH_URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"

if ! download_file "$FASTFETCH_URL" "$TMP_DEB"; then
  echo -e "${ERROR} Failed to download Fastfetch package from $FASTFETCH_URL"
  exit 1
fi

if ! sudo apt install -y "$TMP_DEB" >>"$LOG" 2>&1; then
  echo -e "${ERROR} Failed to install Fastfetch from $TMP_DEB"
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

rm -f "$TMP_DEB"

echo -e "${OK} Fastfetch installation complete."
