#!/bin/bash
set -euo pipefail

STOW_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="/usr/local/bin:/usr/bin:/bin"

echo "==> dotfiles setup :: Arch Linux"
echo ""

# ── Install dependencies ──
echo "==> Installing system packages..."
sudo pacman -S --needed --noconfirm \
    stow git neovim tmux alacritty \
    fzf ripgrep fd zoxide fastfetch \
    playerctl brightnessctl \
    pipewire wireplumber \
    bluez bluez-utils networkmanager nmcli \
    chafa starship go \
    qt6-quick qt6-quick3d qt6-quicktimeline qt6-svg qt6-declarative \
    qt6-wayland qt6-shadertools \
    ttf-departure-mono-nerd noto-fonts-emoji \
    fuse2 cava \
    >/dev/null 2>&1 || {
    echo "ERROR: pacman install failed. Check your network/mirrors."
    exit 1
}

# AUR packages
for pkg in quickshell kdotool; do
    if ! pacman -Qs "$pkg" >/dev/null 2>&1; then
        echo "==> Installing $pkg (AUR)..."
        for helper in paru yay; do
            if command -v "$helper" >/dev/null 2>&1; then
                "$helper" -S --noconfirm "$pkg" >/dev/null 2>&1 && break
            fi
        done
        if ! pacman -Qs "$pkg" >/dev/null 2>&1; then
            echo "WARNING: $pkg not found. Install from AUR manually:"
            echo "  paru -S $pkg  # or yay -S $pkg"
        fi
    fi
done

# ── Stow everything ──
echo ""
echo "==> Stowing dotfiles..."

stow_packages=(
    bash nvim tmux vim alacritty
    fontconfig fcitx5 zathura
    colors_kde kde autostart
    quickshell
)

for pkg in "${stow_packages[@]}"; do
    if [ -d "$STOW_DIR/$pkg" ]; then
        echo "  stow $pkg"
        stow -d "$STOW_DIR" -t "$HOME" "$pkg" 2>/dev/null || {
            echo "  WARNING: stow $pkg failed (may already be linked)"
        }
    fi
done

# ── Ensure quickshell autostart ──
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
if [ -f "$STOW_DIR/autostart/quickshell.desktop" ]; then
    cp "$STOW_DIR/autostart/quickshell.desktop" "$AUTOSTART_DIR/"
fi

echo ""
echo "==> Done!"
echo "    Log out and back in, or run: quickshell"
