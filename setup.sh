#!/bin/bash
# Advanced Ubuntu Setup Builder
# A modular, powerful and intuitive setup builder

# Ensure the script doesn't proceed if there's an error
set -e

# Source the configuration and global functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Check if config.sh exists, otherwise create it
if [ ! -f "$SCRIPT_DIR/config.sh" ]; then
    echo "Configuration file not found. Creating default configuration..."
    mkdir -p "$SCRIPT_DIR"
    cat > "$SCRIPT_DIR/config.sh" << 'EOL'
#!/bin/bash
# Default configuration
VERSION="2.0.0"
DEFAULT_TIMEZONE="UTC"
ESSENTIAL_PACKAGES=(curl wget git nano)
LOGS_DIR="$(dirname "$(readlink -f "$0")")/Install-Logs"
mkdir -p "$LOGS_DIR"
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")/install-scripts"
ASSETS_DIR="$(dirname "$(readlink -f "$0")")/assets"
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"
EOL
fi

# Source configuration
source "$SCRIPT_DIR/config.sh"

# Check if Global_functions.sh exists
if [ ! -f "$SCRIPT_DIR/install-scripts/Global_functions.sh" ]; then
    echo "Global functions file not found at: $SCRIPT_DIR/install-scripts/Global_functions.sh"
    echo "Please ensure the install-scripts directory exists and contains Global_functions.sh"
    exit 1
fi

# Source global functions
source "$SCRIPT_DIR/install-scripts/Global_functions.sh"

# Function to ask yes/no question (define this before using it)
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]"
    else
        prompt="$prompt [y/N]"
    fi
    
    while true; do
        read -p "$prompt " choice
        choice=${choice:-$default}
        
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Clear the screen and show welcome message
clear
cat << "EOF"
 _   _ _                 _          _____      _               
| | | | |__  _   _ _ __ | |_ _   _ / ____|__ _| |_ _   _ _ __  
| | | | '_ \| | | | '_ \| __| | | | (___ / _` | __| | | | '_ \ 
| |_| | |_) | |_| | | | | |_| |_| |\___ \ (_| | |_| |_| | |_) |
 \___/|_.__/ \__,_|_| |_|\__|\__,_|____/\__,_|\__|\__,_| .__/ 
                                                       |_|     
EOF
echo
echo "Version: $VERSION"
echo "============================================================"
echo "Advanced Ubuntu System Setup Builder"
echo "============================================================"

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${ERROR} This script should not be executed as root!"
    exit 1
fi

# Create needed directories
mkdir -p "$LOGS_DIR"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$ASSETS_DIR"

# Define available modules
MODULES=(
    "update:Update system packages"
    "zsh:Install ZSH with Oh-My-ZSH"
    "nettools:Install network diagnostic tools"
    "fonts:Install recommended fonts"
    "neofetch:Install and configure Neofetch"
    "azuredev:Setup Azure development environment"
    "docker:Install Docker and Docker Compose"
    "nvidiadrivers:Install NVIDIA drivers"
    "staticip:Configure static IP address"
    "cockpit:Setup Cockpit web console"
    "gitconfig:Configure Git settings"
    "nodejsinstaller:Install Node.js and npm"
    "apache2:Install Apache web server"
    "createuser:Create a new user account"
    "installpwsh:Install PowerShell"
)

# Function to display a selection menu
display_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=()
    local choice
    
    echo -e "\n${ACTION} $title"
    echo "============================================================"
    
    for i in "${!options[@]}"; do
        echo "[$((i+1))] ${options[$i]}"
    done
    echo "[A] Select All"
    echo "[N] Select None"
    echo "[D] Done"
    echo "============================================================"
    
    while true; do
        read -p "Enter your selection (separate multiple choices with space): " choices_input
        
        # Split input into array
        IFS=' ' read -ra choices <<< "$choices_input"
        
        # Check if choices contains "A" (Select All)
        if [[ " ${choices[*]} " == *" A "* ]] || [[ " ${choices[*]} " == *" a "* ]]; then
            selected=("${!options[@]}")
            echo -e "${NOTE} All options selected!"
            break
        fi
        
        # Check if choices contains "N" (Select None)
        if [[ " ${choices[*]} " == *" N "* ]] || [[ " ${choices[*]} " == *" n "* ]]; then
            selected=()
            echo -e "${NOTE} No options selected."
            break
        fi
        
        # Check if choices contains "D" (Done)
        if [[ " ${choices[*]} " == *" D "* ]] || [[ " ${choices[*]} " == *" d "* ]]; then
            break
        fi
        
        # Process numeric selections
        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
                # Convert to zero-based index
                selected+=($((choice-1)))
            fi
        done
        
        break
    done
    
    # Return the selected indices
    for index in "${selected[@]}"; do
        echo "$index"
    done
}

# Display module menu
echo -e "${NOTE} Please select which components you want to install:"

# Extract descriptions for display
MODULE_DESCRIPTIONS=()
for module in "${MODULES[@]}"; do
    MODULE_DESCRIPTIONS+=("${module#*:}")
done

# Get selected modules
selected_indices=($(display_menu "Available Modules" "${MODULE_DESCRIPTIONS[@]}"))

# Debug output
echo "Debug: Selected indices: ${selected_indices[*]}"

# Prepare for execution
if [ ${#selected_indices[@]} -gt 0 ]; then
    echo -e "${NOTE} Ready to install the following components:"
    for index in "${selected_indices[@]}"; do
        module_name="${MODULES[$index]%%:*}"
        module_desc="${MODULES[$index]#*:}"
        echo -e "  - $module_desc"
    done
    
    # Confirm installation
    if ask_yes_no "Do you want to proceed with installation?" "y"; then
        # Execute selected modules
        for index in "${selected_indices[@]}"; do
            module_name="${MODULES[$index]%%:*}"
            module_desc="${MODULES[$index]#*:}"
            
            echo -e "\n${ACTION} Installing: $module_desc"
            script_path="$SCRIPTS_DIR/${module_name}.sh"
            
            # Check if script exists and is executable
            if [ -f "$script_path" ]; then
                # Make sure script is executable
                chmod +x "$script_path"
                
                # Execute the script
                "$script_path" || echo -e "${ERROR} Failed to execute: $script_path"
            else
                echo -e "${WARN} Script not found: $script_path"
                echo "Looked for: $script_path"
                ls -la "$SCRIPTS_DIR"
            fi
        done
        
        # Clean up
        if [ -e "JetBrainsMono.tar.xz" ]; then
            echo -e "${NOTE} Cleaning up temporary files..."
            rm JetBrainsMono.tar.xz
        fi
        
        echo -e "\n${OK} Setup completed successfully!"
        
        # Show system information
        if command -v neofetch &> /dev/null; then
            neofetch
        else
            echo -e "\n${NOTE} System Information:"
            echo "Hostname: $(hostname)"
            echo "Distribution: $(lsb_release -ds 2>/dev/null || echo 'Unknown')"
            echo "Kernel: $(uname -r)"
            echo "Architecture: $(uname -m)"
            echo "CPU: $(grep -m 1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//' || echo 'Unknown')"
            echo "Memory: $(free -h 2>/dev/null | awk '/Mem:/ {print $2}' || echo 'Unknown')"
            echo "Disk Space: $(df -h / 2>/dev/null | awk 'NR==2 {print $2}' || echo 'Unknown')"
        fi
    else
        echo -e "${NOTE} Installation canceled."
    fi
else
    echo -e "${NOTE} No modules selected. Exiting."
fi

echo -e "${NOTE} Thank you for using the Ubuntu Setup Builder!"
