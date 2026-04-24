# INK HYPRLAND

Manual setup guide for my personal Arch Linux environment using Hyprland as the Wayland compositor, Fish shell, Neovim, and GNU Stow for dotfile management.

---

## TABLE OF CONTENTS

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Base Dependencies](#base-dependencies)
  - [GPU Drivers](#gpu-drivers)
  - [Wayland & Hyprland](#wayland--hyprland)
  - [Display Manager](#display-manager)
  - [Paru](#paru)
  - [Terminal & Editors](#terminal--editors)
  - [Interface](#interface)
  - [GTK Theme](#gtk-theme)
  - [Icons](#icons)
  - [Cursor](#cursor)
  - [Fonts](#fonts)
  - [File Manager](#file-manager)
  - [Audio](#audio)
  - [Media](#media)
  - [Clipboard & Screenshots](#clipboard--screenshots)
  - [Networking](#networking)
  - [Utilities](#utilities)
  - [asdf-vm](#asdf-vm)
  - [Tree-sitter](#tree-sitter)
  - [Dotfiles](#dotfiles)
  - [TLP](#tlp)
  - [auto-cpufreq](#auto-cpufreq)
- [Post-installation](#post-installation)

---

## PREREQUISITES

- Arch Linux installed and running
- Internet access
- A regular user with `sudo` access (do **not** run as root)
- AMD GPU (this guide installs `vulkan-radeon` and `mesa` drivers)

> If you use NVIDIA or Intel, replace the GPU driver packages in the [GPU Drivers](#gpu-drivers) section.

---

## INSTALLATION

### BASE DEPENDENCIES

Install `base-devel` and `git`, required to compile packages and clone repositories.

```bash
sudo pacman -S --needed base-devel git
```

Verify:

```bash
git --version
```

---

### GPU DRIVERS

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

### WAYLAND & HYPRLAND

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

### DISPLAY MANAGER

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

### PARU

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

### TERMINAL & EDITORS

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

### INTERFACE

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

### GTK THEME

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

### ICONS

Clone the [YAMIS](https://github.com/googIyEYES/YAMIS) repository, extract the icon pack to a temporary directory, copy it to the system icons directory, then clean up:

```bash
git clone https://github.com/googIyEYES/YAMIS.git /tmp/yamis
cd /tmp/yamis
tar -xzvf monochrome-icon-theme.tar.gz -C /tmp/yamis/
sudo cp -r /tmp/yamis/YAMIS /usr/share/icons/YAMIS
rm -rf /tmp/yamis
```

Verify:

```bash
ls /usr/share/icons | grep YAMIS
```

---

### CURSOR

Install the Notwaita cursor theme from the AUR:

```bash
paru -S --needed notwaita-cursor-theme
```

Verify:

```bash
ls /usr/share/icons | grep -i notwaita
```

---

### FONTS

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

### FILE MANAGER

Install Thunar and its supporting packages:

```bash
sudo pacman -S --needed thunar gvfs udiskie
```

Verify Thunar launches:

```bash
thunar --version
```

---

### AUDIO

Install the audio control tools:

```bash
sudo pacman -S --needed pamixer pavucontrol
```

Verify:

```bash
pamixer --version
```

---

### MEDIA

Install the image viewer, video player, and PDF reader:

```bash
sudo pacman -S --needed imv mpv zathura-pdf-mupdf
```

Verify:

```bash
mpv --version | head -1
```

---

### CLIPBOARD & SCREENSHOTS

Install clipboard and screenshot utilities:

```bash
sudo pacman -S --needed wl-clipboard cliphist grim slurp
```

Verify:

```bash
grim --help 2>&1 | head -1
```

---

### NETWORKING

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

### UTILITIES

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

### ASDF-VM

Install `asdf-vm` from the AUR:

```bash
paru -S --needed asdf-vm
```

Verify:

```bash
asdf version
```

---

### TREE-SITTER

Install the `tree-sitter` CLI, which is required to compile and update parsers used by Neovim plugins:

```bash
sudo pacman -S tree-sitter-cli
```

---

### DOTFILES

Clone this repository and use `stow` to symlink all configs into `$HOME`:

```bash
git clone https://github.com/hananitallyson/dotfiles.git ~/dotfiles
cd ~/dotfiles

rm -rf ~/.config/fastfetch \
       ~/.config/fish \
       ~/.config/hypr \
       ~/.config/imv \
       ~/.config/kitty \
       ~/.config/mako \
       ~/.config/mpv \
       ~/.config/nvim \
       ~/.config/tofi \
       ~/.config/waybar

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

### TLP

> Laptop only. Skip if running on a desktop.

[TLP](https://linrunner.de/tlp/) is a power management tool that optimizes battery life automatically.

Install TLP and the radio device wizard:

```bash
sudo pacman -S --needed tlp tlp-rdw
```

Enable the services and mask conflicting ones:

```bash
sudo systemctl enable tlp.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

Start TLP immediately without rebooting:

```bash
sudo tlp start
```

Verify TLP is running:

```bash
sudo tlp-stat -s
```

---

### AUTO-CPUFREQ

> Laptop only. Skip if running on a desktop.

[auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq) automatically adjusts CPU speed and governor based on power source and system load.

Install from the AUR:

```bash
paru -S --needed auto-cpufreq
```

Enable and start the service:

```bash
sudo systemctl enable --now auto-cpufreq
```

Verify it is running:

```bash
auto-cpufreq --stats
```

---

## POST-INSTALLATION

After rebooting, connect to Wi-Fi if needed:

```bash
sudo systemctl start iwd
iwctl station wlan0 connect "Network Name"
```

Apply the GTK theme, icons, and cursor with nwg-look:

```bash
nwg-look
```
