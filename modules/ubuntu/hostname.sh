#!/bin/bash
# Set the system hostname.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

CURRENT="$(hostname)"
echo -e "${NOTE} Current hostname: ${CURRENT}"

read -r -p "Enter the new hostname for this server: " new_hostname

if [ -z "$new_hostname" ]; then
  echo -e "${NOTE} No hostname entered. Skipping hostname configuration."
  exit 0
fi

# RFC 1123: letters, digits and hyphens; must not start or end with a hyphen.
if ! [[ "$new_hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
  echo -e "${ERROR} Invalid hostname. Use letters, digits and hyphens only (max 63 chars)."
  exit 1
fi

if ! sudo hostnamectl set-hostname "$new_hostname"; then
  echo -e "${ERROR} Failed to set hostname."
  exit 1
fi

# Keep /etc/hosts consistent, otherwise sudo warns about unresolved host
if grep -qE "^127\.0\.1\.1\s" /etc/hosts; then
  sudo sed -i -E "s/^(127\.0\.1\.1\s+).*/\1${new_hostname}/" /etc/hosts
else
  echo "127.0.1.1 ${new_hostname}" | sudo tee -a /etc/hosts >/dev/null
fi

echo -e "${OK} Hostname set to ${new_hostname} (was ${CURRENT})."
echo -e "${NOTE} /etc/hosts updated. Open a new shell to see the change in your prompt."
exit 0
