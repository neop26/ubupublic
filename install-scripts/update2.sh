#!/bin/bash

# Update package list and upgrade all packages
sudo apt update && sudo apt upgrade -y

# Remove unnecessary packages and dependencies
sudo apt autoremove -y
sudo apt autoclean -y

# Clean up old versions of Snap packages
sudo snap refresh
sudo snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do sudo snap remove "$snapname" --revision="$revision"; done

# Remove old kernels
sudo apt-get --purge autoremove -y

# Check for and remove orphaned packages
sudo deborphan | xargs sudo apt-get -y remove --purge

# Clean up journal logs
sudo journalctl --vacuum-time=2weeks

# Check for and fix broken dependencies
sudo apt --fix-broken install -y

# Update the locate database
sudo updatedb

echo "Maintenance complete!"