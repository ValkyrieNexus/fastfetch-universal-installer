#!/bin/bash

# Universal Fastfetch Auto-Installer and Login Setup
# Automatically detects Linux distribution and installs Fastfetch accordingly
# Supports: Debian/Ubuntu, Arch Linux, Kali Linux, Fedora, openSUSE, and more

set -e

echo "=================================================="
echo "    Universal Fastfetch Auto-Installer"
echo "    Supports multiple Linux distributions"  
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_distro() {
    echo -e "${PURPLE}[DISTRO]${NC} $1"
}

print_detect() {
    echo -e "${CYAN}[DETECT]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

# Function to detect distribution
detect_distro() {
    local distro=""
    local version=""
    local like=""
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro="$ID"
        version="$VERSION_ID"
        like="$ID_LIKE"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        distro="$DISTRIB_ID"
        version="$DISTRIB_RELEASE"
    elif [ -f /etc/redhat-release ]; then
        distro="rhel"
    elif [ -f /etc/arch-release ]; then
        distro="arch"
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    # Convert to lowercase
    distro=$(echo "$distro" | tr '[:upper:]' '[:lower:]')
    
    echo "$distro:$version:$like"
}

# Function to install fastfetch on Debian-based systems
install_debian() {
    print_distro "Installing on Debian-based system..."
    
    print_status "Updating package lists..."
    sudo apt update
    
    # Try official package first
    if sudo apt install -y fastfetch 2>/dev/null; then
        print_success "Fastfetch installed from official repositories"
        return 0
    fi
    
    print_warning "Official package not available, installing from GitHub..."
    sudo apt install -y wget curl
    
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.deb" | cut -d '"' -f 4)
    
    if [ -z "$latest_url" ]; then
        return 1
    fi
    
    wget -O /tmp/fastfetch.deb "$latest_url"
    sudo dpkg -i /tmp/fastfetch.deb || sudo apt install -f -y
    rm -f /tmp/fastfetch.deb
    
    print_success "Fastfetch installed from GitHub"
    return 0
}

# Function to install fastfetch on Arch-based systems
install_arch() {
    print_distro "Installing on Arch-based system..."
    
    print_status "Updating package database..."
    sudo pacman -Sy
    
    # Try official repos first
    if sudo pacman -S --noconfirm fastfetch 2>/dev/null; then
        print_success "Fastfetch installed from official repositories"
        return 0
    fi
    
    # Try AUR helpers
    if command -v yay &> /dev/null; then
        print_status "Using yay to install from AUR..."
        yay -S --noconfirm fastfetch
        return 0
    elif command -v paru &> /dev/null; then
        print_status "Using paru to install from AUR..."
        paru -S --noconfirm fastfetch
        return 0
    fi
    
    # Manual installation
    print_status "Installing manually from GitHub..."
    sudo pacman -S --noconfirm wget curl tar
    
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4)
    
    if [ -z "$latest_url" ]; then
        return 1
    fi
    
    cd /tmp
    wget -O fastfetch.tar.gz "$latest_url"
    tar -xzf fastfetch.tar.gz
    
    local extracted_dir
    extracted_dir=$(tar -tzf fastfetch.tar.gz | head -1 | cut -f1 -d"/")
    cd "$extracted_dir"
    
    sudo cp usr/bin/fastfetch /usr/local/bin/
    [ -f usr/share/man/man1/fastfetch.1 ] && sudo mkdir -p /usr/local/share/man/man1 && sudo cp usr/share/man/man1/fastfetch.1 /usr/local/share/man/man1/
    
    cd / && rm -rf /tmp/fastfetch.tar.gz /tmp/"$extracted_dir"
    print_success "Fastfetch installed manually"
    return 0
}

# Function to install fastfetch on Fedora/RHEL systems
install_fedora() {
    print_distro "Installing on Fedora/RHEL-based system..."
    
    # Determine package manager
    local pkg_manager=""
    if command -v dnf &> /dev/null; then
        pkg_manager="dnf"
    elif command -v yum &> /dev/null; then
        pkg_manager="yum"
    else
        print_error "No supported package manager found"
        return 1
    fi
    
    print_status "Updating package database..."
    sudo $pkg_manager update -y
    
    # Try to install from repos
    if sudo $pkg_manager install -y fastfetch 2>/dev/null; then
        print_success "Fastfetch installed from official repositories"
        return 0
    fi
    
    # Manual installation
    print_status "Installing manually from GitHub..."
    sudo $pkg_manager install -y wget curl tar
    
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4)
    
    if [ -z "$latest_url" ]; then
        return 1
    fi
    
    cd /tmp
    wget -O fastfetch.tar.gz "$latest_url"
    tar -xzf fastfetch.tar.gz
    
    local extracted_dir
    extracted_dir=$(tar -tzf fastfetch.tar.gz | head -1 | cut -f1 -d"/")
    cd "$extracted_dir"
    
    sudo cp usr/bin/fastfetch /usr/local/bin/
    [ -f usr/share/man/man1/fastfetch.1 ] && sudo mkdir -p /usr/local/share/man/man1 && sudo cp usr/share/man/man1/fastfetch.1 /usr/local/share/man/man1/
    
    cd / && rm -rf /tmp/fastfetch.tar.gz /tmp/"$extracted_dir"
    print_success "Fastfetch installed manually"
    return 0
}

# Function to configure shell startup files
configure_shells() {
    print_status "Configuring shell startup files..."
    
    # Configure bash
    if [ -f ~/.bashrc ]; then
        if ! grep -q "fastfetch" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Auto-launch Fastfetch on login" >> ~/.bashrc
            echo "if [[ \$- == *i* ]]; then" >> ~/.bashrc
            echo "    fastfetch" >> ~/.bashrc
            echo "fi" >> ~/.bashrc
            print_success "Added Fastfetch to ~/.bashrc"
        else
            print_warning "Fastfetch already configured in ~/.bashrc"
        fi
    fi
    
    # Configure zsh
    if command -v zsh &> /dev/null; then
        [ ! -f ~/.zshrc ] && touch ~/.zshrc
        if ! grep -q "fastfetch" ~/.zshrc; then
            echo "" >> ~/.zshrc
            echo "# Auto-launch Fastfetch on login" >> ~/.zshrc
            echo "if [[ -o interactive ]]; then" >> ~/.zshrc
            echo "    fastfetch" >> ~/.zshrc
            echo "fi" >> ~/.zshrc
            print_success "Added Fastfetch to ~/.zshrc"
        else
            print_warning "Fastfetch already configured in ~/.zshrc"
        fi
    fi
    
    # Configure fish
    if command -v fish &> /dev/null; then
        mkdir -p ~/.config/fish
        if [ ! -f ~/.config/fish/config.fish ] || ! grep -q "fastfetch" ~/.config/fish/config.fish; then
            echo "" >> ~/.config/fish/config.fish
            echo "# Auto-launch Fastfetch on login" >> ~/.config/fish/config.fish
            echo "if status is-interactive" >> ~/.config/fish/config.fish
            echo "    fastfetch" >> ~/.config/fish/config.fish
            echo "end" >> ~/.config/fish/config.fish
            print_success "Added Fastfetch to fish config"
        else
            print_warning "Fastfetch already configured in fish"
        fi
    fi
    
    return 0
}

# Function to create distribution-specific config
create_config() {
    local distro="$1"
    
    print_status "Creating configuration for $distro..."
    mkdir -p ~/.config/fastfetch
    
    case "$distro" in
        "kali")
            cat > ~/.config/fastfetch/config.jsonc << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "kali_small",
        "color": {
            "1": "white",
            "2": "blue"
        }
    },
    "display": {
        "separator": " ➤ ",
        "color": {
            "keys": "blue",
            "title": "white"
        }
    },
    "modules": [
        {"type": "title", "color": {"user": "blue", "at": "white", "host": "blue"}},
        "separator", "os", "host", "kernel", "uptime", "packages", "shell",
        {"type": "display", "compactType": "original"},
        "de", "wm", "wmtheme", "theme", "icons", "font", "cursor", "terminal", "terminalfont",
        {"type": "cpu", "showPeCoreCount": true},
        {"type": "gpu", "hideType": "integrated"},
        "memory", "swap", {"type": "disk", "folders": ["/", "/home"]},
        "localip", "publicip", "wifi", "battery", "poweradapter", "locale", "break",
        {"type": "colors", "paddingLeft": 2, "symbol": "circle"}
    ]
}
EOF
            ;;
        "arch"|"manjaro"|"endeavouros")
            cat > ~/.config/fastfetch/config.jsonc << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "arch_small"
    },
    "display": {
        "separator": " → ",
        "color": "blue"
    },
    "modules": [
        "title", "separator", "os", "host", "kernel", "uptime", "packages", "shell",
        "display", "de", "wm", "wmtheme", "theme", "icons", "font", "cursor",
        "terminal", "terminalfont", "cpu", "gpu", "memory", "swap", "disk",
        "localip", "battery", "poweradapter", "locale", "break", "colors"
    ]
}
EOF
            ;;
        *)
            cat > ~/.config/fastfetch/config.jsonc << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "auto"
    },
    "display": {
        "separator": " → "
    },
    "modules": [
        "title", "separator", "os", "host", "kernel", "uptime", "packages", "shell",
        "display", "de", "wm", "wmtheme", "theme", "icons", "font", "cursor",
        "terminal", "terminalfont", "cpu", "gpu", "memory", "swap", "disk",
        "localip", "battery", "poweradapter", "locale", "break", "colors"
    ]
}
EOF
            ;;
    esac
    
    print_success "Created configuration for $distro"
}

# Main installation logic
main() {
    print_detect "Detecting Linux distribution..."
    
    local distro_info
    distro_info=$(detect_distro)
    
    local distro
    local version
    local like
    IFS=':' read -r distro version like <<< "$distro_info"
    
    print_detect "Detected: $distro (version: $version)"
    [ -n "$like" ] && print_detect "Based on: $like"
    
    # Install based on distribution
    case "$distro" in
        "debian"|"ubuntu"|"linuxmint"|"pop"|"elementary"|"kali"|"parrot")
            if ! install_debian; then
                print_error "Failed to install Fastfetch on Debian-based system"
                exit 1
            fi
            ;;
        "arch"|"manjaro"|"endeavouros"|"garuda"|"artix")
            if ! install_arch; then
                print_error "Failed to install Fastfetch on Arch-based system"
                exit 1
            fi
            ;;
        "fedora"|"rhel"|"centos"|"rocky"|"almalinux"|"ol")
            if ! install_fedora; then
                print_error "Failed to install Fastfetch on Fedora/RHEL-based system"
                exit 1
            fi
            ;;
        *)
            # Try to determine by ID_LIKE
            case "$like" in
                *"debian"*|*"ubuntu"*)
                    print_warning "Unknown Debian-based distribution, trying Debian method..."
                    if ! install_debian; then
                        print_error "Failed to install Fastfetch"
                        exit 1
                    fi
                    ;;
                *"arch"*)
                    print_warning "Unknown Arch-based distribution, trying Arch method..."
                    if ! install_arch; then
                        print_error "Failed to install Fastfetch"
                        exit 1
                    fi
                    ;;
                *"rhel"*|*"fedora"*)
                    print_warning "Unknown RHEL-based distribution, trying Fedora method..."
                    if ! install_fedora; then
                        print_error "Failed to install Fastfetch"
                        exit 1
                    fi
                    ;;
                *)
                    print_error "Unsupported distribution: $distro"
                    print_error "Please install Fastfetch manually from: https://github.com/fastfetch-cli/fastfetch"
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    # Verify installation
    if ! command -v fastfetch &> /dev/null; then
        print_error "Fastfetch installation failed - binary not found"
        exit 1
    fi
    
    print_success "Fastfetch is now installed!"
    
    # Configure shells
    configure_shells
    
    # Create distribution-specific config
    create_config "$distro"
    
    echo ""
    echo "=================================================="
    print_success "Universal Fastfetch installation completed!"
    echo "=================================================="
    echo ""
    print_distro "Distribution: $distro"
    [ -n "$version" ] && echo "Version: $version"
    echo ""
    echo "Fastfetch has been installed and configured to run on login."
    echo "To test it now, run: fastfetch"
    echo ""
    echo "Configuration file: ~/.config/fastfetch/config.jsonc"
    echo "You can customize it according to your preferences."
    echo ""
    echo "Configured shells:"
    command -v bash &> /dev/null && echo "  ✓ Bash"
    command -v zsh &> /dev/null && echo "  ✓ Zsh"
    command -v fish &> /dev/null && echo "  ✓ Fish"
    echo ""
    echo "The next time you open a new terminal session, Fastfetch will run automatically."
    
    # Special message for Kali
    if [ "$distro" = "kali" ]; then
        echo ""
        print_distro "🐉 Kali Linux detected - Happy ethical hacking!"
    fi
}

# Run main function
main "$@"