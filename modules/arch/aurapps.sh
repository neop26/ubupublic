#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

yay_install() {
  local description="$1"
  shift
  if [ "$#" -eq 0 ]; then
    return 0
  fi
  echo -e "${NOTE} Installing $description (${*}) via yay"
  if yay -S --needed --noconfirm "$@" >>"$LOG" 2>&1; then
    echo -e "${OK} Installed $description"
    return 0
  fi
  echo -e "${ERROR} Failed to install $description"
  return 1
}

echo -e "${NOTE} Checking for yay AUR helper..."
if ! command_exists yay; then
  echo -e "${ERROR} This module requires the 'yay' AUR helper. Install it before continuing."
  exit 1
fi

echo -e "${NOTE} Updating system packages via yay"
yay -Syu --noconfirm >>"$LOG" 2>&1

yay_install "Visual Studio Code (stable)" visual-studio-code-bin

yay_install "Visual Studio Code (Insiders)" visual-studio-code-insiders-bin

yay_install "Microsoft Edge" microsoft-edge-stable-bin

yay_install "Remmina and FreeRDP" remmina freerdp

yay_install "Spotify" spotify

yay_install "Discord" discord

yay_install "npm" npm

yay_install "Azure CLI" azure-cli

yay_install "PowerShell" powershell-bin

echo -e "${NOTE} Installing Termius (AUR, fallback to Flatpak if unavailable)"
if ! yay -S --needed --noconfirm termius-appimage >>"$LOG" 2>&1; then
  echo -e "${WARN} Termius AUR package unavailable; falling back to Flatpak"
  yay_install "Flatpak" flatpak
  if ! command_exists flatpak; then
    echo -e "${ERROR} Flatpak installation failed; cannot install Termius"
  else
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >>"$LOG" 2>&1 || true
    if flatpak install -y flathub com.termius.Termius >>"$LOG" 2>&1; then
      echo -e "${OK} Termius installed via Flatpak"
    else
      echo -e "${ERROR} Failed to install Termius via Flatpak"
    fi
  fi
else
  echo -e "${OK} Termius installed via AUR"
fi

yay_install "Citrix Workspace" icaclient

yay_install "Citrix localization packs" icaclient-nls

echo -e "${NOTE} Configuring Git credential storage with libsecret"
if yay_install "libsecret credential helper" libsecret gnome-keyring; then
  git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
  echo -e "${OK} Git credential helper configured"
else
  echo -e "${WARN} libsecret helper installation failed; Git credential helper not configured"
fi

echo -e "${OK} Desktop applications module completed."