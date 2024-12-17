#!/bin/bash

# Script to configure a hostname on Ubuntu

# Prompt for Hostname
read -p "Enter the new hostname for this server : " hostname

# Check if hostname is not empty
if [ -n "$hostname" ]; then
    sudo hostnamectl set-hostname $hostname
    echo "Hostname has been set to $hostname."
else
    echo "No hostname entered. Skipping hostname configuration."
fi