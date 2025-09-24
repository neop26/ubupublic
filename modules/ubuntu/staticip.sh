#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

CI_DRY_RUN=false
if [ "${CI:-}" = "true" ]; then
  CI_DRY_RUN=true
  echo -e "${NOTE} CI environment detected; running static IP module in dry-run mode."
fi
# Script to configure a static IP address on Ubuntu

# Prompt for network interface, static IP, gateway, and DNS
ip a
read -r -p "Enter the network interface name (e.g., eth0): " interface
read -r -p "Enter the static IP address (e.g., 192.168.1.10/24): " static_ip
read -r -p "Enter the gateway IP (e.g., 192.168.1.1): " gateway_ip
read -r -p "Enter the DNS server IP (e.g., 8.8.8.8): " dns_ip

# Backup current netplan configuration
if [ -f /etc/netplan/50-cloud-init.yaml ]; then
  sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.backup
fi

# Generate new netplan configuration
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses:
        - $static_ip
      gateway4: $gateway_ip
      nameservers:
        addresses:
          - $dns_ip
EOF

echo "Static IP configuration has been written to /etc/netplan/01-netcfg.yaml."
if [ "$CI_DRY_RUN" = "true" ]; then
  echo -e "${NOTE} Skipping netplan apply in CI to avoid disrupting networking."
else
  echo "This connection may drop. Reconnect using the new IP address."
  sudo netplan apply
fi
# Moved from install-scripts: staticip.sh (ubuntu-specific)
