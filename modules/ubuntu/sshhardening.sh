#!/bin/bash
# Harden the SSH server.
#
# IMPORTANT: sshd applies the FIRST occurrence of a keyword, not the last.
# Drop-ins are read in lexical order, so this file must sort BEFORE
# 50-cloud-init.conf (which ships 'PasswordAuthentication yes') or it is
# silently ignored. Hence 01-, not 99-.
#
# Safety: password authentication is only disabled after confirming a usable
# public key exists, and sshd config is validated before reload.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

DROPIN="/etc/ssh/sshd_config.d/01-hardening.conf"
LEGACY_DROPIN="/etc/ssh/sshd_config.d/99-hardening.conf"
CLOUD_INIT_DROPIN="/etc/ssh/sshd_config.d/50-cloud-init.conf"

echo -e "${NOTE} Hardening SSH..."

if [ "${CI:-}" = "true" ]; then
  echo -e "${NOTE} CI detected; skipping SSH hardening."
  exit 0
fi

# --- Pre-flight: is key-based login actually possible? ---
AUTH_KEYS="$HOME/.ssh/authorized_keys"
KEY_COUNT=0
if [ -f "$AUTH_KEYS" ]; then
  KEY_COUNT=$(grep -cE '^(ssh-(rsa|ed25519|dss)|ecdsa-|sk-)' "$AUTH_KEYS" 2>/dev/null || echo 0)
fi
echo -e "${NOTE} Public keys found for ${USER}: ${KEY_COUNT}"

DISABLE_PASSWORDS=false
if [ "$KEY_COUNT" -gt 0 ]; then
  if ask_yes_no "Disable password authentication (key-only login)?" "y"; then
    DISABLE_PASSWORDS=true
  fi
else
  echo -e "${WARN} No authorized_keys entries found."
  echo -e "${WARN} Password authentication will be LEFT ENABLED to avoid locking you out."
fi

# Remove any earlier-named drop-in so the two cannot disagree.
if [ -f "$LEGACY_DROPIN" ]; then
  echo -e "${NOTE} Removing superseded $LEGACY_DROPIN (sorted after cloud-init and had no effect)"
  sudo rm -f "$LEGACY_DROPIN"
fi

# cloud-init re-enables passwords on every boot; neutralise its directive too.
if [ "$DISABLE_PASSWORDS" = true ] && [ -f "$CLOUD_INIT_DROPIN" ]; then
  if sudo grep -qiE '^[[:space:]]*PasswordAuthentication[[:space:]]+yes' "$CLOUD_INIT_DROPIN"; then
    echo -e "${NOTE} Disabling PasswordAuthentication in $(basename "$CLOUD_INIT_DROPIN")"
    sudo cp "$CLOUD_INIT_DROPIN" "${CLOUD_INIT_DROPIN}.backup-$(date +%Y%m%d-%H%M%S)"
    sudo sed -i -E 's/^[[:space:]]*(PasswordAuthentication[[:space:]]+yes)/#\1/I' "$CLOUD_INIT_DROPIN"
  fi
  # Stop cloud-init from regenerating it on the next boot
  if [ -d /etc/cloud/cloud.cfg.d ]; then
    echo 'ssh_pwauth: false' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-pwauth.cfg >/dev/null
  fi
fi

echo -e "${NOTE} Writing $DROPIN"
sudo tee "$DROPIN" >/dev/null <<EOF
# Managed by ubupublic sshhardening.sh - $(date)
# Must sort before 50-cloud-init.conf: sshd honours the first match.
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication $([ "$DISABLE_PASSWORDS" = true ] && echo no || echo yes)
KbdInteractiveAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
AllowAgentForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF
sudo chmod 600 "$DROPIN"

echo -e "${NOTE} Validating sshd configuration..."
if ! sudo sshd -t 2>>"$LOG"; then
  echo -e "${ERROR} sshd config is invalid. Reverting."
  sudo rm -f "$DROPIN"
  exit 1
fi
echo -e "${OK} Configuration is valid."

sudo systemctl reload ssh 2>>"$LOG" || sudo systemctl reload sshd 2>>"$LOG"
echo -e "${OK} SSH reloaded."

# --- Verify the effective setting, not just what we wrote ---
EFFECTIVE=$(sudo sshd -T 2>/dev/null | awk '/^passwordauthentication /{print $2}')
echo -e "\n${NOTE} Effective settings:"
sudo sshd -T 2>/dev/null | grep -Ei '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|maxauthtries|x11forwarding)' | sort

if [ "$DISABLE_PASSWORDS" = true ]; then
  if [ "$EFFECTIVE" = "no" ]; then
    echo -e "\n${OK} Password authentication is disabled and confirmed active."
    echo -e "${WARN} Keep this session open and verify a NEW key-based login before closing it."
  else
    echo -e "\n${ERROR} Requested key-only login but sshd still reports: passwordauthentication=$EFFECTIVE"
    echo -e "${ERROR} Check for another drop-in that sorts earlier than $(basename "$DROPIN")."
    exit 1
  fi
fi

exit 0
