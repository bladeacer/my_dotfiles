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

# ── Quickshell + kdotool (AUR) ──
# kdotool is required on KDE Plasma: KWin intentionally
# does not implement the zwlr-foreign-toplevel-management-v1
# protocol (KDE bug 502647), so quickshell's native
# ToplevelManager never reports windows on KWin. kdotool
# drives KWin's scripting API over D-Bus and works for
# both Wayland-native and XWayland windows.
# (Building quickshell from source gains nothing on KDE.)
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
    quickshell plasma_shutdown_fix
    xprofile
)

# Per-package "do not deploy this" patterns. GNU stow 2.4 only honours the
# --ignore option; a .stow-ignore file inside the package is ignored (and
# stow even tries to deploy the ignore file itself). The pattern is a Perl
# regex matched against the path inside the package, so it has to be
# anchored - "^kde" alone would not cover "kde/FlexcyonDark.colors".
#
# colors_kde/kde is a git submodule (github.com/flexcyon/kde) holding the
# upstream Flexcyon colour schemes. They are installed into
# ~/.local/share/color-schemes/ separately; deploying them from here would
# drop a ~/kde/ directory into the home root.
declare -A stow_ignores=(
    [colors_kde]='^kde(/.*)?$'
    [quickshell]='^\.pytest_cache(/.*)?$'
)

for pkg in "${stow_packages[@]}"; do
    if [ -d "$STOW_DIR/$pkg" ]; then
        echo "  stow $pkg"

        # `stow` aborts the *whole* package if any target already exists as
        # a regular file instead of a symlink, so one leftover file would
        # silently skip every other file in the package. Clear those
        # targets first: identical content just becomes the symlink, and
        # anything genuinely different is moved aside rather than lost.
        while IFS= read -r rel; do
            [ -n "$rel" ] || continue
            tgt="$HOME/$rel"
            src="$STOW_DIR/$pkg/$rel"
            [ -e "$tgt" ] || continue
            [ -L "$tgt" ] && continue
            if cmp -s "$tgt" "$src"; then
                rm -f "$tgt"
                echo "    replaced identical $tgt with symlink"
            else
                mv "$tgt" "$tgt.pre-dotfiles"
                echo "    moved differing $tgt -> $tgt.pre-dotfiles"
            fi
        done < <(cd "$STOW_DIR/$pkg" && find . -type f -printf '%P\n' 2>/dev/null)

        # --no-folding: without it stow replaces a whole top-level
        # directory with a symlink to the package's copy. On a fresh
        # machine ~/.config or ~/.local does not exist yet, so
        # `stow kde` would turn ~/.config into a link to the repo and
        # `stow fcitx5` would do the same for ~/.local - taking the
        # user's real config with them. Folding off means stow always
        # creates real directories and symlinks the individual files.
        stow_args=(-d "$STOW_DIR" -t "$HOME" --no-folding)
        if [ -n "${stow_ignores[$pkg]+set}" ]; then
            stow_args+=(--ignore="${stow_ignores[$pkg]}")
        fi

        stow "${stow_args[@]}" "$pkg" 2>/dev/null || {
            echo "  WARNING: stow $pkg failed (may already be linked)"
        }
    fi
done

# ── Stow system files (SDDM greeter) ──
# 99-no-virtual-keyboard.conf overrides EndeavourOS's
# InputMethod=qtvirtualkeyboard in 10-endeavouros.conf, which otherwise
# pops a full-screen Qt virtual keyboard over the login page.
if [ -d "$STOW_DIR/sddm" ]; then
    echo "  stow sddm -> /etc"

    # The KDE setup wizard writes /etc/sddm.conf.d/kde_settings.conf
    # directly. That file is now tracked as 50-kde-settings.conf, and SDDM
    # reads *every* file in /etc/sddm.conf.d/ with the last-sorted one
    # winning — a stray copy sorting after 99- would silently re-enable the
    # virtual keyboard. Move it out of the drop-in directory (SDDM does not
    # filter by extension, so a .bak inside it would still be read).
    if [ -f /etc/sddm.conf.d/kde_settings.conf ] && [ ! -L /etc/sddm.conf.d/kde_settings.conf ]; then
        sudo mv /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.kde_settings.conf.bak
        echo "  moved stray /etc/sddm.conf.d/kde_settings.conf -> /etc/sddm.conf.kde_settings.conf.bak"
    fi

    # A plain `stow` refuses to replace a regular file that is already in
    # the way, so the drop-in would never land and the greeter would keep
    # showing the keyboard. Move any such file aside first.
    for f in "$STOW_DIR"/sddm/sddm.conf.d/*.conf; do
        [ -e "$f" ] || continue
        tgt="/etc/sddm.conf.d/$(basename "$f")"
        if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
            sudo mv "$tgt" "$tgt.pre-dotfiles"
            echo "  moved pre-existing $tgt -> $tgt.pre-dotfiles"
        fi
    done

    # --no-folding for the same reason as the home packages: folding
    # would replace /etc/sddm.conf.d with a symlink to the repo, which
    # would hide the package-managed 10-endeavouros.conf.
    sudo stow -d "$STOW_DIR" -t /etc --no-folding --restow sddm || {
        echo "  ERROR: stow sddm failed — the greeter may still show the virtual keyboard"
    }
fi

# ── Verify the greeter really has no virtual keyboard ──
# Guards the Plasma 6.8 greeter bug: a mobile-styled Qt virtual keyboard
# scaled over the whole login page, popping up every time the password
# field took focus. The drop-in is load-bearing — SDDM's own default for
# InputMethod is "qtvirtualkeyboard" — so verify it actually took effect.
if [ -r "$STOW_DIR/lib/sddm-config.sh" ]; then
    # shellcheck source=/dev/null
    . "$STOW_DIR/lib/sddm-config.sh"
    im="$(sddm_effective_value General InputMethod)"
    if [ -n "$im" ]; then
        echo "  ERROR: SDDM's effective InputMethod is '$im' — the greeter WILL show the"
        echo "         Qt virtual keyboard over the login screen."
        echo "         Look for a file in /etc/sddm.conf.d/ that sorts after"
        echo "         99-no-virtual-keyboard.conf and sets InputMethod=."
    else
        echo "  greeter virtual keyboard: disabled (SDDM InputMethod is empty)"
    fi
fi

# ── Ensure quickshell autostart ──
# The autostart package is stowed like the rest, so the .desktop file is a
# symlink into the repo. Do not copy it over that symlink - that would
# turn it into a stale regular file that no longer tracks the repo.
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

echo ""
echo "==> Done!"
echo "    Log out and back in, or run: quickshell"
