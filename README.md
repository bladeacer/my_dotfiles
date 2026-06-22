# bladeacer's dotfiles

In this repository, you can find the dotfiles I use.

## Configurations included

- `fastfetch`: Custom blue rose fastfetch
- `nvim`: Custom startpage plugin for rendering 24-bit ANSI art, opinionated
  terminal keybinds, and language specific LSP integrations
- `vim`: Everyone's favourite terminal text editor, used to daily drive this
- `tmux`: Terminal window multiplexing
- `alacritty`: Terminal emulator
- `bash`: Shell aliases and niceties
- `starship`: Shell prompt config
- `fcitx5`: Integrated CJK IME configs
- `zathura`: Keyboard-driven document viewer
- KDE Plasma configs: Background shortcuts and panel exclusion rules
- `navishell`: Custom Qt Quick Wayland shell with KDE Plasma 6 integration

- `hyprland [DEPRECATED]`: Legacy compositor configurations

### Blue Rose Logo

The neovim startpage renders a blue rose ANSI art at `logo/blue_rose`.
The `navishell` status bar also displays a braille rendering of Copland OS logo.


## Palette

Iceberg Dark. See [iceberg.vim](https://github.com/cocopon/iceberg.vim) for more 
details on the original colours scheme.

---

## About navishell

`navishell` is a custom Lain-themed (Serial Experiments Lain) Quickshell setup built with
QML components: app launcher, system controls, media HUD,
task bar, overlay panels, background spectrum visualizer, and animated
shader effects.


### Requirements for navishell

- EndeavourOS / Arch Linux with KDE Plasma 6 (Wayland)
- Quickshell: Qt Quick Wayland shell
- Departure Mono Nerd Font Mono: global monospace font
- `lookas` (via `quickshell/lookas-bridge`): perception-aligned spectrum visualiser
- Rust toolchain (for building `lookas-bridge`)
- `kdotool`: KDE window enumeration and focus tracking (AUR)
- Standard CLI tools: `wpctl`, `brightnessctl`, `nmcli`, `playerctl`,
  `bluetoothctl`, `fcitx5-remote`

## Keybinds (navishell)

| Key | Action |
|-----|--------|
| `Meta+Space` | Toggle app launcher |
| `Meta+S` | Toggle system control centre |
| `Escape` | Close all popups |
| `Ctrl+N` / `J` | Next item |
| `Ctrl+P` / `K` | Previous item |
| `H` / `L` | Tab switch (sys control) |
| `Enter` | Execute / launch |

`navishell` is a work in progress, expect breaking changes.

---

## Installation (Arch Linux)

```bash
git clone https://codeberg.org/bladeacer/my_dotfiles.git ~/my_dotfiles
cd ~/my_dotfiles
./setup.sh
```

The setup script will:
1. Install required packages (stow, neovim, quickshell, playerctl, etc.)
2. Stow all dotfiles to their proper locations
3. Set up navishell autostart

### Building lookas-bridge

```bash
# Requires: Rust toolchain
cd quickshell/lookas-bridge
cargo build --release
```

The bridge pipes 77 mel-scaled, A-weighted, spring-damped bar heights to
the QML canvas at 60 fps (bar count computed from screen width via
bar- and gap-width ratios; 77 at typical desktop resolutions).

Config via `~/.config/lookas.toml`, stowed under `lookas` here.
(see [lookas docs](https://github.com/rccyx/lookas)).

### Manual stow

```bash
cd ~/my_dotfiles
stow bash            # ~/.bashrc, etc.
stow nvim            # ~/nvim/
stow quickshell      # ~/.config/quickshell/
stow kde             # ~/.config/kdeglobals, etc.
stow colors_kde      # ~/colors_kde/
stow tmux            # ~/.tmux.conf
```

Or better yet, use `stow <package-name> -t ~/path_to/target_dir` if
you know what you are doing.

---

## Credits

- [IcebergDark](https://github.com/gkeep/iceberg-dark): Colour palette
- [iceberg.vim](https://github.com/cocopon/iceberg.vim): Original Iceberg colour
  scheme
- [Persona-Quickshell](https://github.com/Yujonpradhananga/Persona-Quickshell):
  Layout concepts, GLSL shaders, fluid animation patterns
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell): System
  status indicators, panel layout strategies, interactive matrix patterns
- [LainOS-ricer-arch](https://codeberg.org/LainOS/LainOS-ricer-arch): Copland
  OS logo and theme inspiration
- [lookas](https://github.com/rccyx/lookas): Perception-aligned audio spectrum
  visualiser (used as analysis engine for the background visualiser)

## Development & Testing

Run `make help` (or just `make`) to see all available targets:

```
$ make
Usage: make <target>
  help           Show this help (default)
  calibrate      Run screen calibration
  shell          Start navishell
  test           Run all tests (bash + python)
  test-bash      Run telemetry pipe unit tests (bash)
  test-py        Run save-offset unit tests (pytest)
  bridge-release Build lookas-bridge in release mode
  setup          Run full setup script
```

Before deploying QML changes, run all tests:

```bash
make test       # bash + python tests
make test-bash  # telemetry pipe tests only
make test-py    # save-offset unit tests only
```

`make` (default) prints a help screen listing all targets.

The bash tests validate every command in `shell.qml`'s telemetry pipe
(battery, wifi, media, volume, brightness, keyboard layout, focus tracking)
produces the expected output format. Run `make test-bash` before restarting
the shell to catch regressions.

The focus tracking test uses `kdotool` + `qdbus` to query the active KDE
window via `org.kde.KWin.getWindowInfo`. See `shell.qml` for the telemetry
pipe integration and `components/TaskTracker.qml` for the KDE window
enumeration fallback.

## License

Unlicence, see [LICENSE](./LICENSE)
