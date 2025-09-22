# Ubuntu Setup Builder

A powerful and intuitive setup builder for Ubuntu systems. This toolkit provides a modular approach to system configuration and software installation.

| Badges | | | |
|--------|-|-|-|
| ![Ubuntu Setup Builder](https://img.shields.io/badge/Ubuntu-Setup_Builder-orange?style=for-the-badge&logo=ubuntu) | ![Version](https://img.shields.io/badge/Version-2.1.0-blue?style=for-the-badge) | ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge) | |
| [![GitHub stars](https://img.shields.io/github/stars/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/stargazers) | [![GitHub forks](https://img.shields.io/github/forks/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/network) | [![GitHub issues](https://img.shields.io/github/issues/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/issues) | [![GitHub pull requests](https://img.shields.io/github/issues-pr/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/pulls) |
| [![GitHub last commit](https://img.shields.io/github/last-commit/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/commits/main) | [![GitHub contributors](https://img.shields.io/github/contributors/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic/graphs/contributors) | [![GitHub repo size](https://img.shields.io/github/repo-size/neop26/ubupublic?style=for-the-badge)](https://github.com/neop26/ubupublic) | |
| [![Bash](https://img.shields.io/badge/Bash-4.0+-black?style=for-the-badge&logo=gnu-bash)](https://www.gnu.org/software/bash/) | [![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04+-E95420?style=for-the-badge&logo=ubuntu)](https://ubuntu.com/) | | |

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
            IM["Installation Modules [install-scripts/*]"]:::module
            GF["Global Functions [Global_functions.sh]"]:::global
        end

        %% Support/Logging Layer
        subgraph "Support/Logging Layer"
            Log["Logging & Diagnostics [Install-Logs]"]:::logging
            Arch["Archived Scripts [_archived/]"]:::archived
            subgraph "Utility Scripts"
                UTIL1["lxcinstaller.sh"]:::utility
                UTIL2["ubuservertemplate.sh"]:::utility
            end
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
    click IM "https://github.com/neop26/ubupublic/tree/main/install-scripts/"
    click GF "https://github.com/neop26/ubupublic/blob/main/core/Global_functions.sh"
    click Arch "https://github.com/neop26/ubupublic/tree/main/_archived/"
    click UTIL1 "https://github.com/neop26/ubupublic/blob/main/lxcinstaller.sh"
    click UTIL2 "https://github.com/neop26/ubupublic/blob/main/ubuservertemplate.sh"

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

- 📦 Modular design for easy customization
- 🛠️ Enhanced error handling and logging
- 🔄 Interactive menu-driven interface
- 📊 Progress indicators for long-running operations
- 📝 Detailed logging of all operations
- 🌐 Support for various Ubuntu versions
- 🔒 Security-focused configurations
- 🚀 Performance optimizations

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
| Azure Dev | Setup Azure development environment |
| Docker | Install Docker and Docker Compose |
| NVIDIA Drivers | Install NVIDIA drivers for GPU support |
| Static IP | Configure static IP address |
| Cockpit | Setup Cockpit web management console |
| Git Config | Configure Git settings |
| Node.js | Install Node.js and npm |
| Apache | Install Apache web server |
| Create User | Create a new user account |
| PowerShell | Install PowerShell for Linux |

## Customization

### Adding New Modules

1. Create a new script file in the `install-scripts` directory
2. Make sure to source the `Global_functions.sh` file
3. Add your module to the `MODULES` array in `setup.sh`

### Configuration

Edit the `config.sh` file to customize default settings.

## Directory Structure

```bash
ubupublic/
├── assets/                # Static configs, images, branding, etc.
├── modules/
│   ├── ubuntu/            # Ubuntu-specific install modules
│   └── arch/              # Arch-specific install modules
├── core/                  # Shared functions/utilities (logging, prompts, etc.)
├── config.sh              # Canonical config (sourced by all scripts)
├── setup.sh               # Main entrypoint (OS detection, menu, orchestration)
├── README.md
└── _archived/             # Legacy scripts, not loaded by default
```

## Logging

All installation logs are stored in the `Install-Logs` directory with timestamps for easy troubleshooting.

## Dependencies

- Ubuntu (tested on 20.04, 22.04, and 24.04)
- Bash 4.0+
- Internet connection for package downloads

## Credits

This project was inspired by [JaKooLit](https://github.com/JaKooLit/Debian-Hyprland) scripts for deploying Hyprland on Debian and other distributions.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Status

- Core utilities consolidated under `core/Global_functions.sh`
- Ubuntu modules live under `modules/ubuntu/`
- Legacy `install-scripts/` retained for reference and will be archived
- Neofetch is deprecated; Fastfetch is the default and supported
- Updated default timezone to Pacific/Auckland
- Enhanced system information display capabilities

### v2.0.0 - 2024-05-25

- Complete architecture redesign
- Added interactive menu system
- Enhanced error handling and logging
- Improved module organization
- Added progress indicators

### v1.1.0 - 2023-12-18

- Added NVIDIA driver installer
- Various bugfixes and improvements

### v1.0.0 - 2023-05-06

- Initial release
- Tested on Ubuntu 23.10 and 24.04
