# Bash script to Update the system

#!/bin/bash

# Update the package list
sudo apt update

# Install Neofetch
sudo apt install neofetch -y

#Backing up Existing Config
if [ -f "~/.config/neofetch/config.conf" ]; then
cp -b "~/.config/neofetch/config.conf" "~/.config/neofetch/config.conf-backup" || true
fi

# Copy the neofetch config file
mkdir -p ~/.config/neofetch
 cp -r 'assets/config.conf'  ~/.config/neofetch/