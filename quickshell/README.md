# quickshell

A Lain-themed Quickshell desktop shell with native QML components: app launcher, system controls, media HUD, task bar, overlay panels, background spectrum visualizer, and animated shader effects.

### Requirements

- EndeavourOS / Arch Linux with KDE Plasma 6 (Wayland)
- [Quickshell](https://github.com/Quickshell/Quickshell) — Qt Quick Wayland shell
- Departure Mono Nerd Font Mono — global monospace font
- `cava` — audio spectrum visualizer
- Standard CLI tools: `wpctl`, `brightnessctl`, `nmcli`, `playerctl`, `bluetoothctl`, `fcitx5-remote`

### Setup

```bash
# Install dependencies
sudo pacman -S cava pipewire wireplumber networkmanager playerctl bluez-utils fcitx5

# Link config (already done if you ran setup.sh)
ln -sf ~/my_dotfiles/quickshell/.config/quickshell ~/.config/quickshell

# Launch
quickshell
```

### Keybinds

| Key | Action |
|-----|--------|
| `Meta+Space` | Toggle app launcher |
| `Meta+S` | Toggle system control centre |
| `Escape` | Close all popups |
| `Ctrl+N` / `J` | Next item |
| `Ctrl+P` / `K` | Previous item |
| `H` / `L` | Tab switch (sys control) |
| `Enter` | Execute / launch |

### Structure

```
~/.config/quickshell/
├── shell.qml                 # Entry point, telemetry, hotkeys, overlays
├── theme/Theme.qml           # IcebergDark palette, blockMeter, frame headers
├── components/
│   ├── StatusBar.qml         # 28px top bar
│   ├── AppLauncher.qml       # Fuzzy-search launcher
│   ├── SystemControlCenter.qml   # Audio/Network/Power + art panel
│   ├── MediaHUD.qml          # Now-playing overlay
│   ├── SpectrumVisualizer.qml    # Cava-driven 24-band audio bars
│   ├── TaskTracker.qml       # Pinned + running windows
│   ├── WifiWidget.qml        # Wi-Fi scan list
│   └── BluetoothControlCenter.qml # Paired device manager
├── services/
│   ├── FocusedWindow.qml     # Active window tracker
│   └── WifiService.qml       # Wi-Fi scan processes
└── shaders/
    ├── tidal.frag            # Kanagawa tidal wave GLSL shader
    └── tidal.frag.qsb        # Compiled QSB
```

### Palette

IcebergDark — `#161821` bg, `#1e2132` header, `#c6c8d1` fg, `#84a0c6` accent blue

### Credits

- [IcebergDark](https://github.com/gkeep/iceberg-dark) — colour palette
- [iceberg.vim](https://github.com/cocopon/iceberg.vim) — original Iceberg colour scheme
- [Persona-Quickshell](https://github.com/Yujonpradhananga/Persona-Quickshell) — layout concepts, GLSL shaders
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) — telemetry modules, panel layouts
