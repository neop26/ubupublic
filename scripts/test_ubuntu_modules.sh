#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SAFE_MODULES=(
  "modules/ubuntu/update.sh",
  "modules/ubuntu/nettools.sh",
  "modules/ubuntu/nodejsinstaller.sh",
  "modules/ubuntu/fix_packages.sh",
  "modules/ubuntu/installpwsh.sh"
)

for module in "${SAFE_MODULES[@]}"; do
  path="$ROOT/$module"
  if [ ! -f "$path" ]; then
    echo "ERROR: Missing module $module" >&2
    exit 1
  fi
  echo "::group::Running $module"
  bash "$path"
  echo "::endgroup::"
done

echo "Ubuntu module smoke run complete."
