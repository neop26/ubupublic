# Bash script to Update the system

#!/bin/bash

# Update the package list
sudo apt update

sudo apt install curl -y

sudo apt install --reinstall software-properties-common -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

echo "System updated successfully"
wait 2

clear