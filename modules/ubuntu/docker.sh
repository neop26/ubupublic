#!/bin/bash
# Docker installation via Docker's official APT repository.
#
# The 'curl https://get.docker.com | sudo sh' convenience path was removed:
# it pipes an unverified remote script into a root shell.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Starting Docker installation..."

{
        echo "===================================================="
        echo "Docker Installation Log - $(date)"
        echo "System: $(lsb_release -ds)"
        echo "Kernel: $(uname -r)"
        echo "===================================================="
} >> "$LOG"

if command_exists docker; then
        if ask_yes_no "Docker is already installed. Would you like to reinstall it?" "n"; then
                echo -e "${NOTE} Removing existing Docker installation..."
                uninstall_package docker-ce
                uninstall_package docker-ce-cli
                uninstall_package containerd.io
        else
                echo -e "${NOTE} Skipping Docker installation."
                exit 0
        fi
fi

echo -e "${NOTE} Installing Docker prerequisites..."
PREREQ_PACKAGES=(curl ca-certificates gnupg lsb-release)
if package_available apt-transport-https; then
  PREREQ_PACKAGES+=(apt-transport-https)
else
  echo -e "${NOTE} Skipping apt-transport-https (not required on $(lsb_release -rs))."
fi
install_packages "${PREREQ_PACKAGES[@]}"

echo -e "${NOTE} Setting up Docker's official repository..."
sudo install -m 0755 -d /etc/apt/keyrings

echo -e "${NOTE} Adding Docker's GPG key..."
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes 2>>"$LOG"; then
        echo -e "${ERROR} Failed to fetch Docker's GPG key."
        exit 1
fi
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker publishes per-codename; fall back to the latest LTS on newer releases.
CODENAME="$(lsb_release -cs)"
if ! curl -fsSI "https://download.docker.com/linux/ubuntu/dists/${CODENAME}/Release" >/dev/null 2>&1; then
        FALLBACK="noble"
        echo -e "${WARN} No Docker repo for '${CODENAME}'; falling back to '${FALLBACK}'."
        CODENAME="$FALLBACK"
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update >> "$LOG" 2>&1

echo -e "${NOTE} Installing Docker packages..."
install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
        echo -e "${ERROR} Docker package installation failed. See $LOG"
        exit 1
}

echo -e "${NOTE} Enabling Docker service..."
sudo systemctl enable --now docker >> "$LOG" 2>&1

if check_service docker; then
        echo -e "${OK} Docker service is running correctly."
else
        echo -e "${ERROR} Docker service failed to start. Please check the logs."
        exit 1
fi

echo -e "${NOTE} Adding user '${USER}' to the docker group..."
sudo usermod -aG docker "$USER" >> "$LOG" 2>&1

echo -e "${NOTE} Verifying..."
sudo docker --version 2>>"$LOG"
sudo docker compose version 2>>"$LOG"

echo -e "${OK} Docker installation completed."
echo -e "${WARN} Log out and back in for docker group membership to apply."
echo -e "${WARN} Docker manipulates iptables directly and bypasses UFW. Publish"
echo -e "${WARN} container ports on 127.0.0.1, or add rules to the DOCKER-USER chain."

# Portainer install deferred
# NOTE: requires the docker group to be active in your session. After re-login:
#       docker volume create portainer_data
#       docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
#         -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

echo -e "${NOTE} Docker installation log saved to: $LOG"
exit 0
