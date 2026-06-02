# Universal Fastfetch Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Tested](https://img.shields.io/badge/Tested-100%25-brightgreen.svg)](#validation)

A universal installer script that detects your Linux distribution and installs [Fastfetch](https://github.com/fastfetch-cli/fastfetch) with distribution-specific configuration and auto-launch setup.

## Features

- Auto-detection of Linux distribution and version
- Support across major Linux distributions
- Distribution-specific configurations (Kali dragon theme, Arch blue theme, etc.)
- Configures Bash, Zsh, and Fish shells automatically
- Multiple installation methods for compatibility
- Built-in safety checks and error handling
- Works out of the box with sensible defaults

## Supported Distributions

### Primary Support
- **Debian-based**: Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary OS, Kali Linux, Parrot OS
- **Arch-based**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, Artix Linux  
- **Red Hat-based**: Fedora, RHEL, CentOS, Rocky Linux, AlmaLinux, Oracle Linux
- **SUSE-based**: openSUSE (Leap/Tumbleweed), SLES

### Installation Methods
1. Official repositories (preferred)
2. AUR (Arch User Repository) - for Arch-based systems
3. GitHub releases (fallback) - latest official releases

## Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/ValkyrieNexus/fastfetch-universal-installer/main/install-fastfetch-universal.sh | bash
```

### Manual Installation

```bash
# Download the installer
wget https://raw.githubusercontent.com/ValkyrieNexus/fastfetch-universal-installer/main/install-fastfetch-universal.sh

# Make it executable
chmod +x install-fastfetch-universal.sh

# Run the installer
./install-fastfetch-universal.sh
```

## What It Does

1. **Detection phase**
   - Detects your Linux distribution and version
   - Identifies available package managers
   - Checks system compatibility

2. **Installation phase**  
   - Attempts installation from official repositories
   - Falls back to AUR (Arch systems) or GitHub releases
   - Verifies successful installation

3. **Configuration phase**
   - Configures shell startup files (.bashrc, .zshrc, fish config)
   - Creates distribution-specific Fastfetch themes
   - Sets up auto-launch on terminal startup

4. **Verification phase**
   - Confirms Fastfetch is properly installed
   - Tests configuration validity
   - Provides usage instructions

## Distribution-Specific Themes

### Kali Linux Theme
- Custom dragon logo with blue/white color scheme
- Security-focused module layout
- Network information display
- Penetration testing branding

### Arch Linux Theme  
- Minimalist Arch logo
- Blue color accent theme
- Performance-oriented module selection
- Clean, technical aesthetic

### Universal Theme
- Auto-detects appropriate logo
- Balanced module selection
- Compatible with any distribution
- Sensible defaults for all systems

## Security Features

- **Root prevention**: Refuses to run as root user
- **Input validation**: Validates user inputs and system responses
- **Error handling**: Uses `set -e` for error handling
- **Secure downloads**: Verifies download integrity
- **Cleanup**: Automatic temporary file cleanup
- **No pipe execution**: Avoids pipe-to-bash patterns

## Advanced Usage

### Custom Configuration

After installation, you can customize your Fastfetch configuration:

```bash
# Edit the main configuration
nano ~/.config/fastfetch/config.jsonc

# Test your changes
fastfetch
```

### Manual Shell Configuration

If you want to prevent auto-launch on terminal startup:

```bash
# Remove from .bashrc
sed -i '/fastfetch/d' ~/.bashrc

# Remove from .zshrc  
sed -i '/fastfetch/d' ~/.zshrc

# Remove from fish config
rm ~/.config/fish/config.fish
```

### Validation

Run the included validator to check script integrity:

```bash
# Download and run validator
wget https://raw.githubusercontent.com/ValkyrieNexus/fastfetch-universal-installer/main/validate-fastfetch-installer.sh
chmod +x validate-fastfetch-installer.sh
./validate-fastfetch-installer.sh
```

## Validation Results

The included validator covers:

- Security tests - root prevention, error handling, cleanup
- Function validation - core functions present and working  
- Distribution support - distro detection and support
- Package manager support - apt, pacman, dnf, yum, zypper
- Shell configuration - Bash, Zsh, Fish support
- Syntax validation - bash syntax check

## Repository Structure

```
├── install-fastfetch-universal.sh    # Main universal installer
├── validate-fastfetch-installer.sh   # Validation script
├── install-fastfetch-debian.sh       # Debian-specific installer (legacy)
├── install-fastfetch-arch.sh         # Arch-specific installer (legacy)  
├── install-fastfetch-kali.sh         # Kali-specific installer (legacy)
└── README.md                         # This file
```

## Development

### Requirements
- Bash 4.0+
- Standard Linux utilities: `curl`, `wget`, `grep`, `cut`
- Sudo privileges for package installation

### Testing
```bash
# Run syntax validation
bash -n install-fastfetch-universal.sh

# Run comprehensive validation
./validate-fastfetch-installer.sh

# Test on different distributions (recommended)
docker run -it ubuntu:latest bash
docker run -it archlinux:latest bash
docker run -it fedora:latest bash
```

## FAQ

**Q: Does this work on all Linux distributions?**  
A: The script supports all major Linux distributions. For unsupported distributions, it attempts to use the closest compatible method based on the `ID_LIKE` field.

**Q: Will this break my existing shell configuration?**  
A: No, the script only adds Fastfetch launch code and doesn't modify existing configurations.

**Q: Can I use this on servers?**  
A: Yes, but consider that Fastfetch will run on every login. You can disable auto-launch while keeping Fastfetch available for manual use.

**Q: What if the installation fails?**  
A: The script includes multiple fallback methods. Check the error output, and you can always install Fastfetch manually from the [official repository](https://github.com/fastfetch-cli/fastfetch).

**Q: How do I uninstall?**  
A: Use your distribution's package manager to remove Fastfetch, and remove the configuration lines from your shell startup files.

## Contributing

Contributions are welcome. Please feel free to submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

### Areas for Contribution
- Additional distribution support
- New theme configurations
- Performance optimizations
- Bug fixes and improvements
- Documentation enhancements

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Fastfetch Team](https://github.com/fastfetch-cli/fastfetch) - For creating the system information tool
- Linux community - For feedback and testing
- Contributors who help improve this installer

## Links

- **Fastfetch Repository**: https://github.com/fastfetch-cli/fastfetch
- **Report Issues**: https://github.com/ValkyrieNexus/fastfetch-universal-installer/issues
- **Latest Releases**: https://github.com/ValkyrieNexus/fastfetch-universal-installer/releases
