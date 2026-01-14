#!/usr/bin/env bash

set -euo pipefail

LANG="${DOTFILES_LANG:-es}"

if [[ "$LANG" == "es" ]]; then
    MSG_CONFIG_NVIDIA="Configurando variables de entorno para Nvidia Wayland (RTX 3050)..."
    MSG_INSTALL_GAME="Instalando gamemode para optimizacion de juegos..."
    MSG_COMPLETE="Modulo de sistema completado. Reinicia para aplicar cambios."
else
    MSG_CONFIG_NVIDIA="Configuring environment variables for Nvidia Wayland (RTX 3050)..."
    MSG_INSTALL_GAME="Installing gamemode for gaming optimization..."
    MSG_COMPLETE="System module completed. Reboot to apply changes."
fi

echo "$MSG_CONFIG_NVIDIA"

ENV_FILE="/etc/profile.d/nvidia-wayland.sh"

sudo tee "$ENV_FILE" > /dev/null <<'EOF'
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

export NVD_BACKEND=direct
export ELECTRON_OZONE_PLATFORM_HINT=auto

export MOZ_ENABLE_WAYLAND=1

export KWIN_DRM_USE_MODIFIERS=1
EOF

echo "$MSG_INSTALL_GAME"
sudo pacman -S --needed --noconfirm gamemode lib32-gamemode

sudo usermod -aG gamemode $USER

echo "$MSG_COMPLETE"
