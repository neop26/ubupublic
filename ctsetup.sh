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
