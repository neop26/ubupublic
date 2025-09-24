#!/bin/bash
# Install and configure Fastfetch on Ubuntu

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

ensure_apt_component universe || true

echo -e "${NOTE} Installing Fastfetch..."
sudo apt-get update >>"$LOG" 2>&1
FASTFETCH_INSTALLED=false
if install_package fastfetch; then
  FASTFETCH_INSTALLED=true
else
  echo -e "${WARN} fastfetch not available via APT; attempting upstream package..."
  ARCHITECTURE=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
  case "$ARCHITECTURE" in
    amd64)   ASSET="fastfetch-linux-amd64.deb" ;;
    arm64)   ASSET="fastfetch-linux-aarch64.deb" ;;
    armhf)   ASSET="fastfetch-linux-armv7l.deb" ;;
    armel)   ASSET="fastfetch-linux-armv6l.deb" ;;
    ppc64el) ASSET="fastfetch-linux-ppc64le.deb" ;;
    riscv64) ASSET="fastfetch-linux-riscv64.deb" ;;
    s390x)   ASSET="fastfetch-linux-s390x.deb" ;;
    *)       ASSET="" ;;
  esac

  if [ -n "$ASSET" ]; then
    TMP_DEB=$(mktemp /tmp/fastfetch-XXXXXX.deb)
    if download_file "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/$ASSET" "$TMP_DEB"; then
      if sudo dpkg -i "$TMP_DEB" >>"$LOG" 2>&1; then
        FASTFETCH_INSTALLED=true
      else
        echo -e "${WARN} Upstream .deb install failed; attempting dependency fix..."
        sudo apt-get install -f -y >>"$LOG" 2>&1 || true
        if sudo dpkg -i "$TMP_DEB" >>"$LOG" 2>&1; then
          FASTFETCH_INSTALLED=true
        else
          echo -e "${ERROR} Failed to install Fastfetch from upstream .deb package."
        fi
      fi
    else
      echo -e "${ERROR} Failed to download Fastfetch package from upstream (asset: $ASSET)."
    fi
    rm -f "$TMP_DEB"
  else
    echo -e "${WARN} Unsupported architecture ($ARCHITECTURE) for Fastfetch .deb fallback."
  fi
fi

if [ "$FASTFETCH_INSTALLED" != true ]; then
  echo -e "${ERROR} Fastfetch installation could not be completed."
  exit 1
fi

CFG_DIR="$HOME/.config/fastfetch"
CFG_FILE="$CFG_DIR/config.jsonc"

create_directory "$CFG_DIR" 755
if [ -f "$CFG_FILE" ]; then
  backup_file "$CFG_FILE"
fi

if [ -f "$ASSETS_DIR/fastfetchconfig.jsonc" ]; then
  cp "$ASSETS_DIR/fastfetchconfig.jsonc" "$CFG_FILE" >>"$LOG" 2>&1
  echo -e "${OK} Fastfetch configured (${CFG_FILE})"
else
  echo -e "${WARN} Missing asset: $ASSETS_DIR/fastfetchconfig.jsonc"
fi

echo -e "${OK} Fastfetch installation complete."
