#!/bin/bash

# Exit on any error
set -e

echo "🔄 Updating package list..."
sudo apt update

echo "📦 Installing prerequisites..."
sudo apt install -y wget apt-transport-https software-properties-common

echo "🔑 Downloading Microsoft GPG package..."
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb

echo "📦 Installing Microsoft GPG package..."
sudo dpkg -i packages-microsoft-prod.deb

echo "🔄 Updating package list again..."
sudo apt update

echo "🚀 Installing PowerShell..."
sudo apt install -y powershell

echo "✅ PowerShell installation complete!"
echo "👉 Run PowerShell using the command: pwsh"
