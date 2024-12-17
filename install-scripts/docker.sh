#!/bin/bash

# Download Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh

# Run Docker installation script
sudo sh ./get-docker.sh

# Install Docker packages
#sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker service to start on boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# Add current user to the Docker group
sudo usermod -aG docker $USER

# Exit the script
exit