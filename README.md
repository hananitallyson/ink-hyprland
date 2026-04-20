# Ink Hyprland

Manual setup guide for my personal Arch Linux environment using Hyprland as the Wayland compositor, Fish shell, Neovim, and GNU Stow for dotfile management.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [1. Base dependencies](#1-base-dependencies)
  - [2. GPU drivers](#2-gpu-drivers)
  - [3. Wayland & Hyprland](#3-wayland--hyprland)
  - [4. Display Manager (greetd)](#4-display-manager-greetd)
  - [5. Paru (AUR Helper)](#5-paru-aur-helper)
  - [6. Terminal & Editors](#6-terminal--editors)
  - [7. Interface & Widgets](#7-interface--widgets)
  - [8. GTK Theme — Graphite](#8-gtk-theme--graphite)
  - [9. Icons — YAMIS](#9-icons--yamis)
  - [10. Cursor — Notwaita](#10-cursor--notwaita)
  - [11. Fonts](#11-fonts)
  - [12. File Manager](#12-file-manager)
  - [13. Audio](#13-audio)
  - [14. Media](#14-media)
  - [15. Clipboard & Screenshots](#15-clipboard--screenshots)
  - [16. Networking](#16-networking)
  - [17. Utilities](#17-utilities)
  - [18. asdf-vm](#18-asdf-vm)
  - [19. Dotfiles with GNU Stow](#19-dotfiles-with-gnu-stow)
- [Post-installation](#post-installation)

---

## Prerequisites

- Arch Linux installed and running
- Internet access
- A regular user with `sudo` access (do **not** run as root)
- AMD GPU (this guide installs `vulkan-radeon` and `mesa` drivers)

> If you use NVIDIA or Intel, replace the GPU driver packages in [step 2](#2-gpu-drivers).

---

## Installation

### 1. Base dependencies

Install `base-devel` and `git`, required to compile packages and clone repositories.

```bash
sudo pacman -S --needed base-devel git
```

Verify:

```bash
git --version
```

---

### 2. GPU drivers

Install the Mesa and Vulkan drivers for AMD GPUs:

```bash
sudo pacman -S --needed amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
```

Verify the Vulkan driver is active:

```bash
vulkaninfo --summary
```

> Replace with `nvidia` or `intel-media-driver` packages if not using AMD.

---

### 3. Wayland & Hyprland

Install Hyprland and its Wayland dependencies:

```bash
sudo pacman -S --needed \
    hyprland \
    wayland wayland-protocols xdg-user-dirs \
    libxkbcommon meson scdoc \
    freetype2 harfbuzz cairo pango
```

Verify Hyprland is available:

```bash
Hyprland --version
```

---

### 4. Display Manager (greetd)

Install greetd and the tuigreet frontend:

```bash
sudo pacman -S --needed greetd greetd-tuigreet
```

If `sddm` is installed, remove it to avoid conflicts:

```bash
sudo pacman -Rns sddm
```

Create the configuration file:

```bash
sudo mkdir -p /etc/greetd
sudo nano /etc/greetd/config.toml
```

Paste the following content:

```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
```

Enable the service:

```bash
sudo systemctl enable greetd
```

Verify it is enabled:

```bash
systemctl is-enabled greetd
```

---

### 5. Paru (AUR Helper)

Check if `paru` is already installed:

```bash
paru --version
```

If not, clone and build it from the AUR:

```bash
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si
```

Verify:

```bash
paru --version
```

---

### 6. Terminal & Editors

Install Fish, Vim, and Neovim:

```bash
sudo pacman -S --needed fish vim neovim
```

Verify each:

```bash
fish --version
vim --version | head -1
nvim --version | head -1
```

Add `fish` to the list of valid shells and set it as your default:

```bash
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

Verify the change (takes effect on next login):

```bash
grep fish /etc/shells
```

---

### 7. Interface & Widgets

Install the status bar, wallpaper daemon, notification daemon, and GTK configurator:

```bash
sudo pacman -S --needed waybar swww mako nwg-look
```

Install `tofi` (application launcher) from the AUR:

```bash
paru -S --needed tofi
```

Verify:

```bash
waybar --version
tofi --version
```

---

### 8. GTK Theme — Graphite

Clone and install the [Graphite GTK Theme](https://github.com/vinceliuice/Graphite-gtk-theme) with the `black` and `rimless` tweaks:

```bash
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git /tmp/graphite
cd /tmp/graphite
sudo ./install.sh -d /usr/share/themes --tweaks black rimless
```

Verify the theme was installed:

```bash
ls /usr/share/themes | grep Graphite
```

---

### 9. Icons — YAMIS

Clone the [YAMIS](https://github.com/googIyEYES/YAMIS) repository, extract the icon pack, and install it:

```bash
git clone https://github.com/googIyEYES/YAMIS.git /tmp/yamis
cd /tmp/yamis
tar -xzf monochrome-icon-theme.tar.gz
sudo cp -r YAMIS /usr/share/icons/YAMIS
```

Verify:

```bash
ls /usr/share/icons | grep YAMIS
```

---

### 10. Cursor — Notwaita

Install the Notwaita cursor theme from the AUR:

```bash
paru -S --needed notwaita-cursor-theme
```

Verify:

```bash
ls /usr/share/icons | grep -i notwaita
```

---

### 11. Fonts

Install the required fonts:

```bash
sudo pacman -S --needed \
    ttf-martian-mono-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk
```

Verify the fonts are recognized by the system:

```bash
fc-list | grep -i martian
```

---

### 12. File Manager

Install Thunar and its supporting packages:

```bash
sudo pacman -S --needed thunar gvfs udiskie
```

Verify Thunar launches:

```bash
thunar --version
```

---

### 13. Audio

Install the audio control tools:

```bash
sudo pacman -S --needed pamixer pavucontrol
```

Verify:

```bash
pamixer --version
```

---

### 14. Media

Install the image viewer, video player, and PDF reader:

```bash
sudo pacman -S --needed imv mpv zathura-pdf-mupdf
```

Verify:

```bash
mpv --version | head -1
```

---

### 15. Clipboard & Screenshots

Install clipboard and screenshot utilities:

```bash
sudo pacman -S --needed wl-clipboard cliphist grim slurp
```

Verify:

```bash
grim --help 2>&1 | head -1
```

---

### 16. Networking

Install the networking stack:

```bash
sudo pacman -S --needed iwd openssh systemd-networkd systemd-resolved curl
```

Enable the services:

```bash
sudo systemctl enable iwd
sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-resolved
sudo systemctl enable sshd
```

Verify they are enabled:

```bash
systemctl is-enabled iwd systemd-networkd systemd-resolved sshd
```

---

### 17. Utilities

Install the remaining utilities:

```bash
sudo pacman -S --needed ripgrep fastfetch stow brightnessctl tar zip unzip
```

Install Google Chrome from the AUR:

```bash
paru -S --needed google-chrome
```

Verify:

```bash
rg --version
fastfetch --version
stow --version | head -1
```

---

### 18. asdf-vm

Install `asdf-vm` from the AUR:

```bash
paru -S --needed asdf-vm
```

Verify:

```bash
asdf version
```

---

### 19. Dotfiles with GNU Stow

Clone this repository and use `stow` to symlink all configs into `$HOME`:

```bash
git clone https://github.com/hananitallyson/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .
```

`stow .` mirrors the directory structure from `~/dotfiles` into `~/`. For example, `~/dotfiles/.config/hypr/` becomes a symlink at `~/.config/hypr/`.

Verify a symlink was created correctly:

```bash
ls -la ~/.config/hypr
```

Reboot your system:

```bash
reboot
```

---

## Post-installation

After rebooting, connect to Wi-Fi if needed:

```bash
sudo systemctl start iwd
iwctl station wlan0 connect "Network Name"
```

Apply the GTK theme, icons, and cursor with nwg-look:

```bash
nwg-look
```
