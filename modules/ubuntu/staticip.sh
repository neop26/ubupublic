#!/bin/bash
# Configure a static IP address via netplan.
#
# NOTE: 'gateway4' was removed from netplan; this writes the supported
# 'routes:' form. The previous version would fail on modern Ubuntu.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

CI_DRY_RUN=false
if [ "${CI:-}" = "true" ]; then
  CI_DRY_RUN=true
  echo -e "${NOTE} CI environment detected; running static IP module in dry-run mode."
fi

echo -e "${WARN} Applying a static IP will drop your SSH session if you get it wrong."
echo -e "${WARN} Prefer running this from the hypervisor console, or use a DHCP reservation."
echo

echo -e "${NOTE} Current interfaces:"
ip -brief address
echo
echo -e "${NOTE} Current default route:"
ip route show default
echo
echo -e "${NOTE} Existing netplan files:"
ls -1 /etc/netplan/ 2>/dev/null
echo

DEFAULT_IFACE="$(ip route show default | awk '/default/{print $5; exit}')"
DEFAULT_GW="$(ip route show default | awk '/default/{print $3; exit}')"
DEFAULT_CIDR="$(ip -o -f inet addr show scope global | awk 'NR==1{print $4}')"
DEFAULT_DNS="$(resolvectl status 2>/dev/null | awk '/Current DNS Server:/{print $4; exit}')"

read -r -p "Network interface [${DEFAULT_IFACE}]: " interface
interface="${interface:-$DEFAULT_IFACE}"
read -r -p "Static IP with prefix [${DEFAULT_CIDR}]: " static_ip
static_ip="${static_ip:-$DEFAULT_CIDR}"
read -r -p "Gateway [${DEFAULT_GW}]: " gateway_ip
gateway_ip="${gateway_ip:-$DEFAULT_GW}"
read -r -p "DNS servers, comma separated [${DEFAULT_DNS}]: " dns_input
dns_input="${dns_input:-$DEFAULT_DNS}"

if [ -z "$interface" ] || [ -z "$static_ip" ] || [ -z "$gateway_ip" ]; then
  echo -e "${ERROR} Interface, address and gateway are all required."
  exit 1
fi

if [[ "$static_ip" != */* ]]; then
  echo -e "${ERROR} Address must include a prefix, e.g. 192.168.1.240/24"
  exit 1
fi

# Build the YAML DNS list
dns_yaml=""
IFS=',' read -ra dns_arr <<< "$dns_input"
for d in "${dns_arr[@]}"; do
  d="$(echo "$d" | xargs)"
  [ -n "$d" ] && dns_yaml="${dns_yaml}          - ${d}"$'\n'
done

TARGET="/etc/netplan/99-static.yaml"

# Disable any existing netplan config so two files cannot conflict.
for existing in /etc/netplan/*.yaml; do
  [ -e "$existing" ] || continue
  [ "$existing" = "$TARGET" ] && continue
  echo -e "${NOTE} Disabling existing config: $existing"
  sudo cp "$existing" "${existing}.backup-$(date +%Y%m%d-%H%M%S)"
  sudo mv "$existing" "${existing}.disabled"
done

echo -e "${NOTE} Writing $TARGET"
sudo tee "$TARGET" >/dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${interface}:
      dhcp4: false
      addresses:
        - ${static_ip}
      routes:
        - to: default
          via: ${gateway_ip}
      nameservers:
        addresses:
${dns_yaml}
EOF

# netplan warns when these are world readable
sudo chmod 600 "$TARGET"

echo -e "${NOTE} Generated configuration:"
sudo cat "$TARGET"

if [ "$CI_DRY_RUN" = "true" ]; then
  echo -e "${NOTE} Skipping netplan apply in CI."
  exit 0
fi

if ! sudo netplan generate 2>>"$LOG"; then
  echo -e "${ERROR} netplan generate failed; configuration not applied."
  exit 1
fi

echo -e "${WARN} 'netplan try' will auto-revert after 120s if you lose connectivity."
if ask_yes_no "Apply now with netplan try?" "n"; then
  sudo netplan try --timeout 120
else
  echo -e "${NOTE} Not applied. Run 'sudo netplan try' when ready."
fi

exit 0
