# Bash script to install applications for a fresh Ubuntu CT

#!/bin/bash

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Add Net Tools
sudo apt install net-tools -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Ability to deploy repository
sudo apt install --reinstall software-properties-common -y

## Deploying Terraform onto Ubuntu Container
# Add the HashiCorp GPG key.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the official HashiCorp Linux repository.
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install Terraform
sudo apt update && sudo apt install terraform -y

## Deploying Bicep onto Ubuntu Container
# Add the Microsoft GPG key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null

# Add the Microsoft repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null

# Update and install Bicep
sudo apt update && sudo apt install bicep -y

# Deploying Nvim
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update -y
sudo apt install build-essential -y
sudo apt-get install manpages-dev -y
sudo apt install cmake -y
sudo apt-get install ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl -y
sudo apt-get install neovim -y
# Configuring LazyVim
sudo mkdir .config/nvim
sudo git clone https://github.com/LazyVim/starter ~/.config/nvim

echo "All done!"
