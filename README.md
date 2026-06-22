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

---

## About navishell

`navishell` is a custom Lain-themed (Serial Experiments Lain) Quickshell inspired
setup built with QML components: app launcher, system controls, media HUD,
task bar, overlay panels, background spectrum visualizer, and animated
shader effects.

Pairing with Iceberg Dark and Departure Mono felt suitable, that being said this
is not purely a Lain inspired rice. There are plenty of blue roses
and the wallpaper is not too similar to the vibes by purely Lain inspired rices.

Since KDE is used, mouse usage is possible and sometimes expected.
> Until I have key binds for everything in the rice itself.

### Logo Usage

The fastfetch and neovim startpage renders a blue rose ANSI art at `logo/blue_rose`.
The `navishell` system controls also displays a braille rendering of Copland OS logo.

## Palette

Iceberg Dark. See [iceberg.vim](https://github.com/cocopon/iceberg.vim) for more 
details on the original colours scheme.


### Requirements for navishell

- EndeavourOS / Arch Linux with KDE Plasma 6 (Wayland)
- Quickshell: Qt Quick Wayland shell
- Departure Mono Nerd Font Mono: primary monospace font for the status bar
- Maple Mono: CJK fallback for Chinese/Japanese/Korean glyphs
  (see [Maple-font](https://github.com/subframe7536/Maple-font))
> Installed separately via GitHub releases, AUR package is not recommended by maintainer.

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
| `Ctrl+N` | Next item |
| `Ctrl+P` | Previous item |
| `Enter` | Execute / launch |

<!-- | `H` / `L` | Tab switch (sys control) | -->

`navishell` is a work in progress, expect breaking changes.

---

## Installation (Arch Linux)

```bash
git clone https://codeberg.org/bladeacer/my_dotfiles.git ~/my_dotfiles
cd ~/my_dotfiles
chmod +x setup.sh
./setup.sh # or make setup
```

The setup script will:
1. Install required packages (stow, neovim, quickshell, playerctl, etc.)
2. Stow all dotfiles to their proper locations
3. Set up navishell autostart

### Building lookas-bridge

tldr; lookas is cava but more accurate. This bridge is so that we can
interface with the `lookas` library itself.

```bash
# Requires: Rust toolchain
cd quickshell/lookas-bridge
cargo build --release
```

The bridge pipes 77 mel-scaled, A-weighted, spring-damped bar heights to
the QML canvas at 60 fps (bar count computed from screen width via
bar- and gap-width ratios; 77 at typical desktop resolutions).

Config via [`./lookas/lookas.toml`](./lookas/lookas.toml), stowed under `lookas` here.
see [lookas docs](https://github.com/rccyx/lookas).

### Manual calibration

The spectrum visualiser offset per screen is stored in
`~/.config/quickshell/calibrations.json`. To set precise values without
using the interactive calibration tool, edit the file directly:

```json
{
  "HDMI-A-1": 131.0,
  "eDP-1": 248.5
}
```

Each entry maps a screen name to a calibrated position (in pixels).
After editing, restart the shell. The save-offset tool reads from this
file (`python3 quickshell/save-offset.py --help` for CLI usage).

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

---

## Credits

### Typography

- [Departure Mono](https://www.departuremono.com/): Primary monospace font
  used. Licensed under the SIL Open Font License.
- [Maple Mono](https://github.com/subframe7536/Maple-font): CJK fallback font
  for Chinese/Japanese/Korean glyphs. Licensed under the SIL Open Font License.

### Colours

- [IcebergDark](https://github.com/gkeep/iceberg-dark): Colour palette.
Licensed under the MIT License.
- [iceberg.vim](https://github.com/cocopon/iceberg.vim): Original Iceberg colour
  scheme. Licensed under the MIT License.

### Dotfiles

- [Persona-Quickshell](https://github.com/Yujonpradhananga/Persona-Quickshell):
  Referenced for layout concepts, GLSL shaders, fluid animation patterns
Licensed under the MIT License.

- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell): Referenced
for System status indicators, panel layout strategies, interactive matrix patterns.
Licensed under the MIT License.

- [LainOS-ricer-arch](https://codeberg.org/LainOS/LainOS-ricer-arch): 
Referenced for ASCII Copland OS logo. License not indicated.

### Dependencies

- [Quickshell](https://git.outfoxxed.me/quickshell/quickshell) Widget
configuration in QML. Licensed under LGPLv3 License.

- [lookas](https://github.com/rccyx/lookas): Perception-aligned audio spectrum
  visualiser (used as analysis engine for the background visualiser).
  Licensed under the MIT License.

## License

Unlicence, see [LICENSE](./LICENSE).
