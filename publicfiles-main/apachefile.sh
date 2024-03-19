#!/bin/bash
sudo apt update
sudo apt install wget curl nano software-properties-common dirmngr apt-transport-https gnupg gnupg2 ca-certificates lsb-release ubuntu-keyring unzip -y 
sudo apt -y install cockpit
# sudo apt -y install docker.io
# sudo docker volume create portainer_data
# sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
apt -y upgrade
# Deploying Apache and a custom index.html page
sudo apt -y install apache2
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html

