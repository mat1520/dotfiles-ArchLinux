#!/usr/bin/env bash
# ========================================
# Spotify Module - Native Installation
# ========================================
# Handles: Spotify (AUR) + Spicetify CLI with permission fixes
# No broken third-party wrappers - direct installation
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
SPOTIFY_DIR="/opt/spotify"
SPICETIFY_DIR="$HOME/.config/spicetify"

# ========== Check AUR Helper ==========

check_aur_helper() {
    print_info "Checking for AUR helper..."
    
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
        print_success "Found yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
        print_success "Found paru"
    else
        print_error "No AUR helper found (yay or paru required)"
        print_info "Installing yay..."
        
        # Install yay
        sudo pacman -S --needed --noconfirm git base-devel
        
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        
        cd - > /dev/null
        rm -rf "$temp_dir"
        
        AUR_HELPER="yay"
        print_success "yay installed"
    fi
}

# ========== Install Spotify ==========

install_spotify() {
    print_info "Installing Spotify from AUR..."
    
    if pacman -Qq spotify &> /dev/null; then
        print_success "Spotify already installed"
    else
        print_info "Installing spotify package..."
        $AUR_HELPER -S --needed --noconfirm spotify
        print_success "Spotify installed"
    fi
}

# ========== Fix Spotify Permissions ==========

fix_spotify_permissions() {
    print_info "Fixing /opt/spotify permissions for Spicetify..."
    
    if [[ ! -d "$SPOTIFY_DIR" ]]; then
        print_error "Spotify directory not found at $SPOTIFY_DIR"
        print_warning "Spotify may not be installed correctly"
        return 1
    fi
    
    # Give user permissions to modify Spotify files
    print_info "Setting ownership to current user..."
    sudo chmod a+wr "$SPOTIFY_DIR"
    sudo chmod a+wr "$SPOTIFY_DIR/Apps" -R
    
    print_success "Spotify permissions fixed"
}

# ========== Install Spicetify CLI ==========

install_spicetify() {
    print_info "Installing Spicetify CLI..."
    
    if command -v spicetify &> /dev/null; then
        print_success "Spicetify already installed"
        return 0
    fi
    
    # Install via AUR (preferred method)
    print_info "Installing spicetify-cli from AUR..."
    $AUR_HELPER -S --needed --noconfirm spicetify-cli
    
    # Verify installation
    if command -v spicetify &> /dev/null; then
        print_success "Spicetify CLI installed"
    else
        print_error "Spicetify installation failed"
        return 1
    fi
}

# ========== Configure Spicetify ==========

configure_spicetify() {
    print_info "Configuring Spicetify..."
    
    # Initialize Spicetify config
    if [[ ! -f "$SPICETIFY_DIR/config-xpui.ini" ]]; then
        print_info "Initializing Spicetify configuration..."
        spicetify || true  # First run creates config
    fi
    
    # Backup Spotify
    print_info "Backing up Spotify..."
    spicetify backup apply
    
    print_success "Spicetify configured"
}

# ========== Install Marketplace ==========

install_marketplace() {
    print_info "Installing Spicetify Marketplace..."
    
    # Install marketplace extension
    if [[ -d "$SPICETIFY_DIR/CustomApps/marketplace" ]]; then
        print_success "Marketplace already installed"
    else
        print_info "Downloading marketplace..."
        
        local marketplace_url="https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/install.sh"
        
        curl -fsSL "$marketplace_url" | sh
        
        if [[ -d "$SPICETIFY_DIR/CustomApps/marketplace" ]]; then
            print_success "Marketplace installed"
        else
            print_warning "Marketplace installation may have failed"
        fi
    fi
}

# ========== Apply Theme ==========

apply_theme() {
    print_info "Applying Spicetify theme..."
    
    # Check if custom theme exists in module
    if [[ -d "${MODULE_DIR}/spicetify-themes" ]]; then
        print_info "Custom theme found. Copying to Spicetify..."
        
        mkdir -p "$SPICETIFY_DIR/Themes"
        cp -r "${MODULE_DIR}/spicetify-themes/"* "$SPICETIFY_DIR/Themes/" 2>/dev/null || true
        
        # Apply the first theme found
        local theme_name=$(ls "${MODULE_DIR}/spicetify-themes" | head -n 1)
        if [[ -n "$theme_name" ]]; then
            print_info "Applying theme: $theme_name"
            spicetify config current_theme "$theme_name"
        fi
    else
        print_info "No custom theme found. Using popular Catppuccin theme..."
        
        # Install Catppuccin theme
        if command -v git &> /dev/null; then
            local themes_dir="$SPICETIFY_DIR/Themes"
            mkdir -p "$themes_dir"
            
            if [[ ! -d "$themes_dir/catppuccin" ]]; then
                git clone https://github.com/catppuccin/spicetify.git "$themes_dir/catppuccin" --depth=1
                print_success "Catppuccin theme downloaded"
            fi
            
            # Apply Catppuccin Mocha
            spicetify config current_theme catppuccin
            spicetify config color_scheme mocha
        else
            print_warning "Git not found. Skipping theme installation."
        fi
    fi
    
    # Apply all changes
    print_info "Applying Spicetify changes..."
    spicetify apply
    
    print_success "Theme applied!"
}

# ========== Enable Extensions ==========

enable_extensions() {
    print_info "Enabling recommended extensions..."
    
    # Enable useful default extensions
    local extensions=(
        "keyboardShortcut.js"
        "shuffle+.js"
    )
    
    for ext in "${extensions[@]}"; do
        if [[ -f "$SPICETIFY_DIR/Extensions/$ext" ]]; then
            spicetify config extensions "$ext"
            print_info "Enabled extension: $ext"
        fi
    done
}

# ========== Verify Installation ==========

verify_installation() {
    print_info "Verifying Spicetify installation..."
    
    if ! command -v spicetify &> /dev/null; then
        print_error "Spicetify command not found!"
        return 1
    fi
    
    echo -e "\n${BOLD}${CYAN}=== Spicetify Status ===${NC}"
    spicetify -v
    
    echo -e "\n${BOLD}${CYAN}=== Current Configuration ===${NC}"
    spicetify config | head -n 10
    
    print_success "Installation verified!"
}

# ========== Create Restore Script ==========

create_restore_script() {
    print_info "Creating quick restore script..."
    
    cat > "${MODULE_DIR}/restore-spicetify.sh" <<'EOF'
#!/usr/bin/env bash
# Quick restore script for Spicetify after Spotify updates

echo "Restoring Spicetify..."

# Fix permissions
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# Reapply Spicetify
spicetify backup apply

echo "✓ Spicetify restored!"
EOF
    
    chmod +x "${MODULE_DIR}/restore-spicetify.sh"
    print_success "Created restore script at ${MODULE_DIR}/restore-spicetify.sh"
}

# ========== Main Execution ==========

main() {
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  Spotify Module - Native Setup      ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${NC}\n"
    
    check_aur_helper
    install_spotify
    fix_spotify_permissions
    install_spicetify
    configure_spicetify
    install_marketplace
    apply_theme
    enable_extensions
    verify_installation
    create_restore_script
    
    print_success "Spotify module completed!"
    
    echo -e "\n${YELLOW}${BOLD}Important Notes:${NC}"
    echo -e "  • Spotify has been modified with Spicetify"
    echo -e "  • If Spotify updates break Spicetify, run:"
    echo -e "    ${BOLD}${MODULE_DIR}/restore-spicetify.sh${NC}"
    echo -e "  • Access Marketplace in Spotify: Click \"Marketplace\" in sidebar"
    echo -e "  • Browse themes/extensions directly in Spotify"
}

main "$@"
