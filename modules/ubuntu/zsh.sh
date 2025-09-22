#!/bin/bash
# 💫 Zsh and Oh My Zsh + plugins

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
# Install zsh
sudo apt-get update
sudo apt-get install -y zsh

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Copy .zshrc configuration
if [ -f "$ASSETS_DIR/.zshrc" ]; then
  cp "$ASSETS_DIR/.zshrc" "$HOME/.zshrc"
fi

## Install Pokemon color scripts
#if [ -d "pokemon-colorscripts" ]; then
#    cd pokemon-colorscripts && git pull && sudo ./install.sh && cd ..
#else
#    git clone https://github.com/Pokemon-color-scripts/pokemon-colorscripts.git
#    cd pokemon-colorscripts && sudo ./install.sh && cd ..
#fi
#sed -i '/#pokemon-colorscripts --no-title -s -r/s/^#//' assets/.zshrc

# Set zsh as the default shell
echo "Changing default shell to zsh, so you will be prompted"
chsh -s "$(which zsh)"
# Moved from install-scripts: zsh.sh (ubuntu-specific)
