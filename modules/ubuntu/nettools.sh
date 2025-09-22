#!/bin/bash
# Install basic network tools on Ubuntu

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

install_packages net-tools nmap traceroute iperf3
