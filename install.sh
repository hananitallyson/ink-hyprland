#!/bin/bash

set -euo pipefail

# Configuration
DOTFILES_REPO="https://github.com/hananitallyson/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: Do not run as root. The script will ask for sudo when needed."
    exit 1
fi

echo "--- Step 1: Installing base-devel and git ---"
sudo pacman -S --needed --noconfirm base-devel git

echo "--- Step 2: Installing official packages ---"
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

echo "--- Step 3: Checking for paru (AUR Helper) ---"
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    TEMP_PARU=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$TEMP_PARU"
    cd "$TEMP_PARU"
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf "$TEMP_PARU"
    echo "paru installed successfully."
else
    echo "paru is already installed. Skipping."
fi

echo "--- Step 4: Installing AUR packages ---"
paru -S --needed --noconfirm asdf-vm bibata-cursor-theme-bin google-chrome tofi

echo "--- Step 5: Configuring Display Manager (greetd) ---"
if pacman -Qs sddm > /dev/null; then
    echo "Removing sddm to avoid conflicts..."
    sudo systemctl disable sddm 2>/dev/null || true
    sudo pacman -Rns --noconfirm sddm
fi

sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
EOF

sudo systemctl enable --now greetd
echo "greetd enabled."

echo "--- Step 6: Installing Graphite GTK Theme (System-wide) ---"
if [ ! -d "/usr/share/themes/Graphite-dark" ]; then
    TEMP_GRAPHITE=$(mktemp -d)
    git clone https://github.com/vinceliuice/Graphite-gtk-theme.git "$TEMP_GRAPHITE"
    cd "$TEMP_GRAPHITE"
    # The -l flag usually installs for the local user, but running with sudo or 
    # without -l targetting /usr/share is better for system-wide.
    # Check theme script help if it fails; usually ./install.sh installs to ~/.themes
    sudo ./install.sh -d /usr/share/themes --tweaks black rimless
    cd - > /dev/null
    rm -rf "$TEMP_GRAPHITE"
    echo "Graphite theme installed system-wide."
else
    echo "Graphite theme already exists. Skipping."
fi

echo "--- Step 7: Installing YAMIS Icon Set (System-wide) ---"
if [ ! -d "/usr/share/icons/YAMIS" ]; then
    TEMP_YAMIS=$(mktemp -d)
    git clone https://github.com/googIyEYES/YAMIS.git "$TEMP_YAMIS"
    sudo mkdir -p /usr/share/icons/
    sudo cp -r "$TEMP_YAMIS" /usr/share/icons/YAMIS
    rm -rf "$TEMP_YAMIS"
    echo "YAMIS icons installed system-wide."
else
    echo "YAMIS icons already exist. Skipping."
fi

echo "--- Step 8: Configuring Fish Shell ---"
FISH_BIN=$(command -v fish)
if ! grep -q "$FISH_BIN" /etc/shells; then
    echo "Adding fish to /etc/shells..."
    echo "$FISH_BIN" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$FISH_BIN" ]; then
    echo "Changing default shell to fish for $USER..."
    sudo chsh -s "$FISH_BIN" "$USER"
fi

echo "--- Step 9: Cloning and applying dotfiles ---"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles to $HOME/dotfiles..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists. Updating..."
    cd "$DOTFILES_DIR" && git pull && cd - > /dev/null
fi

cd "$DOTFILES_DIR"
echo "Running stow..."
# stow . will symlink everything in the current dir to the parent (usually $HOME)
stow .

echo "-------------------------------------------"
echo "Setup complete! Please reboot your system."
echo "-------------------------------------------"
