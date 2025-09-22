#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
# Exit on any error
set -e

echo "🔄 Updating package list..."
sudo apt-get update >>"$LOG" 2>&1

echo "📦 Installing prerequisites..."
install_packages wget apt-transport-https software-properties-common

echo "🔑 Downloading Microsoft GPG package..."
download_file "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" "/tmp/packages-microsoft-prod.deb"

echo "📦 Installing Microsoft GPG package..."
sudo dpkg -i /tmp/packages-microsoft-prod.deb >>"$LOG" 2>&1

echo "🔄 Updating package list again..."
sudo apt-get update >>"$LOG" 2>&1

echo "🚀 Installing PowerShell..."
install_package powershell

echo "✅ PowerShell installation complete!"
echo "👉 Run PowerShell using the command: pwsh"
# Moved from install-scripts: installpwsh.sh (ubuntu-specific)
