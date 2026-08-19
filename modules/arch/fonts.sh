#!/bin/bash
# Arch Linux: Install font packages

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm ttf-fira-code ttf-font-awesome noto-fonts noto-fonts-cjk noto-fonts-emoji >>"$LOG" 2>&1 || true

echo -e "${NOTE} Optionally installing JetBrains Mono Nerd via manual download..."
JET_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
if [ ! -d "$JET_DIR" ]; then
  mkdir -p "$JET_DIR"
  url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tmp="$(mktemp)"
  if download_file "$url" "$tmp"; then
    tar -xJf "$tmp" -C "$JET_DIR" >>"$LOG" 2>&1 && fc-cache -fv >>"$LOG" 2>&1
  fi
  rm -f "$tmp"
fi
echo -e "${OK} Fonts setup complete."

