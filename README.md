# Ubuntu Setup Builder

A powerful and intuitive setup builder for Ubuntu systems. This toolkit provides a modular approach to system configuration and software installation.

![Ubuntu Setup Builder](https://img.shields.io/badge/Ubuntu-Setup_Builder-orange)
![Version](https://img.shields.io/badge/Version-2.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

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
git clone https://github.com/yourusername/ubupublic.git
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
| Neofetch | Install and configure Neofetch system information tool |
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

```
ubupublic/
├── assets/              # Configuration files and assets
├── install-scripts/     # Individual installation modules
├── config.sh            # Central configuration settings
├── setup.sh             # Main setup script
└── README.md            # Documentation
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

## Changelog

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