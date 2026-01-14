#!/usr/bin/env bash
# ========================================
# Visuals & Rice Module
# ========================================
# Handles: Fastfetch, Terminal (Kitty/Konsole), KDE Plasma customization
# ========================================

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ========== Fastfetch Setup ==========

setup_fastfetch() {
    print_info "Setting up Fastfetch..."
    
    # Install fastfetch
    if ! command -v fastfetch &> /dev/null; then
        print_info "Installing fastfetch..."
        sudo pacman -S --needed --noconfirm fastfetch
        print_success "Fastfetch installed"
    else
        print_success "Fastfetch already installed"
    fi
    
    # Config will be symlinked via stow
    if [[ -f "${MODULE_DIR}/.config/fastfetch/config.jsonc" ]]; then
        print_info "Custom fastfetch config found (will be symlinked)"
    else
        print_warning "No custom fastfetch config found at .config/fastfetch/config.jsonc"
        print_info "Creating default config directory..."
        mkdir -p "${MODULE_DIR}/.config/fastfetch"
        
        # Create a sample config
        cat > "${MODULE_DIR}/.config/fastfetch/config.jsonc" <<'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "auto",
        "padding": {
            "top": 1,
            "left": 2
        }
    },
    "display": {
        "separator": " → ",
        "color": "blue"
    },
    "modules": [
        {
            "type": "title",
            "format": "{user-name-colored}@{host-name-colored}"
        },
        "separator",
        {
            "type": "os",
            "key": "OS",
            "format": "{3} {12}"
        },
        {
            "type": "kernel",
            "key": "Kernel"
        },
        {
            "type": "packages",
            "key": "Packages"
        },
        {
            "type": "shell",
            "key": "Shell"
        },
        {
            "type": "de",
            "key": "DE"
        },
        {
            "type": "wm",
            "key": "WM"
        },
        {
            "type": "terminal",
            "key": "Terminal"
        },
        {
            "type": "cpu",
            "key": "CPU"
        },
        {
            "type": "gpu",
            "key": "GPU"
        },
        {
            "type": "memory",
            "key": "Memory"
        },
        {
            "type": "disk",
            "key": "Disk (/)"
        },
        {
            "type": "uptime",
            "key": "Uptime"
        },
        "separator",
        "colors"
    ]
}
EOF
        print_success "Created sample fastfetch config"
    fi
}

# ========== Terminal Setup ==========

setup_terminal() {
    print_info "Setting up terminal emulator..."
    
    # Detect preferred terminal or install Kitty
    if command -v kitty &> /dev/null; then
        print_success "Kitty terminal detected"
        TERMINAL="kitty"
    elif command -v konsole &> /dev/null; then
        print_success "Konsole terminal detected"
        TERMINAL="konsole"
    else
        print_info "No preferred terminal found. Installing Kitty..."
        sudo pacman -S --needed --noconfirm kitty
        TERMINAL="kitty"
        print_success "Kitty installed"
    fi
    
    # Setup terminal configs
    case "$TERMINAL" in
        kitty)
            if [[ -f "${MODULE_DIR}/.config/kitty/kitty.conf" ]]; then
                print_info "Custom Kitty config found (will be symlinked)"
            else
                print_info "Creating default Kitty config directory..."
                mkdir -p "${MODULE_DIR}/.config/kitty"
                
                cat > "${MODULE_DIR}/.config/kitty/kitty.conf" <<'EOF'
# Kitty Configuration - Lenovo LOQ

# Font
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.0

# Cursor
cursor_shape block
cursor_blink_interval 0

# Window
window_padding_width 8
remember_window_size yes
enabled_layouts tall,fat,grid,horizontal,vertical

# Tab Bar
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted

# Color Scheme (Catppuccin Mocha)
background #1e1e2e
foreground #cdd6f4
selection_background #585b70
selection_foreground #cdd6f4

# Black
color0 #45475a
color8 #585b70

# Red
color1 #f38ba8
color9 #f38ba8

# Green
color2 #a6e3a1
color10 #a6e3a1

# Yellow
color3 #f9e2af
color11 #f9e2af

# Blue
color4 #89b4fa
color12 #89b4fa

# Magenta
color5 #f5c2e7
color13 #f5c2e7

# Cyan
color6 #94e2d5
color14 #94e2d5

# White
color7 #bac2de
color15 #a6adc8

# Performance
sync_to_monitor yes
enable_audio_bell no

# Shell integration
shell_integration enabled
EOF
                print_success "Created sample Kitty config"
            fi
            ;;
        konsole)
            if [[ -d "${MODULE_DIR}/.local/share/konsole" ]]; then
                print_info "Custom Konsole profiles found (will be symlinked)"
            else
                print_warning "No custom Konsole profiles found"
                print_info "You can export profiles from Konsole settings to .local/share/konsole/"
            fi
            ;;
    esac
}

# ========== KDE Plasma Setup ==========

setup_kde_plasma() {
    print_info "Setting up KDE Plasma customization..."
    
    # Check if we're in KDE
    if [[ "${XDG_CURRENT_DESKTOP:-}" != *"KDE"* ]] && [[ "${DESKTOP_SESSION:-}" != *"plasma"* ]]; then
        print_warning "Not running KDE Plasma. Skipping KDE configuration."
        return 0
    fi
    
    # Install kpackagetool6 if not present
    if ! command -v kpackagetool6 &> /dev/null; then
        print_info "Installing KDE package tools..."
        sudo pacman -S --needed --noconfirm plasma-framework
    fi
    
    # Install recommended KDE tools
    print_info "Installing KDE customization tools..."
    local kde_packages=(
        "plasma-desktop"
        "plasma-workspace"
        "kde-gtk-config"
        "kvantum"
    )
    
    sudo pacman -S --needed --noconfirm "${kde_packages[@]}" 2>&1 | grep -v "warning: .* is up to date" || true
    
    # Install konsave for KDE config backup/restore
    if ! command -v konsave &> /dev/null; then
        print_info "Installing konsave for KDE config management..."
        
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm konsave
        elif command -v paru &> /dev/null; then
            paru -S --needed --noconfirm konsave
        else
            print_warning "No AUR helper found. Install konsave manually:"
            print_info "pip install konsave --user"
        fi
    fi
    
    # Apply KDE settings if konsave profile exists
    if [[ -d "${MODULE_DIR}/kde-configs" ]]; then
        print_info "KDE config backup found. Attempting to restore..."
        
        # Check for konsave profile
        if [[ -f "${MODULE_DIR}/kde-configs/konsave-profile.knsv" ]]; then
            print_info "Importing konsave profile..."
            konsave -i "${MODULE_DIR}/kde-configs/konsave-profile.knsv" || print_warning "Failed to import konsave profile"
        fi
        
        # Manual config copy fallback
        if [[ -d "${MODULE_DIR}/kde-configs/config" ]]; then
            print_info "Copying KDE configs manually..."
            cp -r "${MODULE_DIR}/kde-configs/config/"* "$HOME/.config/" 2>/dev/null || true
            print_success "KDE configs copied"
        fi
    else
        print_info "No KDE configs found. To create a backup:"
        echo -e "  ${CYAN}1.${NC} Customize your KDE Plasma desktop"
        echo -e "  ${CYAN}2.${NC} Run: ${BOLD}konsave -s myprofile${NC}"
        echo -e "  ${CYAN}3.${NC} Run: ${BOLD}konsave -e myprofile${NC}"
        echo -e "  ${CYAN}4.${NC} Move the .knsv file to ${BOLD}${MODULE_DIR}/kde-configs/${NC}"
    fi
    
    # Install KWin scripts/effects
    setup_kwin_scripts
    
    print_success "KDE Plasma setup completed"
}

setup_kwin_scripts() {
    print_info "Checking for KWin scripts..."
    
    # Common useful KWin scripts
    local kwin_scripts=(
        # Add your preferred KWin script package names here
        # Example: "kwin-scripts-forceblur"
    )
    
    if [[ ${#kwin_scripts[@]} -gt 0 ]]; then
        print_info "Installing KWin scripts from AUR..."
        
        for script in "${kwin_scripts[@]}"; do
            if command -v yay &> /dev/null; then
                yay -S --needed --noconfirm "$script" || print_warning "Failed to install $script"
            elif command -v paru &> /dev/null; then
                paru -S --needed --noconfirm "$script" || print_warning "Failed to install $script"
            fi
        done
    fi
    
    # Enable installed KWin scripts
    print_info "You can enable KWin scripts in: System Settings → Window Management → KWin Scripts"
}

# ========== Apply Wallpaper (Optional) ==========

apply_wallpaper() {
    local wallpaper_path="${MODULE_DIR}/wallpapers/default.jpg"
    
    if [[ -f "$wallpaper_path" ]]; then
        print_info "Applying wallpaper..."
        
        if command -v plasma-apply-wallpaperimage &> /dev/null; then
            plasma-apply-wallpaperimage "$wallpaper_path" 2>/dev/null || print_warning "Failed to apply wallpaper"
            print_success "Wallpaper applied"
        else
            print_warning "plasma-apply-wallpaperimage not found. Set wallpaper manually."
        fi
    fi
}

# ========== Main Execution ==========

main() {
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  Visuals & Rice Module - Setup      ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${NC}\n"
    
    setup_fastfetch
    setup_terminal
    setup_kde_plasma
    apply_wallpaper
    
    print_success "Visuals module completed!"
    
    echo -e "\n${YELLOW}${BOLD}Post-installation steps:${NC}"
    echo -e "  • Log out and log back in to apply KDE settings"
    echo -e "  • Run ${BOLD}fastfetch${NC} to test your new config"
    echo -e "  • Customize further in KDE System Settings"
}

main "$@"
