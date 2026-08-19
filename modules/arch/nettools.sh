#!/bin/bash
# Arch Linux: Install network tools

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm net-tools nmap traceroute iperf3 >>"$LOG" 2>&1
echo -e "${OK} Network tools installed."

