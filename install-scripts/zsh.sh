#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Zsh and Oh my Zsh + Pokemon ColorScripts#

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
cp -r 'assets/.zshrc' ~/

# Install Pokemon color scripts
if [ -d "pokemon-colorscripts" ]; then
    cd pokemon-colorscripts && git pull && sudo ./install.sh && cd ..
else
    git clone https://github.com/Pokemon-color-scripts/pokemon-colorscripts.git
    cd pokemon-colorscripts && sudo ./install.sh && cd ..
fi
sed -i '/#pokemon-colorscripts --no-title -s -r/s/^#//' assets/.zshrc

# Set zsh as the default shell
chsh -s $(which zsh)