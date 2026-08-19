#!/bin/bash
# Arch Linux: Install Zsh and basic Oh My Zsh setup

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

sudo pacman -S --needed --noconfirm zsh git wget >>"$LOG" 2>&1

# Minimal Oh My Zsh setup without curl-to-bash
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh" >>"$LOG" 2>&1 || true
fi

if [ -f "$ASSETS_DIR/.zshrc" ]; then
  cp "$ASSETS_DIR/.zshrc" "$HOME/.zshrc"
elif [ ! -f "$HOME/.zshrc" ] && [ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]; then
  cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

chsh -s "$(which zsh)"
echo -e "${OK} Zsh installed and set as default shell."

