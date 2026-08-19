#!/bin/bash
# Arch Linux: system update and essentials

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Updating system (pacman -Syu)..."
sudo pacman -Syyu --noconfirm >>"$LOG" 2>&1

echo -e "${NOTE} Installing essential packages..."
sudo pacman -S --needed --noconfirm curl wget git nano base-devel >>"$LOG" 2>&1 || true

echo -e "${NOTE} Setting timezone to ${DEFAULT_TIMEZONE}..."
set_timezone "${DEFAULT_TIMEZONE}"

echo -e "${NOTE} Installing monitors (htop, ncdu)..."
sudo pacman -S --needed --noconfirm htop ncdu >>"$LOG" 2>&1 || true

"$SCRIPT_DIR/fastfetch.sh"

echo -e "${OK} System update completed."

