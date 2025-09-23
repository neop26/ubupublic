#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

release="$(lsb_release -rs)"
release_code="${release//./}"

case "$release_code" in
  2004|2204|2404)
    cuda_key_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${release_code}/x86_64/cuda-keyring_1.1-1_all.deb"
    ;;
  *)
    echo -e "${WARN} Ubuntu release $release is not covered by this NVIDIA installer."
    echo -e "${WARN} Skipping CUDA/NVIDIA package configuration."
    exit 1
    ;;
esac

echo -e "${NOTE} Installing compiler prerequisites..."
install_package gcc

cuda_key_tmp="/tmp/cuda-keyring.deb"
echo -e "${NOTE} Downloading NVIDIA CUDA repository keyring..."
if download_file "$cuda_key_url" "$cuda_key_tmp"; then
  sudo dpkg -i "$cuda_key_tmp" >>"$LOG" 2>&1
  rm -f "$cuda_key_tmp"
else
  echo -e "${ERROR} Unable to download CUDA keyring from $cuda_key_url"
  exit 1
fi

sudo apt-get update >>"$LOG" 2>&1

echo -e "${NOTE} Installing CUDA toolkit packages..."
install_package cuda-toolkit

if apt-cache show nvidia-open >/dev/null 2>&1; then
  echo -e "${NOTE} Installing NVIDIA open driver package..."
  install_package nvidia-open
else
  echo -e "${WARN} Package nvidia-open not available; falling back to ubuntu-drivers autoinstall."
  sudo ubuntu-drivers autoinstall >>"$LOG" 2>&1 || true
fi

echo -e "${NOTE} Configuring NVIDIA Container Toolkit repository..."
container_key="/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
container_key_tmp="/tmp/nvidia-container-toolkit.gpg"
if download_file "https://nvidia.github.io/libnvidia-container/gpgkey" "$container_key_tmp"; then
  sudo gpg --dearmor -o "$container_key" "$container_key_tmp" >>"$LOG" 2>&1
  rm -f "$container_key_tmp"
else
  echo -e "${ERROR} Failed to download NVIDIA container toolkit GPG key."
  exit 1
fi

list_tmp="/tmp/nvidia-container-toolkit.list"
if download_file "https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list" "$list_tmp"; then
  sed "s#deb https://#deb [signed-by=$container_key] https://#" "$list_tmp" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
  rm -f "$list_tmp"
else
  echo -e "${ERROR} Failed to download NVIDIA container repository list."
  exit 1
fi

sudo apt-get update >>"$LOG" 2>&1

echo -e "${NOTE} Installing NVIDIA container toolkit..."
install_package nvidia-container-toolkit

if command_exists nvidia-ctk; then
  sudo nvidia-ctk runtime configure --runtime=docker >>"$LOG" 2>&1 || true
fi

if command_exists systemctl; then
  sudo systemctl restart docker >>"$LOG" 2>&1 || true
fi

echo -e "${OK} NVIDIA driver installation complete."
