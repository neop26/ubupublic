#!/bin/bash
# Arch Linux: Install and configure Fastfetch

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm fastfetch >>"$LOG" 2>&1

CFG_DIR="$HOME/.config/fastfetch"
CFG_FILE="$CFG_DIR/config.jsonc"
create_directory "$CFG_DIR" 755
if [ -f "$CFG_FILE" ]; then
  backup_file "$CFG_FILE"
fi
if [ -f "$ASSETS_DIR/fastfetchconfig.jsonc" ]; then
  cp "$ASSETS_DIR/fastfetchconfig.jsonc" "$CFG_FILE" >>"$LOG" 2>&1
fi
echo -e "${OK} Fastfetch installed and configured."

