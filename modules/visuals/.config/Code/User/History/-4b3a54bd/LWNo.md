# Arch Linux Dotfiles - Automated Installation Framework

**Fully automated, modular dotfiles restoration for Arch Linux + KDE Plasma 6 (Wayland)**

---

## Directory Structure

```
dotfiles-ArchLinux/
├── install.sh                          # Master orchestrator script
├── README.md                           # This file
│
└── modules/                            # Modular installation components
    │
    ├── secureboot/                     # Secure Boot automation
    │   └── setup.sh                    # sbctl + kernel/Nvidia signing
    │
    ├── shell/                          # Zsh configuration
    │   ├── setup.sh                    # Oh My Zsh + Powerlevel10k
    │   ├── .zshrc                      # Zsh config (copy yours here)
    │   └── .p10k.zsh                   # Powerlevel10k config
    │
    ├── system/                         # System optimizations
    │   └── setup.sh                    # Nvidia Wayland env vars + gamemode
    │
    ├── visuals/                        # Visual customization
    │   ├── setup.sh                    # Fastfetch + Terminal + KDE
    │   ├── .config/
    │   │   ├── fastfetch/
    │   │   │   └── config.jsonc        # Custom fastfetch config
    │   │   └── kitty/
    │   │       └── kitty.conf          # Kitty terminal config
    │   ├── .local/
    │   │   └── share/
    │   │       └── konsole/            # Konsole profiles (optional)
    │   ├── kde-configs/                # KDE Plasma backups
    │   │   └── konsave-profile.knsv   # Konsave export
    │   └── wallpapers/                 # Wallpaper images
    │
    └── spotify/                        # Spotify + Spicetify
        ├── setup.sh                    # Native Spotify + CLI install
        ├── restore-spicetify.sh        # Auto-generated restore script
        └── spicetify-themes/           # Custom Spicetify themes (optional)
```

---

## Quick Start

### 1. Clone Repository

```bash
git clone <your-repo-url> ~/Documents/dotfiles-ArchLinux
cd ~/Documents/dotfiles-ArchLinux
```

### 2. Copy Your Personal Configs

**Important:** Before running the installer, copy your current configs:

```bash
# Shell configs
cp ~/.zshrc modules/shell/
cp ~/.p10k.zsh modules/shell/

# Add your wallpapers
cp ~/Pictures/wallpapers/* modules/visuals/wallpapers/

# Optional: Backup KDE settings
pip install konsave --user
konsave -s current
konsave -e current
mv ~/.config/konsave/profiles/current.knsv modules/visuals/kde-configs/
```

### 3. Run Master Installer

```bash
chmod +x install.sh
./install.sh
```

The script will:
- Auto-detect all modules
- Show progress bars with colors
- Install each module sequentially
- Symlink configs using GNU Stow
- Provide detailed summary

### 4. Reboot

```bash
reboot
```

After reboot, enable Secure Boot in BIOS if desired.

---

## Module Breakdown

### 1. Secure Boot Module (`modules/secureboot/`)

**What it does:**
- Installs and configures `sbctl`
- Creates and enrolls Secure Boot keys
- Signs kernel, Nvidia modules, and bootloader
- Creates pacman hooks for automatic re-signing on updates

**Critical for:**
- Secure Boot enforcement on Lenovo LOQ
- Nvidia RTX 3050 driver compatibility with Secure Boot

**Post-installation:**
```bash
sudo sbctl status
sudo sbctl list-files
```

---

### 2. Shell Module (`modules/shell/`)

**What it does:**
- Installs Zsh + JetBrains Mono Nerd Font
- Changes default shell to Zsh
- Installs Oh My Zsh
- Installs plugins: zsh-autosuggestions, zsh-syntax-highlighting
- Installs Powerlevel10k theme

**Important:**
Copy your personal configs to the module:
```bash
cp ~/.zshrc ~/Documents/dotfiles-ArchLinux/modules/shell/
cp ~/.p10k.zsh ~/Documents/dotfiles-ArchLinux/modules/shell/
```

---

### 3. System Module (`modules/system/`)

**What it does:**
- Configures Nvidia Wayland environment variables
- Enables proper GBM backend for Nvidia
- Fixes Electron apps (VS Code, Discord, Spotify) on Wayland
- Enables Firefox Wayland mode
- Installs gamemode for gaming performance

**Creates:** `/etc/profile.d/nvidia-wayland.sh`

**Post-installation:** Reboot to apply environment variables

---

### 4. Visuals Module (`modules/visuals/`)

**What it does:**
- Installs **Fastfetch** with custom config
- Configures **Kitty** or **Konsole** terminal
- Installs **KDE Plasma** customization tools
- Restores KDE settings via **konsave** (if available)
- Applies wallpapers
- Installs KWin scripts/effects

**Included configs:**
- `fastfetch/config.jsonc` - System info display
- `kitty/kitty.conf` - Terminal theme
- `kde-configs/` - Full KDE Plasma backup

**To backup your current KDE setup:**
```bash
pip install konsave --user
konsave -s mysetup
konsave -e mysetup
mv ~/.config/konsave/profiles/mysetup.knsv \
   ~/Documents/dotfiles-ArchLinux/modules/visuals/kde-configs/
```

---

### 5. Spotify Module (`modules/spotify/`)

**What it does:**
- Installs **Spotify** from AUR (native, not Flatpak)
- Fixes `/opt/spotify` permissions (critical for Spicetify)
- Installs **Spicetify CLI** from AUR
- Installs **Spicetify Marketplace**
- Applies theme
- Creates restore script for Spotify updates

**Why native installation?**
- Direct access to `/opt/spotify` for theming
- No sandboxing issues (unlike Flatpak)
- Full Spicetify compatibility

**After Spotify updates:**
```bash
cd ~/Documents/dotfiles-ArchLinux/modules/spotify
./restore-spicetify.sh
```

---

## 🛠️ Customization Guide

### Adding Your Own Configs

**Example: Adding Zsh config**

1. Create module structure:
```bash
mkdir -p modules/shell/.config/zsh
```

2. Add your config files:
```bash
cp ~/.zshrc modules/shell/.config/zsh/
cp -r ~/.oh-my-zsh modules/shell/.config/zsh/
```

3. Create `modules/shell/setup.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Installing Zsh..."
sudo pacman -S --needed --noconfirm zsh

echo "Zsh module completed!"
```

4. Make executable:
```bash
chmod +x modules/shell/setup.sh
```

5. Run master installer:
```bash
./install.sh
```

---

### Using GNU Stow

Stow automatically creates symlinks from `modules/` to `$HOME`.

**Structure requirement:**
```
modules/<module-name>/.config/<app>/<files>
                 ↓
            symlinked to
                 ↓
            ~/.config/<app>/<files>
```

**Example:**
```
modules/visuals/.config/kitty/kitty.conf
    → ~/.config/kitty/kitty.conf
```

**Manual stow command:**
```bash
cd ~/Documents/dotfiles-ArchLinux/modules
stow -v -t $HOME visuals
```

---

## 🔧 System Requirements

**Hardware:**
- CPU: AMD Ryzen 5 7000 Series
- GPU: Nvidia RTX 3050 6GB
- RAM: 12GB

**Software:**
- OS: Arch Linux x86_64
- Desktop: KDE Plasma 6 (Wayland)
- Shell: Zsh 5.9
- Bootloader: systemd-boot or GRUB
- Kernel: linux or linux-lts

**Dependencies (auto-installed):**
- `git`
- `stow`
- `sbctl` (Secure Boot)
- `yay` or `paru` (AUR helper)

---

## 📋 Usage Examples

### Install Everything
```bash
./install.sh
```

### Install Single Module
```bash
cd modules/spotify
bash setup.sh
```

### Re-apply Symlinks Only
```bash
cd modules
stow -v -t $HOME */
```

### Check What Would Be Stowed (Dry Run)
```bash
cd modules
stow -n -v -t $HOME visuals
```

---

## ⚠️ Important Notes

### Secure Boot
- **Reboot required** after secure boot setup
- Enable Secure Boot in BIOS/UEFI after first boot
- If boot fails, disable Secure Boot and run `sudo sbctl verify`

### Nvidia Drivers
- Modules auto-signed on kernel updates via pacman hooks
- If Nvidia fails to load: `sudo sbctl sign-all && sudo update-initramfs -u`

### KDE Plasma
- Some settings require re-login to apply
- Konsave profiles may not include all extensions
- Manually install Latte Dock or other plasmoids if needed

### Spotify
- After Spotify updates, Spicetify may break
- Run `modules/spotify/restore-spicetify.sh` to fix
- Marketplace allows theme/extension installation from Spotify UI

---

## 🐛 Troubleshooting

### Issue: "Module failed" error
**Solution:**
```bash
# Run module manually to see detailed errors
cd modules/<module-name>
bash -x setup.sh
```

### Issue: Stow conflicts
**Solution:**
```bash
# Backup existing config
mv ~/.config/<app> ~/.config/<app>.backup

# Re-run stow
cd modules
stow -v -t $HOME <module-name>
```

### Issue: Secure Boot won't enable
**Solution:**
```bash
# Check status
sudo sbctl status

# Verify keys enrolled
sudo sbctl list-keys

# Re-create keys if needed
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
```

### Issue: Spicetify not applying
**Solution:**
```bash
# Fix permissions
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

# Reapply
spicetify backup apply
```

---

## 📚 Additional Resources

- [Arch Wiki - Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
- [sbctl Documentation](https://github.com/Foxboron/sbctl)
- [Spicetify CLI](https://spicetify.app/)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Konsave GitHub](https://github.com/Prayag2/konsave)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)

---

## 📝 To-Do

- [ ] Add Neovim/Vim configuration module
- [ ] Add Hyprland/i3 window manager configs
- [ ] Create automated backup script (`backup.sh`)
- [ ] Add Firefox CSS customization module
- [ ] Integrate GTK theme installation

---

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own setup!

---

## 📄 License

MIT License - Do whatever you want with this code.

---

<div align="center">

**Made with ❤️ for Arch Linux**

*"I use Arch, btw"*

</div>
