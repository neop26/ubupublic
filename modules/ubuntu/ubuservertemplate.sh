#!/bin/bash
# Ubuntu server template orchestrator (modular)

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Launching Ubuntu server template..."

# This template wraps selections similar to setup.sh for quick CT provisioning
modules=(update fonts hostname zsh nettools fastfetch azuredev docker cockpit gitconfig apache2 staticip nvidiadrivers)
echo -e "${NOTE} The following modules will be offered: ${modules[*]}"

selected=()
for m in "${modules[@]}"; do
  if ask_yes_no "Include module: $m?" n; then
    selected+=("$m")
  fi
done

for m in "${selected[@]}"; do
  mod_path="$REPO_DIR/modules/ubuntu/${m}.sh"
  if [ -f "$mod_path" ]; then
    echo -e "${ACTION} Running: $m"
    bash "$mod_path"
  else
    echo -e "${WARN} Missing module: $mod_path"
  fi
done

echo -e "${OK} Server template complete."
