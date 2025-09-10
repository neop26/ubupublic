# Moved from install-scripts: docker.sh (ubuntu-specific)
#!/bin/bash
# Enhanced Docker installation script with better error handling and feedback

# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi

echo -e "${NOTE} Starting Docker installation..."

# Log the start of installation
{
	echo "===================================================="
	echo "Docker Installation Log - $(date)"
	echo "System: $(lsb_release -ds)"
	echo "Kernel: $(uname -r)"
	echo "===================================================="
} >> "$LOG"

# Check for existing Docker installation
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

# Make sure required packages are installed
echo -e "${NOTE} Installing Docker prerequisites..."
install_packages curl apt-transport-https ca-certificates gnupg lsb-release

# Ask for installation method
echo -e "${ACTION} Select Docker installation method:"
echo "1) Use Docker's convenience script (recommended)"
echo "2) Add Docker's official repository manually"

case $docker_method in
	2)
		# Manual repository setup
		echo -e "${NOTE} Setting up Docker repository..."
    
		# Add Docker's official GPG key
		echo -e "${NOTE} Adding Docker's GPG key..."
		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> "$LOG" 2>&1
    
		# Add the repository
		echo -e "${NOTE} Adding Docker repository..."
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >> "$LOG" 2>&1
    
		# Update package index
		sudo apt update >> "$LOG" 2>&1
    
		# Install Docker packages
		echo -e "${NOTE} Installing Docker packages..."
		install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
		;;
	*)
		# Use convenience script (default)
		echo -e "${NOTE} Downloading Docker installation script..."
		download_file "https://get.docker.com" "get-docker.sh"
    
		echo -e "${NOTE} Executing Docker installation script..."
		sudo sh ./get-docker.sh >> "$LOG" 2>&1
    
		if [ $? -ne 0 ]; then
			echo -e "${ERROR} Docker installation failed. Check the log for details: $LOG"
			exit 1
		fi
		;;
esac

# Enable and start Docker service
echo -e "${NOTE} Enabling Docker service to start on boot..."
sudo systemctl enable docker >> "$LOG" 2>&1

echo -e "${NOTE} Starting Docker service..."
sudo systemctl start docker >> "$LOG" 2>&1

# Check if Docker service is running
if check_service docker; then
	echo -e "${OK} Docker service is running correctly."
else
	echo -e "${ERROR} Docker service failed to start. Please check the logs."
	exit 1
fi

# Add current user to the Docker group
echo -e "${NOTE} Adding user '${USER}' to the Docker group..."
sudo usermod -aG docker "$USER" >> "$LOG" 2>&1

# Install Docker Compose
echo -e "${NOTE} Installing Docker Compose..."
install_package docker-compose-plugin

# Verify installations
echo -e "${NOTE} Verifying Docker installation..."
docker --version 2>> "$LOG" || echo -e "${WARN} Docker command not available. You may need to log out and log back in."

echo -e "${NOTE} Verifying Docker Compose installation..."
docker compose version 2>> "$LOG" || echo -e "${WARN} Docker Compose command not available. You may need to log out and log back in."

echo -e "${OK} Docker installation completed!"
echo -e "${WARN} You need to log out and log back in for the Docker group changes to take effect."

# Offer to install Portainer
if ask_yes_no "Would you like to install Portainer for Docker management?" "y"; then
	echo -e "${NOTE} Creating Portainer volume..."
	docker volume create portainer_data >> "$LOG" 2>&1
  
	echo -e "${NOTE} Starting Portainer container..."
	docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest >> "$LOG" 2>&1
  
	if [ $? -eq 0 ]; then
		echo -e "${OK} Portainer installed successfully!"
		echo -e "${NOTE} Access Portainer at https://$(hostname -I | awk '{print $1}'):9443"
	else
		echo -e "${ERROR} Failed to install Portainer. Please check the logs."
	fi
fi

# Clean up
if [ -f "get-docker.sh" ]; then
	echo -e "${NOTE} Cleaning up..."
	rm get-docker.sh
fi

echo -e "${NOTE} Docker installation log saved to: $LOG"
# Moved from install-scripts: docker.sh (ubuntu-specific)
