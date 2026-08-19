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

# Sanitize agnoster.zsh-theme to remove non-ASCII characters from line 12
THEME_FILE="$HOME/.oh-my-zsh/themes/agnoster.zsh-theme"
if [ -f "$THEME_FILE" ]; then
  # Remove non-ASCII characters from line 12
  sed -i '12s/[^\x00-\x7F]//g' "$THEME_FILE"
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
DEFAULT_ZSH=$(command -v zsh || true)
if [ -z "$DEFAULT_ZSH" ]; then
  echo -e "${WARN} Unable to locate zsh binary; skipping default shell change."
else
  if [ "${CI:-}" = "true" ]; then
    echo -e "${NOTE} CI environment detected; skipping default shell change."
  else
    echo -e "${NOTE} Changing default shell to zsh..."
    if command_exists sudo; then
      sudo chsh -s "$DEFAULT_ZSH" "$USER"
    else
      chsh -s "$DEFAULT_ZSH"
    fi
  fi
fi
# Moved from install-scripts: zsh.sh (ubuntu-specific)
