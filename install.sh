# Bash script to install applications for a fresh Ubuntu Install

#!/bin/bash

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install Snap
sudo apt install snapd -y

# Install Snap Packages
sudo snap install spotify
sudo snap install vlc
sudo snap install gimp
sudo snap install chromium
sudo snap install brave
sudo snap install firefox
sudo snap install opera
sudo snap install tor
sudo snap install bitwarden

# Install Flatpak
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Flathub install Vscode
sudo flatpak install flathub com.visualstudio.code -y
# Flathub install Microsoft Edge
sudo flatpak install flathub com.microsoft.Edge -y

# Install Grub Optimizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt install grub-customizer -y

# Install Gnome Tweaks
sudo apt install gnome-tweaks -y

# Install Gnome Extensions
sudo apt install gnome-shell-extensions -y

# Install Gparted
sudo apt install gparted -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Install zsh
sudo apt install zsh -y

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Thunar
sudo apt install thunar -y

# Install Thunar Plugins
sudo apt install thunar-archive-plugin -y

# Install Thunar Media Tags
sudo apt install thunar-media-tags-plugin -y

# Install Thunar Thumbnailers
sudo apt install ffmpegthumbnailer -y

# Install Thunar Custom Actions
sudo apt install thunar-custom-actions -y

# Install Thunar Send To
sudo apt install thunar-sendto-clamtk -y

# Install wallpaper manager
sudo apt install variety -y

# Install Gnome Disk Utility
sudo apt install gnome-disk-utility -y

# Install Gnome System Monitor
sudo apt install gnome-system-monitor -y

# Install Gnome Screenshot
sudo apt install gnome-screenshot -y

# Install Gnome Calculator
sudo apt install gnome-calculator -y

# Install Gnome Calendar
sudo apt install gnome-calendar -y

# Install Gnome Clocks
sudo apt install gnome-clocks -y

# Install Gnome Weather
sudo apt install gnome-weather -y

# Install Gnome Maps
sudo apt install gnome-maps -y

# Install Terraform
sudo apt install terraform -y

# Install Docker
sudo apt install docker.io -y

# Install Docker Compose
sudo apt install docker-compose -y

# Install nix package manager
curl -L https://nixos.org/nix/install | sh

## Change the transparency to 50% for the Terminal
# Get the current profile
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default)

# Remove leading and trailing single quotes
PROFILE=${PROFILE:1:-1}

# Set the transparency
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/ background-transparency-percent 50

sudo apt-get install -y grub-pc

# Update GRUB
echo "Updating GRUB..."
sudo update-grub


