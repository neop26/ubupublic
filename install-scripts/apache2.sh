#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

apt -y upgrade
# Deploying Apache and a custom index.html page
sudo apt -y install apache2
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html