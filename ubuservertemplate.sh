# Bash script to install applications for a fresh Ubuntu CT

#!/bin/bash

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

clear

printf "\n%.0s" {1..3}         _             _            _      
echo "         /\ \     _    /\ \         /\ \       "
echo "        /  \ \   /\_\ /  \ \       /  \ \      "
echo "       / /\ \ \_/ / // /\ \ \     / /\ \ \     "
echo "      / / /\ \___/ // / /\ \_\   / / /\ \ \    "
echo "     / / /  \/____// /_/_ \/_/  / / /  \ \_\   "
echo "    / / /    / / // /____/\    / / /   / / /   "
echo "   / / /    / / // /\____\/   / / /   / / /    "
echo "  / / /    / / // / /______  / / /___/ / /     "
echo " / / /    / / // / /_______\/ / /____\/ /      "
echo " \/_/     \/_/ \/__________/\/_________/       "
printf "\n%.0s" {1..2}                                      


# Update and Upgrade
apt update && apt upgrade -y

# Add Net Tools
apt install net-tools -y

# Install Neofetch
apt install neofetch -y

# Install Htop
apt install htop -y

# Ability to deploy repository
apt install --reinstall software-properties-common -y

# Install oh-my-zsh
apt install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Oh-My-Zsh has been installed!"

echo "All done!"
