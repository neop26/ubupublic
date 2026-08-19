#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
# Exit on any error
set -e

echo -e "${NOTE} Installing keyring dependencies for secure token storage..."
install_packages gnome-keyring libsecret-1-0 libsecret-tools

echo -e "${NOTE} Installing GitHub Copilot CLI..."
curl -fsSL https://gh.io/copilot-install | bash >>"$LOG" 2>&1

echo -e "${OK} GitHub Copilot CLI installation complete."
echo -e "${NOTE} Run 'copilot' to authenticate. A system keyring is now available for secure token storage."
