#!/bin/bash
# Universal Linux Setup Builder
# Detects OS (Ubuntu/Arch), loads relevant modules, and orchestrates setup

set -e

# Source the configuration and global functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Require configuration
if [ ! -f "$SCRIPT_DIR/config.sh" ]; then
    echo "[ERROR] config.sh not found at $SCRIPT_DIR."
    exit 1
fi
source "$SCRIPT_DIR/config.sh"

# --- OS Detection ---
OS="unknown"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            OS="ubuntu" ;;
        arch)
            OS="arch" ;;
    esac
elif [ -f /etc/arch-release ]; then
    OS="arch"
fi

if [ "$OS" = "unknown" ]; then
    echo "[ERROR] Unsupported or undetected Linux distribution."
    exit 1
fi

# Source centralized global functions
GLOBAL_FUNCTIONS_PATH="$SCRIPT_DIR/core/Global_functions.sh"
if [ ! -f "$GLOBAL_FUNCTIONS_PATH" ]; then
    echo "[ERROR] Global functions not found at: $GLOBAL_FUNCTIONS_PATH"
    exit 1
fi
source "$GLOBAL_FUNCTIONS_PATH"

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
echo "Universal Linux System Setup Builder ($OS detected)"
echo "============================================================"

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${ERROR} This script should not be executed as root!"
    exit 1
fi

# Create needed directories
mkdir -p "$LOGS_DIR"
mkdir -p "$ASSETS_DIR"

# Define available modules
MODULES=(
    "update:Update system packages"
    "zsh:Install ZSH with Oh-My-ZSH"
    "nettools:Install network diagnostic tools"
    "fonts:Install recommended fonts"
    "fastfetch:Install and configure Fastfetch"
    "azuredev:Setup Azure development environment"
    "aurapps:Install desktop apps from AUR/Flatpak"
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

# (OS detection already completed above)
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

# Display module menu
echo -e "${NOTE} Please select which components you want to install:"

# Display menu and get selection
echo -e "\n${ACTION} Available Modules"
echo "============================================================"

# Display module options
for i in "${!MODULES[@]}"; do
    module_desc="${MODULES[$i]#*:}"
    echo "[$((i+1))] $module_desc"
done
echo "[A] Select All"
echo "[N] Select None"
echo "[D] Done (proceed with selection)"
echo "============================================================"

# Get user selection
read -p "Enter your selection (separate multiple choices with space): " choices_input

# Process selected modules
selected_indices=()

# Check for special options
if [[ "$choices_input" == *"A"* ]] || [[ "$choices_input" == *"a"* ]]; then
    # Select all modules
    for i in "${!MODULES[@]}"; do
        selected_indices+=($i)
    done
    echo -e "${NOTE} All options selected!"
elif [[ "$choices_input" == *"N"* ]] || [[ "$choices_input" == *"n"* ]]; then
    # Select none
    echo -e "${NOTE} No options selected."
elif [[ "$choices_input" == *"D"* ]] || [[ "$choices_input" == *"d"* ]]; then
    # Done with selection - use whatever is already selected
    :
else
    # Process individual selections
    for choice in $choices_input; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#MODULES[@]}" ]; then
            selected_indices+=($((choice-1)))
        fi
    done
fi

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
        overall_success=true
        failed_modules=()
        set +e
        for index in "${selected_indices[@]}"; do
            module_name="${MODULES[$index]%%:*}"
            module_desc="${MODULES[$index]#*:}"
            echo -e "\n${ACTION} Installing: $module_desc"
            if [ "$OS" = "ubuntu" ]; then
                script_path="$SCRIPT_DIR/modules/ubuntu/${module_name}.sh"
            elif [ "$OS" = "arch" ]; then
                script_path="$SCRIPT_DIR/modules/arch/${module_name}.sh"
            fi
            if [ -f "$script_path" ]; then
                chmod +x "$script_path"
                if "$script_path"; then
                    echo -e "${OK} Completed: $module_desc"
                else
                    echo -e "${ERROR} Failed: $script_path (see logs in $LOGS_DIR)"
                    failed_modules+=("$module_desc")
                    overall_success=false
                fi
            else
                echo -e "${WARN} Missing module script: $script_path"
                failed_modules+=("$module_desc (missing script)")
                overall_success=false
            fi
        done
        set -e
        
        # Clean up
        if [ -e "JetBrainsMono.tar.xz" ]; then
            echo -e "${NOTE} Cleaning up temporary files..."
            rm JetBrainsMono.tar.xz
        fi
        
        if [ "$overall_success" = true ]; then
            echo -e "\n${OK} Setup completed successfully!"
        else
            echo -e "\n${ERROR} Setup completed with failures in:"
            for failed in "${failed_modules[@]}"; do
                echo -e "  - $failed"
            done
        fi
        
        if [ "$overall_success" = true ] && command -v fastfetch &> /dev/null; then
            fastfetch
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
        
        if [ "$overall_success" != true ]; then
            exit 1
        fi
    else
        echo -e "${NOTE} Installation canceled."
    fi
else
    echo -e "${NOTE} No modules selected. Exiting."
fi

echo -e "${NOTE} Thank you for using the Universal Linux Setup Builder!"

