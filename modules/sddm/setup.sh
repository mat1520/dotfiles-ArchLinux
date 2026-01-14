#!/usr/bin/env bash

set -euo pipefail

LANG="${DOTFILES_LANG:-es}"

if [[ "$LANG" == "es" ]]; then
    MSG_INSTALL_SDDM="Configurando SDDM (Gestor de inicio de sesion)..."
    MSG_COPY_CONFIG="Copiando configuracion de SDDM..."
    MSG_THEME="Tema actual: SilentSDDM"
    MSG_COMPLETE="Modulo SDDM completado."
    MSG_NOTE="NOTA: Si quieres cambiar el tema SDDM, edita: /etc/sddm.conf.d/kde_settings.conf"
else
    MSG_INSTALL_SDDM="Configuring SDDM (Display Manager)..."
    MSG_COPY_CONFIG="Copying SDDM configuration..."
    MSG_THEME="Current theme: SilentSDDM"
    MSG_COMPLETE="SDDM module completed."
    MSG_NOTE="NOTE: To change SDDM theme, edit: /etc/sddm.conf.d/kde_settings.conf"
fi

echo "$MSG_INSTALL_SDDM"

sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-declarative

SDDM_CONF_DIR="/etc/sddm.conf.d"
sudo mkdir -p "$SDDM_CONF_DIR"

echo "$MSG_COPY_CONFIG"
sudo cp kde_settings.conf "$SDDM_CONF_DIR/" 2>/dev/null || echo "Config file not found in module directory"

sudo systemctl enable sddm.service

echo "$MSG_THEME"
echo "$MSG_COMPLETE"
echo "$MSG_NOTE"
