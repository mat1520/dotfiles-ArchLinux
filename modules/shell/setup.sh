#!/usr/bin/env bash

set -euo pipefail

LANG="${DOTFILES_LANG:-es}"

if [[ "$LANG" == "es" ]]; then
    MSG_INSTALL_ZSH="Instalando Zsh y fuentes Nerd..."
    MSG_CHANGE_SHELL="Cambiando shell por defecto a Zsh..."
    MSG_INSTALL_OMZ="Instalando Oh My Zsh..."
    MSG_INSTALL_SUGGEST="Instalando zsh-autosuggestions..."
    MSG_INSTALL_SYNTAX="Instalando zsh-syntax-highlighting..."
    MSG_INSTALL_P10K="Instalando Powerlevel10k..."
    MSG_COMPLETE="Modulo de shell completado."
else
    MSG_INSTALL_ZSH="Installing Zsh and Nerd Fonts..."
    MSG_CHANGE_SHELL="Changing default shell to Zsh..."
    MSG_INSTALL_OMZ="Installing Oh My Zsh..."
    MSG_INSTALL_SUGGEST="Installing zsh-autosuggestions..."
    MSG_INSTALL_SYNTAX="Installing zsh-syntax-highlighting..."
    MSG_INSTALL_P10K="Installing Powerlevel10k..."
    MSG_COMPLETE="Shell module completed."
fi

echo "$MSG_INSTALL_ZSH"
sudo pacman -S --needed --noconfirm zsh ttf-jetbrains-mono-nerd ttf-font-awesome

if [[ "$SHELL" != */zsh ]]; then
    echo "$MSG_CHANGE_SHELL"
    chsh -s $(which zsh)
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "$MSG_INSTALL_OMZ"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "$MSG_INSTALL_SUGGEST"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "$MSG_INSTALL_SYNTAX"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "$MSG_INSTALL_P10K"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
fi

echo "$MSG_COMPLETE"
