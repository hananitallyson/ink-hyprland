# dotfiles — Arch Linux + Hyprland Setup

Automated setup for my personal Arch Linux environment using Hyprland as the Wayland compositor, Fish shell, Neovim, and GNU Stow for dotfile management.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [How to use](#how-to-use)
- [What the script does](#what-the-script-does)
  - [1. Base dependencies](#1-base-dependencies)
  - [2. Official packages](#2-official-packages)
  - [3. Paru (AUR Helper)](#3-paru-aur-helper)
  - [4. AUR packages](#4-aur-packages)
  - [5. Display Manager (greetd)](#5-display-manager-greetd)
  - [6. GTK Theme — Graphite](#6-gtk-theme--graphite)
  - [7. Icons — YAMIS](#7-icons--yamis)
  - [8. Fish Shell](#8-fish-shell)
  - [9. Dotfiles with GNU Stow](#9-dotfiles-with-gnu-stow)
- [Package details](#package-details)
- [Dotfiles structure](#dotfiles-structure)
- [Post-installation](#post-installation)

---

## Prerequisites

- Arch Linux installed and running
- Internet access
- A regular user with `sudo` access (do **not** run as root)
- AMD GPU (the script installs `vulkan-radeon` and `mesa` drivers)

> If you use NVIDIA or Intel, replace the GPU driver packages in the [relevant section](#gpu--drivers).

---

## How to use

Clone this repository and run the install script:

```bash
git clone https://github.com/hananitallyson/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script will prompt for your `sudo` password when needed. Do not run it as root.

Once it finishes, reboot your system:

```bash
reboot
```

---

## What the script does

### 1. Base dependencies

Installs `base-devel` and `git`, which are required to compile AUR packages and clone repositories.

```bash
sudo pacman -S --needed --noconfirm base-devel git
```

### 2. Official packages

Installs all required packages via `pacman`. See the [package details](#package-details) section for a description of each one.

```bash
sudo pacman -S --needed --noconfirm \
    hyprland amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    wayland wayland-protocols xdg-user-dirs meson scdoc libxkbcommon \
    freetype2 harfbuzz cairo pango \
    greetd greetd-tuigreet \
    fish vim neovim \
    waybar swww mako nwg-look \
    thunar gvfs udiskie \
    ttf-martian-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    imv mpv zathura-pdf-mupdf \
    wl-clipboard cliphist grim slurp \
    iwd openssh systemd-networkd systemd-resolved curl \
    pamixer pavucontrol \
    ripgrep fastfetch stow brightnessctl tar zip unzip
```

### 3. Paru (AUR Helper)

Checks if `paru` is already installed. If not, it is compiled and installed from the AUR.

```bash
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si --noconfirm
```

### 4. AUR packages

Installs additional packages available only on the AUR:

```bash
paru -S --needed --noconfirm asdf-vm bibata-cursor-theme-bin google-chrome tofi
```

| Package | Description |
|---|---|
| `asdf-vm` | Multi-language version manager (Node, Python, Ruby, etc.) |
| `bibata-cursor-theme-bin` | Minimal and modern cursor theme |
| `google-chrome` | Google Chrome browser |
| `tofi` | Minimal application launcher for Wayland |

### 5. Display Manager (greetd)

Removes `sddm` if installed to avoid conflicts, then sets up `greetd` with `tuigreet` as the login manager.

The generated configuration at `/etc/greetd/config.toml`:

```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
```

The service is enabled automatically:

```bash
sudo systemctl enable --now greetd
```

### 6. GTK Theme — Graphite

Clones and installs the [Graphite GTK Theme](https://github.com/vinceliuice/Graphite-gtk-theme) system-wide under `/usr/share/themes`, with the `black` and `rimless` tweaks.

```bash
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git /tmp/graphite
cd /tmp/graphite
sudo ./install.sh -d /usr/share/themes --tweaks black rimless
```

### 7. Icons — YAMIS

Clones and installs the [YAMIS](https://github.com/googIyEYES/YAMIS) icon pack globally under `/usr/share/icons/YAMIS`.

```bash
git clone https://github.com/googIyEYES/YAMIS.git /tmp/yamis
sudo cp -r /tmp/yamis /usr/share/icons/YAMIS
```

### 8. Fish Shell

Adds `fish` to the list of valid shells in `/etc/shells` and sets it as the default shell for the current user.

```bash
echo $(which fish) | sudo tee -a /etc/shells
sudo chsh -s $(which fish) $USER
```

### 9. Dotfiles with GNU Stow

Clones this dotfiles repository and uses `stow` to create symlinks for all configs into `$HOME`.

```bash
git clone https://github.com/hananitallyson/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .
```

`stow .` mirrors the directory structure from `~/dotfiles` into `~/`. For example, `~/dotfiles/.config/hypr/` becomes a symlink at `~/.config/hypr/`.

---

## Package details

### Compositor & Wayland

| Package | Description |
|---|---|
| `hyprland` | Dynamic tiling Wayland compositor with animations and eye candy |
| `wayland` | Modern display server protocol, replacing X11 |
| `wayland-protocols` | Extra protocol extensions for Wayland |
| `xdg-user-dirs` | Manages standard user directories (`~/Downloads`, `~/Documents`, etc.) |
| `libxkbcommon` | Keyboard mapping library for Wayland |
| `meson` | Build system (required by some Wayland packages) |
| `scdoc` | Man page generator (build dependency) |

### GPU & Drivers

| Package | Description |
|---|---|
| `amd-ucode` | Security microcode updates for AMD CPUs |
| `mesa` | Open-source OpenGL/Vulkan implementation |
| `lib32-mesa` | 32-bit Mesa build (for Wine and game compatibility) |
| `vulkan-radeon` | Vulkan driver for AMD GPUs (RADV) |
| `lib32-vulkan-radeon` | 32-bit Vulkan driver for AMD GPUs |

> Replace with `nvidia` or `intel-media-driver` if not using AMD.

### Text Rendering

| Package | Description |
|---|---|
| `freetype2` | Font rendering engine |
| `harfbuzz` | Text shaping engine (unicode, ligatures, etc.) |
| `cairo` | 2D vector graphics library |
| `pango` | Internationalized text layout and rendering |

### Display Manager

| Package | Description |
|---|---|
| `greetd` | Minimal and flexible display manager |
| `greetd-tuigreet` | Terminal UI greeter frontend for greetd |

### Shell & Editors

| Package | Description |
|---|---|
| `fish` | Modern interactive shell with smart autocompletion |
| `vim` | Classic terminal text editor |
| `neovim` | Modern Vim fork, extensible via Lua |

### Interface & Widgets

| Package | Description |
|---|---|
| `waybar` | Highly customizable status bar for Wayland |
| `swww` | Animated wallpaper daemon for Wayland |
| `mako` | Lightweight notification daemon for Wayland |
| `nwg-look` | GTK theme configurator for Wayland environments |

### File Manager

| Package | Description |
|---|---|
| `thunar` | Lightweight and fast GTK file manager |
| `gvfs` | Virtual filesystem backend for Thunar (network shares, trash, etc.) |
| `udiskie` | Automounter for USB devices with systray support |

### Fonts

| Package | Description |
|---|---|
| `ttf-martian-mono-nerd` | Monospace font with Nerd Font icons (used in the terminal) |
| `noto-fonts` | Google Noto font family for multilingual support |
| `noto-fonts-emoji` | Color emoji font (Google Noto) |
| `noto-fonts-cjk` | Chinese, Japanese, and Korean character support |

### Media

| Package | Description |
|---|---|
| `imv` | Minimal image viewer for Wayland |
| `mpv` | Powerful and scriptable video player |
| `zathura-pdf-mupdf` | Minimal PDF reader with Vim-like keybindings |

### Clipboard & Screenshots

| Package | Description |
|---|---|
| `wl-clipboard` | `wl-copy` / `wl-paste` clipboard utilities for Wayland |
| `cliphist` | Clipboard history manager for Wayland |
| `grim` | Screenshot tool for Wayland |
| `slurp` | Screen region selector (used alongside grim) |

### Networking

| Package | Description |
|---|---|
| `iwd` | Modern and lightweight Wi-Fi daemon (replaces wpa_supplicant) |
| `openssh` | SSH client and server |
| `systemd-networkd` | systemd-integrated network manager |
| `systemd-resolved` | systemd-integrated DNS resolver |
| `curl` | Command-line tool for data transfer |

### Audio

| Package | Description |
|---|---|
| `pamixer` | Command-line volume control (PulseAudio/Pipewire) |
| `pavucontrol` | Graphical audio control interface |

### Utilities

| Package | Description |
|---|---|
| `ripgrep` | Ultra-fast `grep` alternative written in Rust |
| `fastfetch` | System information display tool (neofetch successor) |
| `stow` | Symlink manager for dotfiles |
| `brightnessctl` | Screen brightness control via command line |
| `tar` / `zip` / `unzip` | Compression and archiving tools |

---

## Dotfiles structure

```
~/dotfiles/
├── .config/
│   ├── hypr/          # Hyprland configuration
│   ├── waybar/        # Status bar configuration
│   ├── fish/          # Fish shell configuration
│   ├── nvim/          # Neovim configuration
│   ├── mako/          # Notification daemon configuration
└── └── tofi/          # Application launcher configuration
```

The exact structure depends on your dotfiles. `stow .` handles creating the correct symlinks automatically.

---

## Post-installation

After rebooting, you may want to:

Enable Wi-Fi with iwd:

```bash
sudo systemctl enable --now iwd
iwctl station wlan0 connect "Network Name"
```

Enable systemd-networkd and resolved:

```bash
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
```

Enable SSH:

```bash
sudo systemctl enable --now sshd
```

Apply the GTK theme with nwg-look:

```bash
nwg-look
```
