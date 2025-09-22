
#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
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
cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
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
echo "Static IP configuration has been applied."
echo "This connection may drop. Reconnect using the new IP address."
sudo netplan apply
# Moved from install-scripts: staticip.sh (ubuntu-specific)
