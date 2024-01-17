# Bash script to install applications for a fresh Ubuntu Install

#!/bin/bash

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install Snap
sudo apt install snapd -y

# Install Snap Packages
sudo snap install spotify
sudo snap install chromium

# Install Flatpak and Flatpak Apps
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Flathub install Vscode
sudo flatpak install flathub com.visualstudio.code -y
# Flathub install Microsoft Edge
sudo flatpak install flathub com.microsoft.Edge -y
# Flathub install Xmind
sudo flatpak install flathub net.xmind.XMind -y
# Flatfub install plex
flatpak install flathub tv.plex.PlexDesktop

# Installing Twingate
curl -s https://binaries.twingate.com/client/linux/install.sh | sudo bash

# Install Net-tools
sudo apt install net-tools -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

#grub
sudo apt-get install -y grub-pc

# Update GRUB
echo "Updating GRUB..."
sudo update-grub


