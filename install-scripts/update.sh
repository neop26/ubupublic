# Bash script to Update the system

#!/bin/bash

# Update the package list
sudo apt update

sudo apt install curl -y

sudo apt-get install -y language-pack-en

sudo apt install --reinstall software-properties-common -y

sudo setcap cap_net_raw+ep /bin/ping

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Setting timezone to Auckland
sudo timedatectl set-timezone Pacific/Auckland
echo "Timezone set to Auckland"

sudo apt install wget curl nano software-properties-common dirmngr apt-transport-https gnupg gnupg2 ca-certificates lsb-release ubuntu-keyring unzip -y 

echo "System updated successfully"
wait 2

clear