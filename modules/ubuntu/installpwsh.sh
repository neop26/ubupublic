#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
# Exit on any error
set -e

echo -e "${NOTE} Updating package list..."
sudo apt-get update >>"$LOG" 2>&1

echo -e "${NOTE} Installing prerequisites..."
install_packages wget apt-transport-https software-properties-common

echo -e "${NOTE} Downloading Microsoft package metadata..."
download_file "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" "/tmp/packages-microsoft-prod.deb"

echo -e "${NOTE} Installing Microsoft package metadata..."
sudo dpkg -i /tmp/packages-microsoft-prod.deb >>"$LOG" 2>&1

echo -e "${NOTE} Refreshing package list..."
sudo apt-get update >>"$LOG" 2>&1

echo -e "${NOTE} Installing PowerShell..."
install_package powershell

echo -e "${OK} PowerShell installation complete. Run it with: pwsh"
