## bladeacer's dotfiles

In this repository, you can find the dotfiles I use.

#### Configurations included

- `nvim`
- `tmux`
- `vim`
- `opencode`
- `quickshell` (Wayland shell with KDE Plasma)
- `hyprland`
- `alacritty`
- `bash`
- KDE Plasma configs
- `starship`
- `fcitx5`
- `zathura`

#### Installation (Arch Linux)

```bash
git clone https://github.com/bladeacer/my_dotfiles.git ~/my_dotfiles
cd ~/my_dotfiles
./setup.sh
```

The setup script will:
1. Install required packages (stow, neovim, quickshell, playerctl, etc.)
2. Stow all dotfiles to their proper locations
3. Set up quickshell autostart

#### Manual stow

```bash
cd ~/my_dotfiles
stow bash            # ~/.bashrc, etc.
stow nvim            # ~/nvim/
stow quickshell      # ~/.config/quickshell/
stow kde             # ~/.config/kdeglobals, etc.
stow colors_kde      # ~/colors_kde/
stow tmux            # ~/.tmux.conf
```

#### Blue Rose Logo

The neovim startpage renders a blue rose ANSI art at `logo/blue_rose`.
The quickshell status bar also displays a compact braille rendering.

#### License

Unlicence, see [LICENSE](./LICENSE)
