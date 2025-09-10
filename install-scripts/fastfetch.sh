#!/bin/bash

# Update the package list
sudo apt update

# Install Fastfetch
sudo apt install fastfetch -y

# Backing up Existing Config
if [ -f "~/.config/fastfetch/config.jsonc" ]; then
cp -b "~/.config/fastfetch/config.jsonc" "~/.config/fastfetch/config.jsonc-backup" || true
fi

# Copy the fastfetch config file
mkdir -p ~/.config/fastfetch
cp -r '../assets/fastfetchconfig.jsonc' ~/.config/fastfetch/config.jsonc
