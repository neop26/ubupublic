#!/bin/bash
# Arch Linux: Install Node.js and npm

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm nodejs npm >>"$LOG" 2>&1
echo -e "${OK} Node.js and npm installed."

