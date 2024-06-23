#!/bin/bash

# Script to configure a static IP address on Ubuntu

# Prompt for network interface, static IP, gateway, and DNS
read -p "Enter the network interface name (e.g., eth0): " interface
read -p "Enter the static IP address (e.g., 192.168.1.10/24): " static_ip
read -p "Enter the gateway IP (e.g., 192.168.1.1): " gateway_ip
read -p "Enter the DNS server IP (e.g., 8.8.8.8): " dns_ip

# Backup current netplan configuration
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.backup
sudo rm -r /etc/netplan/50-cloud-init.yaml

# Generate new netplan configuration
cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$static_ip]
      gateway4: $gateway_ip
      nameservers:
        addresses: [$dns_ip]
EOF

# Apply the new netplan configuration
sudo netplan apply

echo "Static IP configuration has been applied."