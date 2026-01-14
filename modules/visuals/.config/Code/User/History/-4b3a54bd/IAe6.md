# Arch Linux Dotfiles | Dotfiles Arch Linux

**[English](#english) | [Español](#español)**

---

## English

### Automated Installation Framework for Arch Linux

Fully automated, modular dotfiles restoration for **Lenovo LOQ** with:
- **OS:** Arch Linux x86_64
- **Desktop:** KDE Plasma 6.5.5 (Wayland)
- **GPU:** Nvidia RTX 3050 6GB Laptop
- **CPU:** AMD Ryzen 5 7000 Series
- **Shell:** Zsh with Oh My Zsh + Powerlevel10k

### Quick Start

```bash
# Clone repository
git clone <your-repo-url> ~/Documents/dotfiles-ArchLinux
cd ~/Documents/dotfiles-ArchLinux

# Run in English
DOTFILES_LANG=en ./install.sh

# Or run in Spanish (default)
./install.sh
```

### Directory Structure

```
dotfiles-ArchLinux/
├── install.sh                  # Master installer (bilingual)
├── README.md                   # This file
│
└── modules/
    ├── secureboot/             # Secure Boot + sbctl
    │   └── setup.sh
    ├── shell/                  # Zsh + Oh My Zsh + Powerlevel10k
    │   ├── setup.sh
    │   ├── .zshrc              # Your actual Zsh config
    │   ├── .gitconfig          # Your Git config
    │   └── .p10k.zsh           # Powerlevel10k config (optional)
    ├── system/                 # Nvidia Wayland optimization
    │   └── setup.sh
    ├── visuals/                # Fastfetch + Terminal + KDE
    │   ├── setup.sh
    │   ├── .config/
    │   │   ├── fastfetch/      # Your actual config
    │   │   └── kitty/          # Your actual Kitty config
    │   ├── wallpapers/         # Place your wallpapers here
    │   └── kde-configs/        # KDE Plasma backups
    └── spotify/                # Spotify + Spicetify
        └── setup.sh
```

### Modules

#### 1. Secure Boot (`secureboot/`)
- Installs and configures `sbctl`
- Signs kernel, Nvidia modules, and bootloader
- Creates pacman hooks for auto-signing on updates

#### 2. Shell (`shell/`)
- Installs Zsh + JetBrains Mono Nerd Font
- Installs Oh My Zsh + plugins (autosuggestions, syntax-highlighting)
- Installs Powerlevel10k theme
- Symlinks your `.zshrc` and `.gitconfig`

#### 3. System (`system/`)
- Configures Nvidia Wayland environment variables for RTX 3050
- Fixes Electron apps (VS Code, Discord, Spotify) on Wayland
- Installs gamemode for gaming optimization

#### 4. Visuals (`visuals/`)
- Installs Fastfetch (system info tool)
- Configures Kitty terminal
- KDE Plasma customization tools
- Symlinks your actual configs

#### 5. Spotify (`spotify/`)
- Installs native Spotify from AUR
- Fixes permissions for Spicetify
- Installs Spicetify CLI + Marketplace

### Language Selection

```bash
# English
DOTFILES_LANG=en ./install.sh

# Spanish (default)
DOTFILES_LANG=es ./install.sh
# or simply
./install.sh
```

### Requirements

- Arch Linux x86_64
- Internet connection
- `git`, `stow`, `sudo` (auto-installed if missing)

### Post-Installation

1. **Reboot** to apply Secure Boot and environment variables
2. **Re-login** to apply Zsh shell changes
3. **Enable Secure Boot** in BIOS (optional)
4. Run `p10k configure` to customize Powerlevel10k (if installed)

### Troubleshooting

**Module failed:**
```bash
cd modules/<module-name>
bash -x setup.sh
```

**Secure Boot won't enable:**
```bash
sudo sbctl status
sudo sbctl sign-all
```

**Spicetify not working after Spotify update:**
```bash
cd modules/spotify
./restore-spicetify.sh
```

---

## Español

### Framework de Instalación Automatizada para Arch Linux

Restauración completamente automatizada y modular de dotfiles para **Lenovo LOQ** con:
- **SO:** Arch Linux x86_64
- **Escritorio:** KDE Plasma 6.5.5 (Wayland)
- **GPU:** Nvidia RTX 3050 6GB Laptop
- **CPU:** AMD Ryzen 5 7000 Series
- **Shell:** Zsh con Oh My Zsh + Powerlevel10k

### Inicio Rápido

```bash
# Clonar repositorio
git clone <tu-repo-url> ~/Documents/dotfiles-ArchLinux
cd ~/Documents/dotfiles-ArchLinux

# Ejecutar en español (por defecto)
./install.sh

# O ejecutar en inglés
DOTFILES_LANG=en ./install.sh
```

### Estructura de Directorios

```
dotfiles-ArchLinux/
├── install.sh                  # Instalador maestro (bilingüe)
├── README.md                   # Este archivo
│
└── modules/
    ├── secureboot/             # Secure Boot + sbctl
    │   └── setup.sh
    ├── shell/                  # Zsh + Oh My Zsh + Powerlevel10k
    │   ├── setup.sh
    │   ├── .zshrc              # Tu configuración real de Zsh
    │   ├── .gitconfig          # Tu configuración de Git
    │   └── .p10k.zsh           # Config de Powerlevel10k (opcional)
    ├── system/                 # Optimización Nvidia Wayland
    │   └── setup.sh
    ├── visuals/                # Fastfetch + Terminal + KDE
    │   ├── setup.sh
    │   ├── .config/
    │   │   ├── fastfetch/      # Tu configuración real
    │   │   └── kitty/          # Tu configuración real de Kitty
    │   ├── wallpapers/         # Coloca tus fondos aquí
    │   └── kde-configs/        # Respaldos de KDE Plasma
    └── spotify/                # Spotify + Spicetify
        └── setup.sh
```

### Módulos

#### 1. Secure Boot (`secureboot/`)
- Instala y configura `sbctl`
- Firma kernel, módulos Nvidia y bootloader
- Crea hooks de pacman para auto-firmar en actualizaciones

#### 2. Shell (`shell/`)
- Instala Zsh + JetBrains Mono Nerd Font
- Instala Oh My Zsh + plugins (autosuggestions, syntax-highlighting)
- Instala tema Powerlevel10k
- Crea enlaces simbólicos a tu `.zshrc` y `.gitconfig`

#### 3. System (`system/`)
- Configura variables de entorno Nvidia Wayland para RTX 3050
- Arregla apps Electron (VS Code, Discord, Spotify) en Wayland
- Instala gamemode para optimización en juegos

#### 4. Visuals (`visuals/`)
- Instala Fastfetch (herramienta de info del sistema)
- Configura terminal Kitty
- Herramientas de personalización de KDE Plasma
- Crea enlaces simbólicos a tus configuraciones reales

#### 5. Spotify (`spotify/`)
- Instala Spotify nativo desde AUR
- Arregla permisos para Spicetify
- Instala Spicetify CLI + Marketplace

### Selección de Idioma

```bash
# Inglés
DOTFILES_LANG=en ./install.sh

# Español (por defecto)
DOTFILES_LANG=es ./install.sh
# o simplemente
./install.sh
```

### Requisitos

- Arch Linux x86_64
- Conexión a Internet
- `git`, `stow`, `sudo` (se instalan automáticamente si faltan)

### Post-Instalación

1. **Reiniciar** para aplicar Secure Boot y variables de entorno
2. **Volver a iniciar sesión** para aplicar cambios de Zsh
3. **Habilitar Secure Boot** en BIOS (opcional)
4. Ejecuta `p10k configure` para personalizar Powerlevel10k (si está instalado)

### Solución de Problemas

**Módulo falló:**
```bash
cd modules/<nombre-modulo>
bash -x setup.sh
```

**Secure Boot no se habilita:**
```bash
sudo sbctl status
sudo sbctl sign-all
```

**Spicetify no funciona después de actualizar Spotify:**
```bash
cd modules/spotify
./restore-spicetify.sh
```

---

## License | Licencia

MIT License - Do whatever you want | Haz lo que quieras

**Made for Arch Linux | Hecho para Arch Linux**  
**Lenovo LOQ | AMD Ryzen 5 7000 | RTX 3050 6GB**
