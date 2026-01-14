#!/usr/bin/env bash
# ========================================
# Arch Linux Dotfiles - Master Installer
# ========================================
# Automated dotfiles restoration for Lenovo LOQ
# KDE Plasma 6 (Wayland) + Zsh + Nvidia RTX 3050
# ========================================

set -euo pipefail

# ========== Color Definitions ==========
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ========== Script Variables ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
TOTAL_MODULES=0
CURRENT_MODULE=0
FAILED_MODULES=()

# ========== Helper Functions ==========

print_header() {
    echo -e "\n${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${MAGENTA}Arch Linux Dotfiles - Master Installer${NC}"
    echo -e "${BOLD}${YELLOW}Lenovo LOQ - AMD Ryzen 5 7000 - RTX 3050${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}\n"
}

print_section() {
    echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${BOLD}${CYAN}["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] ${percentage}%% (${current}/${total})${NC}"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root!"
        print_info "It will request sudo when needed."
        exit 1
    fi
}

check_dependencies() {
    print_section "Checking Dependencies"
    
    local deps=("git" "stow" "sudo")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is installed"
        else
            print_error "$dep is NOT installed"
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Installing missing dependencies: ${missing_deps[*]}"
        sudo pacman -S --needed --noconfirm "${missing_deps[@]}"
    fi
}

discover_modules() {
    print_section "Discovering Modules"
    
    if [[ ! -d "${MODULES_DIR}" ]]; then
        print_error "Modules directory not found: ${MODULES_DIR}"
        exit 1
    fi
    
    local modules=()
    while IFS= read -r -d '' module_dir; do
        local module_name=$(basename "$module_dir")
        if [[ -f "${module_dir}/setup.sh" ]]; then
            modules+=("$module_name")
            print_info "Found module: ${BOLD}${module_name}${NC}"
        else
            print_warning "Skipping ${module_name} (no setup.sh found)"
        fi
    done < <(find "${MODULES_DIR}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    
    TOTAL_MODULES=${#modules[@]}
    
    if [[ $TOTAL_MODULES -eq 0 ]]; then
        print_error "No modules found!"
        exit 1
    fi
    
    echo -e "\n${BOLD}${GREEN}Total modules to install: ${TOTAL_MODULES}${NC}\n"
    
    # Return modules array
    printf '%s\n' "${modules[@]}"
}

execute_module() {
    local module_name=$1
    local module_path="${MODULES_DIR}/${module_name}"
    local setup_script="${module_path}/setup.sh"
    
    CURRENT_MODULE=$((CURRENT_MODULE + 1))
    
    echo -e "\n${BOLD}${MAGENTA}--- Module ${CURRENT_MODULE}/${TOTAL_MODULES}: ${module_name} ---${NC}\n"
    
    progress_bar $CURRENT_MODULE $TOTAL_MODULES
    
    if [[ ! -f "$setup_script" ]]; then
        print_error "Setup script not found: $setup_script"
        FAILED_MODULES+=("$module_name")
        return 1
    fi
    
    chmod +x "$setup_script"
    
    if (cd "$module_path" && bash setup.sh); then
        print_success "Module '${module_name}' completed successfully"
        return 0
    else
        print_error "Module '${module_name}' failed!"
        FAILED_MODULES+=("$module_name")
        return 1
    fi
}

apply_stow() {
    print_section "Applying GNU Stow"
    
    # Stow all modules that have config directories
    for module_dir in "${MODULES_DIR}"/*; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")
            
            # Check if module has .config directory
            if [[ -d "${module_dir}/.config" ]]; then
                print_info "Stowing ${module_name}..."
                
                cd "${MODULES_DIR}"
                if stow -v -t "$HOME" "$module_name" 2>&1 | grep -v "BUG in find_stowed_path" || true; then
                    print_success "${module_name} symlinked"
                else
                    print_warning "${module_name} may have conflicts"
                fi
            fi
        fi
    done
    
    cd "$SCRIPT_DIR"
}

print_summary() {
    print_section "Installation Summary"
    
    local successful=$((TOTAL_MODULES - ${#FAILED_MODULES[@]}))
    
    echo -e "${BOLD}Modules Processed:${NC} ${TOTAL_MODULES}"
    echo -e "${GREEN}${BOLD}Successful:${NC} ${successful}"
    echo -e "${RED}${BOLD}Failed:${NC} ${#FAILED_MODULES[@]}"
    
    if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
        echo -e "\n${RED}${BOLD}Failed Modules:${NC}"
        for module in "${FAILED_MODULES[@]}"; do
            echo -e "  ${RED}[FAILED]${NC} ${module}"
        done
        echo -e "\n${YELLOW}Please check the error messages above and retry.${NC}"
        return 1
    else
        echo -e "\n${GREEN}${BOLD}All modules installed successfully!${NC}\n"
        
        print_info "You may need to:"
        echo -e "  - Reboot to apply Secure Boot changes"
        echo -e "  - Re-login to apply shell/KDE settings"
        echo -e "  - Run ${BOLD}plasma-apply-*${NC} commands manually if needed"
        return 0
    fi
}

# ========== Main Execution ==========

main() {
    print_header
    
    check_root
    check_dependencies
    
    # Discover and store modules
    mapfile -t MODULES_TO_INSTALL < <(discover_modules)
    
    # Confirm with user
    echo -e "${YELLOW}${BOLD}Ready to install ${TOTAL_MODULES} module(s).${NC}"
    read -p "Continue? [Y/n] " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        print_warning "Installation cancelled by user."
        exit 0
    fi
    
    # Execute each module
    for module in "${MODULES_TO_INSTALL[@]}"; do
        execute_module "$module" || true  # Continue even if module fails
    done
    
    # Apply stow for symlinking
    apply_stow
    
    # Print summary
    print_summary
    exit_code=$?
    
    exit $exit_code
}

main "$@"
