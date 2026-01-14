#!/usr/bin/env bash
# ========================================
# Secure Boot Module - Automated Signing
# ========================================
# Handles: sbctl, kernel signing, Nvidia module signing, pacman hooks
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

# ========== Check Secure Boot Status ==========

check_secureboot_status() {
    print_info "Checking Secure Boot status..."
    
    if ! command -v sbctl &> /dev/null; then
        print_warning "sbctl not found. Installing..."
        sudo pacman -S --needed --noconfirm sbctl
    fi
    
    # Check if in Setup Mode
    if sbctl status 2>&1 | grep -q "Setup Mode"; then
        print_success "System is in Setup Mode (ready for key enrollment)"
    else
        print_warning "System may not be in Setup Mode"
        print_info "If Secure Boot enrollment fails, enter BIOS and clear Secure Boot keys"
    fi
}

# ========== Create and Enroll Keys ==========

setup_sbctl_keys() {
    print_info "Setting up sbctl keys..."
    
    if [[ -d /usr/share/secureboot/keys ]]; then
        print_info "Keys already exist. Skipping creation..."
    else
        print_info "Creating new Secure Boot keys..."
        sudo sbctl create-keys
        print_success "Keys created"
    fi
    
    print_info "Enrolling keys into firmware..."
    if sudo sbctl enroll-keys --microsoft 2>&1 | grep -qi "already enrolled\|enrolled"; then
        print_success "Keys enrolled successfully"
    else
        print_warning "Key enrollment may have failed. Check manually with: sbctl status"
    fi
}

# ========== Sign Critical Binaries ==========

sign_system_files() {
    print_info "Signing bootloader and kernel..."
    
    # Common locations for bootloader and kernel
    local files_to_sign=(
        "/boot/vmlinuz-linux"
        "/boot/vmlinuz-linux-lts"
        "/boot/EFI/BOOT/BOOTX64.EFI"
        "/boot/EFI/systemd/systemd-bootx64.efi"
        "/boot/EFI/Linux/*.efi"
        "/efi/EFI/BOOT/BOOTX64.EFI"
        "/efi/EFI/systemd/systemd-bootx64.efi"
        "/efi/vmlinuz-linux"
        "/efi/vmlinuz-linux-lts"
    )
    
    for pattern in "${files_to_sign[@]}"; do
        # Handle glob patterns
        for file in $pattern 2>/dev/null; do
            if [[ -f "$file" ]]; then
                print_info "Signing: $file"
                sudo sbctl sign -s "$file" || print_warning "Failed to sign $file"
            fi
        done
    done
    
    # Sign any unified kernel images
    if ls /boot/EFI/Linux/*.efi 2>/dev/null || ls /efi/EFI/Linux/*.efi 2>/dev/null; then
        print_info "Signing unified kernel images..."
        sudo sbctl sign -s /boot/EFI/Linux/*.efi 2>/dev/null || true
        sudo sbctl sign -s /efi/EFI/Linux/*.efi 2>/dev/null || true
    fi
    
    print_success "System files signed"
}

# ========== Sign Nvidia Modules ==========

sign_nvidia_modules() {
    print_info "Checking for Nvidia modules..."
    
    if ! lspci | grep -i nvidia &> /dev/null; then
        print_warning "No Nvidia GPU detected. Skipping Nvidia module signing."
        return 0
    fi
    
    if ! pacman -Qq nvidia &> /dev/null && ! pacman -Qq nvidia-dkms &> /dev/null; then
        print_warning "Nvidia drivers not installed. Skipping module signing."
        return 0
    fi
    
    print_info "Signing Nvidia kernel modules..."
    
    # Get current kernel version
    local kernel_version=$(uname -r)
    local module_dir="/usr/lib/modules/${kernel_version}/updates/dkms"
    local extra_dir="/usr/lib/modules/${kernel_version}/extramodules"
    
    # Nvidia modules to sign
    local nvidia_modules=(
        "nvidia.ko.zst"
        "nvidia.ko"
        "nvidia-drm.ko.zst"
        "nvidia-drm.ko"
        "nvidia-modeset.ko.zst"
        "nvidia-modeset.ko"
        "nvidia-uvm.ko.zst"
        "nvidia-uvm.ko"
    )
    
    local signed_count=0
    
    for module in "${nvidia_modules[@]}"; do
        # Check in multiple possible locations
        for base_dir in "$module_dir" "$extra_dir" "/usr/lib/modules/${kernel_version}/kernel/drivers/video"; do
            if [[ -f "${base_dir}/${module}" ]]; then
                print_info "Signing: ${base_dir}/${module}"
                
                # Decompress if .zst
                if [[ "$module" == *.zst ]]; then
                    local temp_module="/tmp/${module%.zst}"
                    sudo zstd -d "${base_dir}/${module}" -o "$temp_module" --force
                    sudo sbctl sign-module "$temp_module"
                    sudo zstd "$temp_module" -o "${base_dir}/${module}" --force
                    sudo rm "$temp_module"
                else
                    sudo sbctl sign-module "${base_dir}/${module}"
                fi
                
                ((signed_count++))
            fi
        done
    done
    
    if [[ $signed_count -gt 0 ]]; then
        print_success "Signed ${signed_count} Nvidia module(s)"
    else
        print_warning "No Nvidia modules found to sign"
    fi
}

# ========== Create Pacman Hooks ==========

create_pacman_hooks() {
    print_info "Creating pacman hooks for automatic signing..."
    
    sudo mkdir -p /etc/pacman.d/hooks
    
    # Hook for kernel updates
    cat <<'EOF' | sudo tee /etc/pacman.d/hooks/99-secureboot-kernel.hook > /dev/null
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = linux-lts
Target = linux-zen
Target = linux-hardened

[Action]
Description = Signing kernel with sbctl for Secure Boot...
When = PostTransaction
Exec = /usr/bin/sbctl sign-all
Depends = sbctl
EOF
    
    print_success "Created kernel signing hook"
    
    # Hook for Nvidia driver updates
    cat <<'EOF' | sudo tee /etc/pacman.d/hooks/99-secureboot-nvidia.hook > /dev/null
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = nvidia
Target = nvidia-dkms
Target = nvidia-lts

[Action]
Description = Signing Nvidia modules with sbctl for Secure Boot...
When = PostTransaction
Exec = /usr/bin/bash -c 'for module in /usr/lib/modules/*/extramodules/nvidia*.ko* /usr/lib/modules/*/updates/dkms/nvidia*.ko*; do [ -f "$module" ] && if [[ "$module" == *.zst ]]; then temp="${module%.zst}"; zstd -d "$module" -o "$temp" --force && sbctl sign-module "$temp" && zstd "$temp" -o "$module" --force && rm "$temp"; else sbctl sign-module "$module"; fi; done'
Depends = sbctl
EOF
    
    print_success "Created Nvidia module signing hook"
    
    # Hook for systemd-boot updates
    cat <<'EOF' | sudo tee /etc/pacman.d/hooks/99-secureboot-systemd.hook > /dev/null
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = systemd

[Action]
Description = Signing systemd-boot with sbctl for Secure Boot...
When = PostTransaction
Exec = /usr/bin/bash -c 'sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi 2>/dev/null || sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi 2>/dev/null || true'
Depends = sbctl
EOF
    
    print_success "Created systemd-boot signing hook"
}

# ========== Verify Setup ==========

verify_setup() {
    print_info "Verifying Secure Boot setup..."
    
    echo -e "\n${BOLD}${CYAN}=== sbctl status ===${NC}"
    sudo sbctl status
    
    echo -e "\n${BOLD}${CYAN}=== Signed files ===${NC}"
    sudo sbctl list-files
    
    echo -e "\n${BOLD}${YELLOW}NOTE: Secure Boot will be enforced after reboot.${NC}"
    echo -e "${YELLOW}If the system fails to boot, disable Secure Boot in BIOS.${NC}\n"
}

# ========== Main Execution ==========

main() {
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  Secure Boot Module - Setup         ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${NC}\n"
    
    check_secureboot_status
    setup_sbctl_keys
    sign_system_files
    sign_nvidia_modules
    create_pacman_hooks
    verify_setup
    
    print_success "Secure Boot module completed!"
}

main "$@"
