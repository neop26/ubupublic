#!/bin/bash
# Arch Linux: Azure dev environment (partial)

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Installing Terraform from community..."
sudo pacman -S --needed --noconfirm terraform neovim base-devel cmake ninja gettext libtool pkgconf unzip curl >>"$LOG" 2>&1 || true

NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
  mkdir -p "$NVIM_DIR"
  git clone https://github.com/LazyVim/starter "$NVIM_DIR" >>"$LOG" 2>&1 || true
fi

echo -e "${WARN} Azure CLI and Bicep are not in official repos."
echo -e "${NOTE} Consider AUR helpers: azure-cli, bicep-bin."
echo -e "${OK} Azure dev baseline setup complete (Terraform + Neovim)."

