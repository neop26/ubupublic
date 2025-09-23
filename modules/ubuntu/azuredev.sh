#!/bin/bash
# Azure development environment setup (Terraform, Azure CLI, Bicep, Neovim, etc.)

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Preparing Azure development environment..."

# Essentials
echo -e "${NOTE} Refreshing APT package index..."
sudo apt-get update >>"$LOG" 2>&1

PREREQ_PACKAGES=(software-properties-common gnupg curl ca-certificates)
if package_available apt-transport-https; then
  PREREQ_PACKAGES+=(apt-transport-https)
else
  echo -e "${NOTE} Skipping apt-transport-https (not required on $(lsb_release -rs))."
fi
install_packages "${PREREQ_PACKAGES[@]}"
ensure_apt_component universe || true

# Terraform via HashiCorp APT repo
echo -e "${NOTE} Adding HashiCorp APT repository for Terraform..."
download_file "https://apt.releases.hashicorp.com/gpg" "/tmp/hashicorp.gpg" && \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg /tmp/hashicorp.gpg >>"$LOG" 2>&1
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
sudo apt-get update >>"$LOG" 2>&1
install_package terraform
terraform -install-autocomplete >>"$LOG" 2>&1 || true

# Azure CLI via Microsoft package repo (.deb config)
echo -e "${NOTE} Adding Microsoft package repository for Azure CLI..."
download_file "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" "/tmp/packages-microsoft-prod.deb"
sudo dpkg -i /tmp/packages-microsoft-prod.deb >>"$LOG" 2>&1
sudo apt-get update >>"$LOG" 2>&1
install_package azure-cli

# Bicep via Azure CLI (no manual binary fetch)
if command_exists az; then
  echo -e "${NOTE} Installing Bicep via Azure CLI..."
  az bicep install >>"$LOG" 2>&1 || true
  az bicep upgrade >>"$LOG" 2>&1 || true
else
  echo -e "${WARN} Azure CLI not detected; skipping Bicep installation"
fi

# Neovim and developer tooling
add_repository ppa:neovim-ppa/unstable
install_packages build-essential cmake ninja-build gettext libtool-bin g++ pkg-config unzip curl neovim

# Configure LazyVim starter as user (no sudo)
NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
  mkdir -p "$NVIM_DIR"
  git clone https://github.com/LazyVim/starter "$NVIM_DIR" >>"$LOG" 2>&1 || true
fi

# PowerShell via Microsoft repo
install_packages dirmngr lsb-release
download_file "https://packages.microsoft.com/keys/microsoft.asc" "/tmp/microsoft.asc"
gpg --dearmor < /tmp/microsoft.asc | sudo tee /usr/share/keyrings/powershell.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/powershell.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/powershell.list >/dev/null
sudo apt-get update >>"$LOG" 2>&1
install_package powershell

# Node.js + npm (from Ubuntu repos by default)
install_packages nodejs npm

# Python pip
install_package python3-pip

# Ansible PPA
add_repository ppa:ansible/ansible
install_package ansible

echo -e "${OK} Azure development environment ready."
