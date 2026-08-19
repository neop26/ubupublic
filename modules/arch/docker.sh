#!/bin/bash
# Arch Linux: Install Docker and Docker Compose

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Installing Docker..."
sudo pacman -S --needed --noconfirm docker docker-compose >>"$LOG" 2>&1
sudo systemctl enable --now docker >>"$LOG" 2>&1

echo -e "${NOTE} Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER" >>"$LOG" 2>&1

if check_service docker; then
  echo -e "${OK} Docker service running."
fi

echo -e "${WARN} You may need to log out/in for group changes to take effect."

