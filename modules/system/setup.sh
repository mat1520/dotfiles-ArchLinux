#!/usr/bin/env bash

set -euo pipefail

echo "Configuring environment variables for Nvidia Wayland..."

ENV_FILE="/etc/profile.d/nvidia-wayland.sh"

sudo tee "$ENV_FILE" > /dev/null <<'EOF'
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

export NVD_BACKEND=direct
export ELECTRON_OZONE_PLATFORM_HINT=auto

export MOZ_ENABLE_WAYLAND=1

export KWIN_DRM_USE_MODIFIERS=1
EOF

echo "Installing gamemode..."
sudo pacman -S --needed --noconfirm gamemode lib32-gamemode

sudo usermod -aG gamemode $USER

echo "System module completed. Reboot to apply changes."
