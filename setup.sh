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

# Source centralized global functions (provides ask_yes_no, install_package, etc.)
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
    "hostname:Set the system hostname"
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
    "copilot:Install GitHub Copilot CLI"
    "ufw:Configure the UFW firewall"
    "sshhardening:Harden the SSH server"
)

# Display module menu
echo -e "${NOTE} Please select which components you want to install:"
echo -e "\n${ACTION} Available Modules"
echo "============================================================"

for i in "${!MODULES[@]}"; do
    module_desc="${MODULES[$i]#*:}"
    printf '[%2d] %s\n' "$((i+1))" "$module_desc"
done
echo " [A] Select all"
echo " [N] Select none"
echo " [Q] Quit"
echo "============================================================"

read -r -p "Enter your selection (numbers separated by spaces, or A): " choices_input

# Tokenised parsing. The previous implementation used substring tests, so any
# input containing the letter 'a' silently selected every module.
selected_indices=()
for token in $choices_input; do
    case "${token,,}" in
        a|all)
            selected_indices=()
            for i in "${!MODULES[@]}"; do selected_indices+=("$i"); done
            echo -e "${NOTE} All modules selected."
            break
            ;;
        n|none)
            selected_indices=()
            echo -e "${NOTE} No modules selected."
            break
            ;;
        q|quit|exit)
            echo -e "${NOTE} Cancelled."
            exit 0
            ;;
        ''|*[!0-9]*)
            echo -e "${WARN} Ignoring invalid entry: '$token'"
            ;;
        *)
            if [ "$token" -ge 1 ] && [ "$token" -le "${#MODULES[@]}" ]; then
                selected_indices+=("$((token-1))")
            else
                echo -e "${WARN} Out of range: '$token'"
            fi
            ;;
    esac
done

# Remove duplicates while preserving menu order
if [ ${#selected_indices[@]} -gt 0 ]; then
    mapfile -t selected_indices < <(printf '%s\n' "${selected_indices[@]}" | sort -n -u)
fi

# Prepare for execution
if [ ${#selected_indices[@]} -gt 0 ]; then
    echo -e "${NOTE} Ready to install the following components:"
    for index in "${selected_indices[@]}"; do
        echo -e "  - ${MODULES[$index]#*:}"
    done

    if ask_yes_no "Do you want to proceed with installation?" "y"; then
        overall_success=true
        failed_modules=()
        set +e
        for index in "${selected_indices[@]}"; do
            module_name="${MODULES[$index]%%:*}"
            module_desc="${MODULES[$index]#*:}"
            echo -e "\n${ACTION} Installing: $module_desc"
            script_path="$SCRIPT_DIR/modules/$OS/${module_name}.sh"
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
