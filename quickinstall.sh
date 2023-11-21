# Bash script to install applications for a fresh Ubuntu Install

#!/bin/bash

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install Snap
sudo apt install snapd -y

# Install Snap Packages
sudo snap install spotify
sudo snap install chromium

# Install Flatpak
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Flathub install Vscode
sudo flatpak install flathub com.visualstudio.code -y
# Flathub install Microsoft Edge
sudo flatpak install flathub com.microsoft.Edge -y

# Install Fish
sudo apt install fish -y

# Install Net-tools
sudo apt install net-tools -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Install Terraform
sudo apt install terraform -y

# Install Docker
sudo apt install docker.io -y

# Install Docker Compose
sudo apt install docker-compose -y

# Install nix package manager
curl -L https://nixos.org/nix/install | sh

#grub
sudo apt-get install -y grub-pc

# Update GRUB
echo "Updating GRUB..."
sudo update-grub


