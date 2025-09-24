#!/usr/bin/env bash
# Azure development environment setup (Terraform, Azure CLI, Bicep, Neovim, etc.)
set -euo pipefail

########################################
# Bootstrap & Globals
########################################
export DEBIAN_FRONTEND=noninteractive

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
[ -f "$REPO_DIR/core/Global_functions.sh" ] && source "$REPO_DIR/core/Global_functions.sh" || true

LOG="${LOG:-/var/tmp/azure-dev-setup.log}"
NOTE="${NOTE:-[NOTE]}"
OK="${OK:-[OK]}"
WARN="${WARN:-[WARN]}"
ERR="${ERR:-[ERR]}"

echo -e "${NOTE} Preparing Azure development environment..."
echo -e "${NOTE} Logging to: $LOG"
mkdir -p "$(dirname "$LOG")"
touch "$LOG"

# Helper fallbacks if not provided by Global_functions.sh
command_exists() { command -v "$1" >/dev/null 2>&1; }
package_available() { apt-cache show "$1" >/dev/null 2>&1; }
install_package() { sudo apt-get install -y "$@" >>"$LOG" 2>&1; }
install_packages() { sudo apt-get install -y "$@" >>"$LOG" 2>&1; }
add_repository() { sudo add-apt-repository -y "$1" >>"$LOG" 2>&1; }
ensure_apt_component() { sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) $1" >>"$LOG" 2>&1; }
download_file() { curl -fsSL "$1" -o "$2"; }

retry() {
  local tries="${1}"; shift
  local n=0
  until "$@"; do
    n=$((n+1))
    if [ "$n" -ge "$tries" ]; then return 1; fi
    sleep $((n*2))
  done
}

apt_update() {
  retry 3 sudo apt-get update >>"$LOG" 2>&1 || {
    echo -e "${ERR} apt-get update failed. See $LOG"; return 1; }
}

########################################
# Essentials & Universe
########################################
echo -e "${NOTE} Refreshing APT package index..."
apt_update

PREREQ_PACKAGES=(software-properties-common gnupg curl ca-certificates)
if package_available apt-transport-https; then
  PREREQ_PACKAGES+=(apt-transport-https)
else
  echo -e "${NOTE} Skipping apt-transport-https (not required on $(lsb_release -rs))."
fi
install_packages "${PREREQ_PACKAGES[@]}" || true
ensure_apt_component universe || true

########################################
# HashiCorp APT repo (Terraform)
########################################
echo -e "${NOTE} Adding HashiCorp APT repository for Terraform..."
sudo mkdir -p /usr/share/keyrings
download_file "https://apt.releases.hashicorp.com/gpg" "/tmp/hashicorp.gpg"
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg /tmp/hashicorp.gpg >>"$LOG" 2>&1
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

apt_update
install_package terraform
terraform -install-autocomplete >>"$LOG" 2>&1 || true

########################################
# Microsoft repos — ONE KEYRING to avoid Signed-By conflicts
########################################
echo -e "${NOTE} Configuring Microsoft keyring and unifying repos..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
sudo chmod 0644 /usr/share/keyrings/microsoft-prod.gpg

# Ensure Azure CLI repo uses the unified keyring
AZ_REPO_CODENAME="$(lsb_release -cs)"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/azure-cli/ ${AZ_REPO_CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list >/dev/null

# If a PowerShell repo exists, force it to use the same keyring (prevents microsoft-prod.gpg vs powershell.gpg clashes)
if [ -f /etc/apt/sources.list.d/powershell.list ]; then
  sudo sed -i 's#signed-by=/usr/share/keyrings/powershell.gpg#signed-by=/usr/share/keyrings/microsoft-prod.gpg#' /etc/apt/sources.list.d/powershell.list || true
fi

# If a generic microsoft prod list exists, force same keyring and optionally comment duplicate lines to reduce noise
if [ -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
  sudo sed -i 's#signed-by=/usr/share/keyrings/[^ ]*#signed-by=/usr/share/keyrings/microsoft-prod.gpg#' /etc/apt/sources.list.d/microsoft-prod.list || true
  # Optional: comment the generic prod line to avoid duplicate entries pointing to the same URL
  # sudo sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/microsoft-prod.list
fi

apt_update
install_package azure-cli

########################################
# Bicep via Azure CLI
########################################
if command_exists az; then
  echo -e "${NOTE} Installing/Upgrading Bicep via Azure CLI..."
  az bicep install >>"$LOG" 2>&1 || true
  az bicep upgrade >>"$LOG" 2>&1 || true
else
  echo -e "${WARN} Azure CLI not detected; skipping Bicep installation"
fi

########################################
# Neovim + dev toolchain
########################################
echo -e "${NOTE} Installing Neovim and build tools..."
# Prefer stable PPA; switch to unstable if you really want nightly
if ! grep -q "neovim-ppa/stable" /etc/apt/sources.list.d/* 2>/dev/null; then
  add_repository ppa:neovim-ppa/stable
fi
apt_update
install_packages build-essential cmake ninja-build gettext libtool-bin g++ pkg-config unzip curl neovim

# LazyVim starter (user scope)
NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
  echo -e "${NOTE} Installing LazyVim starter config..."
  git clone https://github.com/LazyVim/starter "$NVIM_DIR" >>"$LOG" 2>&1 || true
fi

########################################
# PowerShell (optional) — uses the SAME keyring
########################################
echo -e "${NOTE} Installing PowerShell..."
# Create/normalize powershell.list to use unified keyring and noble series
POW_CODENAME="$(lsb_release -cs)"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod ${POW_CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/powershell.list >/dev/null

apt_update
install_package powershell || echo -e "${WARN} PowerShell install failed or unavailable on this release."

########################################
# Node.js + npm (Ubuntu repo default; adjust if you want NodeSource)
########################################
echo -e "${NOTE} Installing Node.js and npm..."
install_packages nodejs npm || echo -e "${WARN} Node.js install skipped/failed."

########################################
# Python pip
########################################
echo -e "${NOTE} Installing Python pip..."
install_package python3-pip || echo -e "${WARN} python3-pip install skipped/failed."

########################################
# Ansible PPA (official community PPA)
########################################
echo -e "${NOTE} Adding Ansible PPA and installing Ansible..."
if ! grep -q "ansible/ansible" /etc/apt/sources.list.d/* 2>/dev/null; then
  add_repository ppa:ansible/ansible
fi
apt_update
install_package ansible || echo -e "${WARN} Ansible install skipped/failed."

########################################
# Done
########################################
echo -e "${OK} Azure development environment ready."
