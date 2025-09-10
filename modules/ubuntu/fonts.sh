#!/bin/bash
# Enhanced Fonts Installation Script

# Source the global functions
SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi

# Define the fonts to install
fonts=(
	fonts-firacode
	fonts-font-awesome
	fonts-noto
	fonts-noto-cjk
	fonts-noto-color-emoji
)

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"

# Create log header
{
	echo "===================================================="
	echo "Font Installation Log - $(date)"
	echo "System: $(lsb_release -ds)"
	echo "===================================================="
} >> "$LOG"

	# Source the global functions using absolute path
	SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
	if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
		source "$SCRIPT_DIR/Global_functions.sh"
	fi
# Check for any broken packages before installation
echo -e "${NOTE} Checking for broken packages..."
sudo apt-get check >> "$LOG" 2>&1 || {
	echo -e "${WARN} Found broken packages, attempting to fix..."
	sudo apt-get --fix-broken install -y >> "$LOG" 2>&1
}

# Install each font package one by one
for font in "${fonts[@]}"; do
	echo -e "${NOTE} Installing $font..."
  
	# Try to install with apt directly - more reliable than the function for fonts
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$font" >> "$LOG" 2>&1
  
	if [ $? -eq 0 ]; then
		echo -e "${OK} Successfully installed $font"
	else
		echo -e "${WARN} Failed to install $font, continuing with next package..."
	fi
done

# Download and install JetBrains Mono Nerd Font (if needed)
if [ ! -d ~/.local/share/fonts/JetBrainsMonoNerd ]; then
	echo -e "${NOTE} Setting up JetBrains Mono Nerd Font..."
  
	# Create font directory
	mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
  
	# Download JetBrains Mono
	echo -e "${NOTE} Downloading JetBrains Mono Nerd Font..."
  
	# Use curl instead of wget for more reliability
	JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  
	if ! curl -L --progress-bar "$JETBRAINS_URL" -o "$SCRIPT_DIR/JetBrainsMono.tar.xz"; then
		echo -e "${ERROR} Failed to download JetBrains Mono font"
	else
		echo -e "${OK} Downloaded JetBrains Mono font"
    
		# Extract the font
		echo -e "${NOTE} Extracting JetBrains Mono font..."
		if ! tar -xJf "$SCRIPT_DIR/JetBrainsMono.tar.xz" -C ~/.local/share/fonts/JetBrainsMonoNerd; then
			echo -e "${ERROR} Failed to extract JetBrains Mono font"
		else
			echo -e "${OK} Extracted JetBrains Mono font"
      
			# Update font cache
			echo -e "${NOTE} Updating font cache..."
			fc-cache -fv >> "$LOG" 2>&1
      
			# Clean up
			echo -e "${NOTE} Cleaning up..."
			rm -f "$SCRIPT_DIR/JetBrainsMono.tar.xz"
		fi
	fi
else
	echo -e "${NOTE} JetBrains Mono Nerd Font already installed. Skipping..."
fi

echo -e "${OK} Font installation completed!"
# Moved from install-scripts: fonts.sh (ubuntu-specific)
