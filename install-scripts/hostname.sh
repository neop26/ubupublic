#!/bin/bash

# Script to configure a static IP address on Ubuntu

# Prompt for network interface, static IP, gateway, and DNS
read -p "Enter the new hostname for this server (e.g., eth0): " hostname


sudo hostnamectl set-hostname $hostname


echo "Hostname has been set to $hostname."