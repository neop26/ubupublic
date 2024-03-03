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
sudo flatpak install flathub tv.plex.PlexDesktop -y
# Flathub install discord
sudo flatpak install flathub com.discordapp.Discord -y

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

# Installing Remmina
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next -y
sudo apt update -y
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret -y


# Update GRUB
echo "Updating GRUB..."
sudo update-grub


