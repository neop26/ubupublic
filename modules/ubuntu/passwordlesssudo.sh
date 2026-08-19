#!/bin/bash
# Enable passwordless sudo for the current user.
#
# SECURITY: this makes any shell as this user effectively root. It is only
# defensible when SSH is key-only, so this module refuses to proceed while
# password authentication is still accepted unless explicitly overridden.
#
# Note on the "scoped" option: allowing apt, systemctl or docker without a
# password is NOT a hard security boundary - each can be used to obtain root.
# Scoping limits accidental damage, not a determined attacker who already has
# your private key.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

SUDOERS_FILE="/etc/sudoers.d/90-${USER}-nopasswd"

echo -e "${NOTE} Configuring passwordless sudo for '${USER}'..."

if [ "${CI:-}" = "true" ]; then
  echo -e "${NOTE} CI detected; skipping."
  exit 0
fi

# --- Gate 1: SSH must be key-only ---
PW_AUTH="$(sudo sshd -T 2>/dev/null | awk '/^passwordauthentication /{print $2}')"
echo -e "${NOTE} sshd passwordauthentication = ${PW_AUTH:-unknown}"

if [ "$PW_AUTH" != "no" ]; then
  echo -e "${WARN} ------------------------------------------------------------"
  echo -e "${WARN} SSH still accepts passwords."
  echo -e "${WARN} Passwordless sudo would turn any guessed SSH password into"
  echo -e "${WARN} instant root access on this machine."
  echo -e "${WARN} Run ./modules/ubuntu/sshhardening.sh first and answer 'y'."
  echo -e "${WARN} ------------------------------------------------------------"
  if ! ask_yes_no "Continue anyway (NOT recommended)?" "n"; then
    echo -e "${NOTE} Aborted. Nothing changed."
    exit 1
  fi
fi

# --- Gate 2: a usable key must exist, or you can be locked out of both ---
if [ ! -s "$HOME/.ssh/authorized_keys" ]; then
  echo -e "${ERROR} No authorized_keys found. Add a key before hardening access."
  exit 1
fi

echo
echo -e "${ACTION} Choose a scope:"
echo "  1) Full        - NOPASSWD for all commands (simplest)"
echo "  2) Scoped      - NOPASSWD for common admin tooling (recommended)"
echo "  3) Cache only  - keep prompts, extend the timeout to 60 minutes"
read -r -p "Choose [1/2/3] (default 2): " scope
scope="${scope:-2}"

TMP="$(mktemp)"
case "$scope" in
  1)
    printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$USER" > "$TMP"
    DESC="full passwordless sudo"
    ;;
  3)
    printf 'Defaults:%s timestamp_timeout=60\n' "$USER" > "$TMP"
    DESC="60 minute sudo credential cache"
    ;;
  *)
    # sudoers forbids wildcards in command ARGUMENTS, only the command path may
    # be globbed. Bare commands are listed; argument restriction is not possible
    # here without a wrapper script.
    cat > "$TMP" <<EOF
# Scoped passwordless sudo for $USER - managed by ubupublic
$USER ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg
$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/journalctl
$USER ALL=(ALL) NOPASSWD: /usr/sbin/ufw
$USER ALL=(ALL) NOPASSWD: /usr/sbin/lvextend, /usr/sbin/lvs, /usr/sbin/vgs, /usr/sbin/pvs
$USER ALL=(ALL) NOPASSWD: /usr/sbin/resize2fs, /usr/sbin/fstrim
$USER ALL=(ALL) NOPASSWD: /usr/bin/docker
$USER ALL=(ALL) NOPASSWD: /usr/sbin/sshd
$USER ALL=(ALL) NOPASSWD: /usr/bin/hostnamectl, /usr/bin/timedatectl
$USER ALL=(ALL) NOPASSWD: /usr/sbin/netplan
EOF
    DESC="scoped passwordless sudo"
    ;;
esac

echo
echo -e "${NOTE} Proposed $SUDOERS_FILE:"
sed 's/^/    /' "$TMP"
echo

if ! ask_yes_no "Apply this configuration?" "n"; then
  rm -f "$TMP"
  echo -e "${NOTE} Aborted. Nothing changed."
  exit 0
fi

# Validate BEFORE installing: a malformed sudoers file breaks sudo entirely.
if ! sudo visudo -c -f "$TMP" >/dev/null 2>&1; then
  echo -e "${ERROR} sudoers syntax validation failed. Nothing was installed."
  sudo visudo -c -f "$TMP"
  rm -f "$TMP"
  exit 1
fi
echo -e "${OK} Syntax valid."

sudo install -m 0440 -o root -g root "$TMP" "$SUDOERS_FILE"
rm -f "$TMP"

# Re-validate the whole sudoers tree, and roll back if we broke it.
if ! sudo visudo -c >/dev/null 2>&1; then
  echo -e "${ERROR} Global sudoers validation failed. Rolling back."
  sudo rm -f "$SUDOERS_FILE"
  exit 1
fi

echo -e "${OK} Installed $SUDOERS_FILE"

# Verify from a clean credential cache
sudo -k
if sudo -n true 2>/dev/null; then
  echo -e "${OK} Verified: sudo now works without a password ($DESC)."
elif [ "$scope" = "2" ] && sudo -n /usr/bin/systemctl is-system-running >/dev/null 2>&1; then
  echo -e "${OK} Verified: scoped commands work without a password ($DESC)."
  echo -e "${NOTE} Commands outside the list will still prompt - that is expected."
elif [ "$scope" = "3" ]; then
  echo -e "${OK} Cache timeout applied; you will be prompted once per 60 minutes."
else
  echo -e "${WARN} sudo still prompts. Check for a later file in /etc/sudoers.d that overrides this."
fi

echo -e "\n${NOTE} To revoke:  sudo rm $SUDOERS_FILE"
exit 0
