#!/bin/bash
# Configure the UFW firewall.
#
# Safety: the SSH port is always allowed BEFORE the firewall is enabled, so an
# active session can never be locked out.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Configuring UFW firewall..."

if [ "${CI:-}" = "true" ]; then
  echo -e "${NOTE} CI detected; skipping firewall changes."
  exit 0
fi

install_package ufw || exit 1

# Discover the live SSH port rather than assuming 22.
SSH_PORT="$(sudo sshd -T 2>/dev/null | awk '/^port /{print $2; exit}')"
[ -z "$SSH_PORT" ] && SSH_PORT="$(awk '/^\s*Port\s+/{print $2; exit}' /etc/ssh/sshd_config 2>/dev/null)"
[ -z "$SSH_PORT" ] && SSH_PORT=22
echo -e "${NOTE} Detected SSH port: ${SSH_PORT}"

sudo ufw default deny incoming >>"$LOG" 2>&1
sudo ufw default allow outgoing >>"$LOG" 2>&1

# Allow SSH first. Rate limiting slows brute-force attempts.
echo -e "${NOTE} Allowing SSH on ${SSH_PORT} (rate limited)..."
sudo ufw limit "${SSH_PORT}/tcp" comment 'SSH' >>"$LOG" 2>&1

# Restrict management and service ports to the local network only.
LAN_CIDR="$(ip -o -f inet addr show scope global | awk 'NR==1{print $4}' | \
  awk -F/ '{split($1,o,"."); print o[1]"."o[2]"."o[3]".0/"$2}')"
echo -e "${NOTE} Detected LAN: ${LAN_CIDR:-unknown}"

if systemctl is-active --quiet cockpit.socket 2>/dev/null; then
  if [ -n "$LAN_CIDR" ] && ask_yes_no "Restrict Cockpit (9090) to ${LAN_CIDR}?" "y"; then
    sudo ufw allow from "$LAN_CIDR" to any port 9090 proto tcp comment 'Cockpit (LAN only)' >>"$LOG" 2>&1
  else
    sudo ufw allow 9090/tcp comment 'Cockpit' >>"$LOG" 2>&1
  fi
fi

if command_exists docker; then
  echo -e "${WARN} Docker publishes ports directly via iptables and bypasses UFW."
  echo -e "${WARN} Bind containers to 127.0.0.1 or use an explicit DOCKER-USER chain rule."
fi

if ask_yes_no "Allow HTTP/HTTPS (80/443) from anywhere?" "n"; then
  sudo ufw allow 80/tcp comment 'HTTP' >>"$LOG" 2>&1
  sudo ufw allow 443/tcp comment 'HTTPS' >>"$LOG" 2>&1
fi

sudo ufw logging low >>"$LOG" 2>&1

echo -e "${NOTE} Rules staged. Enabling UFW..."
sudo ufw --force enable >>"$LOG" 2>&1

if sudo ufw status verbose; then
  echo -e "${OK} UFW is active."
else
  echo -e "${ERROR} Failed to query UFW status."
  exit 1
fi

echo -e "${NOTE} Your current SSH session remains open; SSH was allowed before enabling."
exit 0
