# Universal Linux Setup Builder

A powerful, modular setup builder for Ubuntu and Arch Linux systems. This toolkit provides a modular approach to system configuration and software installation.

| Badges | | | |
|--------|-|-|-|
| ![Universal Setup Builder](https://img.shields.io/badge/Linux-Setup_Builder-orange?style=for-the-badge&logo=linux) | ![Version](https://img.shields.io/badge/Version-2.2.0-blue?style=for-the-badge) | ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge) | [![Smoke](https://github.com/neop26/ubupublic/actions/workflows/smoke.yml/badge.svg)](https://github.com/neop26/ubupublic/actions/workflows/smoke.yml) |
| [![GitHub stars](https://img.shields.io/github/stars/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/stargazers) | [![GitHub forks](https://img.shields.io/github/forks/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/network) | [![GitHub issues](https://img.shields.io/github/issues/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/issues) | [![GitHub pull requests](https://img.shields.io/github/issues-pr/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/pulls) |
| [![GitHub last commit](https://img.shields.io/github/last-commit/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/commits/main) | [![GitHub contributors](https://img.shields.io/github/contributors/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/graphs/contributors) | [![GitHub repo size](https://img.shields.io/github/repo-size/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic) | |
| [![Bash](https://img.shields.io/badge/Bash-4.0+-black?style=for-the-badge&logo=gnu-bash)](https://www.gnu.org/software/bash/) | [![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04+-E95420?style=for-the-badge&logo=ubuntu)](https://ubuntu.com/) | [![Arch Linux](https://img.shields.io/badge/Arch-rolling-1793d1?style=for-the-badge&logo=arch-linux)](https://archlinux.org/) | |

## Architecture Overview

```mermaid
flowchart TD
    subgraph "Ubuntu Setup Builder"
        %% User Interface Layer
        subgraph "User Interface Layer"
            U["User"]:::user
        end

        %% Control Layer
        subgraph "Control Layer"
            ISE["Interactive Setup Engine [setup.sh]"]:::engine
        end

        %% Configuration & Assets Layer
        subgraph "Configuration & Assets Layer"
            CM["Configuration Manager [config.sh]"]:::config
            AS["Assets [assets/]"]:::config
        end

        %% Module Layer
        subgraph "Module Layer"
            IM["Installation Modules [modules/<os>/*]"]:::module
            GF["Global Functions [Global_functions.sh]"]:::global
        end

        %% Support/Logging Layer
        subgraph "Support/Logging Layer"
            Log["Logging & Diagnostics [Install-Logs]"]:::logging
            Arch["Archived Scripts [_archived/]"]:::archived
        end

        %% External Dependencies
        subgraph "External Dependencies"
            APT["APT/External Repos"]:::external
        end
    end

    %% Relationships
    U -->|"selects"| ISE
    ISE -->|"reads"| CM
    CM -->|"loads"| AS
    ISE -->|"executes"| IM
    IM -->|"sources"| GF
    IM -->|"logs"| Log
    GF -->|"reports"| Log
    IM -->|"fetches"| APT

    %% Click Events
    click ISE "https://github.com/neop26/ubupublic/blob/main/setup.sh"
    click CM "https://github.com/neop26/ubupublic/blob/main/config.sh"
    click AS "https://github.com/neop26/ubupublic/tree/main/assets/"
    click IM "https://github.com/neop26/ubupublic/tree/main/modules/"
    click GF "https://github.com/neop26/ubupublic/blob/main/core/Global_functions.sh"
    click Arch "https://github.com/neop26/ubupublic/tree/main/_archived/"
    

    %% Styles
    classDef user fill:#cce5ff,stroke:#333,stroke-width:2px;
    classDef engine fill:#ffcccc,stroke:#333,stroke-width:2px;
    classDef config fill:#ccffcc,stroke:#333,stroke-width:2px;
    classDef module fill:#ccccff,stroke:#333,stroke-width:2px;
    classDef global fill:#e0ccff,stroke:#333,stroke-width:2px;
    classDef logging fill:#ffffcc,stroke:#333,stroke-width:2px;
    classDef archived fill:#ffcc99,stroke:#333,stroke-width:2px;
    classDef utility fill:#ccffff,stroke:#333,stroke-width:2px;
    classDef external fill:#d9d9d9,stroke:#333,stroke-width:2px;
```

## Features

- Modular installers for Ubuntu and Arch powered by shared helpers
- Interactive menu-driven workflow with consistent logging
- Hardened package handling (idempotent installs, no curl | bash shortcuts)
- Detailed per-run logs written to `Install-Logs/`
- Tested combinations for Ubuntu 20.04/22.04/24.04 and Arch Linux
- Automated smoke checks via GitHub Actions to prevent regressions

## Installation

Clone the repository:

```bash
git clone https://github.com/neop26/ubupublic.git
cd ubupublic
chmod +x setup.sh
```

## Usage

Run the main setup script:

```bash
./setup.sh
```

Follow the interactive prompts to select the modules you want to install.

## Available Modules

| Module | Description |
|--------|-------------|
| System Update | Update system packages and install essential tools |
| ZSH | Install ZSH with Oh-My-ZSH configuration |
| Network Tools | Install network diagnostic and management tools |
| Fonts | Install recommended font packages |
| Fastfetch | Install and configure Fastfetch system information tool |
| Azure Dev | Setup Azure development environment (partial on Arch) |
| Docker | Install Docker and Docker Compose |
| NVIDIA Drivers | Install NVIDIA drivers for GPU support |
| Static IP | Configure static IP address (Arch: manual guidance) |
| Cockpit | Setup Cockpit web management console |
| Git Config | Configure Git settings |
| Node.js | Install Node.js and npm |
| Apache | Install Apache web server |
| Create User | Create a new user account |
| PowerShell | Install PowerShell (Ubuntu). Arch: AUR guidance |

## Customization

### Adding New Modules

1. Create a new script in `modules/<os>/` (e.g., `modules/ubuntu/mytool.sh`)
2. Source the shared helpers: `source "$REPO_DIR/core/Global_functions.sh"`
3. Add your module to the `MODULES` array in `setup.sh`

### Configuration

Edit the `config.sh` file to customize default settings.

## Directory Structure

```text
ubupublic/
|-- assets/               # Static configs, images, branding, etc.
|-- core/                 # Shared functions/utilities (logging, prompts, etc.)
|-- modules/
|   |-- ubuntu/           # Ubuntu-specific install modules
|   `-- arch/             # Arch-specific install modules
|-- scripts/              # Validation helpers (smoke/tests)
|-- config.sh             # Canonical configuration (sourced by all scripts)
|-- setup.sh              # Main entrypoint (OS detection, menu, orchestration)
|-- _archived/           # Legacy scripts, not loaded by default
`-- README.md
```

## Logging

All installation logs are stored in the `Install-Logs` directory with timestamps for easy troubleshooting.

## Dependencies

- Ubuntu (20.04/22.04/24.04) or Arch Linux (rolling)
- Bash 4.0+
- Internet connection for package downloads

## Credits

This project was inspired by [JaKooLit](https://github.com/JaKooLit/Debian-Hyprland) scripts for deploying Hyprland on Debian and other distributions.

## License

MIT - see `LICENSE`.

## CI & Tests

- `smoke` job: runs `bash scripts/smoke.sh` to verify module manifests, syntax, and sourcing
- `ubuntu-modules` job: runs `bash scripts/test_ubuntu_modules.sh` against a safe subset on `ubuntu-latest`
- Local smoke: `bash scripts/smoke.sh`
- Local Ubuntu module sampler: `bash scripts/test_ubuntu_modules.sh`
## Changelog

### v2.2.0 - 2025-09-22
- Consolidated helpers into `core/Global_functions.sh`; removed duplicates
- Canonicalized `config.sh` and directory paths
- Completed migration to `modules/<os>/*`; removed legacy `install-scripts/`
- Neofetch deprecated -> Fastfetch module added and used by default
- Hardened installers (no curl-to-bash; better pathing/quoting)
- Added Arch parity modules (update, fastfetch, zsh, docker, etc.)
- Improved `setup.sh` orchestration and messages

### v2.1.0 - 2024-09-11
- Replaced Neofetch with Fastfetch in docs; preliminary module changes

### v2.0.0 - 2024-05-25
- Architecture redesign, interactive menu, logging, modularization


