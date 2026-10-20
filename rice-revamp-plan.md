# Rice Revamp — quickshell polish plan

**Status:** implementation-ready (green-lighted)
**Scope:** `quickshell/.config/quickshell/` (the navishell rice) — QML only. No dynamic/wallpaper-derived theming (intentional exclusion).

## Goal

Bring the quickshell rice up to the polish level seen in `~/Desktop/projects/DankMaterialShell` and `~/Desktop/projects/Persona-Quickshell`, but adopt it into the rice's own Iceberg Dark aesthetics: shared animation/transition library, elevation/shadow surface system, rounded corners, marquee text, per-screen `Scope`/`Variants` layout, and de-duplicated popup boilerplate — while keeping the static palette + KDE color sync and the existing `playerctl`/`kdotool` telemetry.

## Aesthetic & inspiration

The rice's own identity (from `README.md`): Lain-adjacent but not pure-Lain; Iceberg Dark palette (cocopon); Departure Mono + Maple Mono; blue roses; Copland OS braille glyph in system controls; "navishell" name. Keep this — do not reskin into DankMaterialShell's Material 3 or Persona-Quickshell's anime wallpaper look.

Adopt from references (adapted, not copied):

- **DankMaterialShell** (`~/Desktop/projects/DankMaterialShell/quickshell/Common/`): shared `Theme` singleton with surface roles (`surface`, `surfaceVariant`, `surfaceContainer`, `surfaceContainerHigh`), elevation tokens (`elevationLevel1..4`: blurPx/offsetY/alpha), `DankAnim` spring curves, `Appearance` rounding/spacing/anim tokens, `ShellLayout` per-screen resolve pattern, hover/pressed state layers.
- **Persona-Quickshell** (`~/Desktop/projects/Persona-Quickshell/`): per-screen `Scope { Variants { model: Quickshell.screens ... PanelWindow } }`, `Widgets/Marquee.qml` scrolling text, `MultiEffect`/`ShaderEffectSource` mask + glow flair, waveform backgrounds, rounded album-art masks, `Data/Colors.qml` named color roles.
- **Existing rice**: `Theme.qml` frame glyphs (`\u250c\u2500\u2510` etc.), shader transitions (dissolve/crtwipe/signallock/fade/fluid_dream/digital_rose/cyber_classic/iceberg_chill), lookas spectrum visualizer, telemetry pipe, `blockMeter` unicode bars.

Design principles (v1):
- Iceberg Dark stays static; KDE `kdeglobals` sync preserved; no matugen/wallpaper color derivation ever.
- All animation durations/easings centralized in `Theme.qml` (one source of truth) — no magic numbers per widget.
- Every popup shares one transition helper; no duplicated open/close boilerplate.
- Overflowing text uses marquee, not hard elision.
- Interactive surfaces get hover scale + press feedback; selected state uses `surfaceContainerHigh` + border.

Animation spec (centralize in `Theme.qml`, reference from widgets):
| Token | Value | Use |
|---|---|---|
| `animDur` | 140ms | micro-interactions (hover, press) |
| `openDur` | 300–400ms | popup open, Easing.OutCubic |
| `closeDur` | 200–300ms | popup close, Easing.InCubic |
| `easeStandard` | Easing.OutCubic | general entrance |
| `easeEmphasized` | Easing.OutQuart | emphasized/spatial |
| `springExpressive` | stiffness 560, damping 37 | bouncy spring (opt-in) |

## Decisions (resolved)

| Decision | Value |
|---|---|
| Plan file | `.kilo/plans/rice-revamp-plan.md` (exact user path) |
| Location | `~/.config/quickshell/` (stowed as `quickshell`) |
| Theming | Iceberg Dark static palette retained; `Theme.qml` extended with surface/elevation roles; KDE `kdeglobals` color sync kept. No matugen/wallpaper dynamic theming — ever (explicit exclusion). |
| Telemetry | Keep existing `playerctl`/`kdotool` bash pipe in `shell.qml` for v1. Defer `Quickshell.Services.Mpris` migration to v2 (out of scope). |
| Layout pattern | Adopt per-screen `Scope { Variants { model: Quickshell.screens ... PanelWindow } }` for anything that should exist per-screen (background visualizer, future clock/capsule). |
| Animation | Extract a shared transition helper (open/close + dissolve/shader overlay) so the 5 loaders stop duplicating ~150 lines each. |
| Visual polish | Rounded corners (`Theme.radius`), subtle `MultiEffect` drop-shadow/elevation on popups, border & surface roles from DankMaterialShell, marquee from Persona-Quickshell. |

## Current state (reference)

- `shell.qml` (701 lines): monolithic telemetry pipe + 5 inlined `Loader` popups (launcher, sys, mediaHUD, wifi, bt), each duplicating `startCloseTransition`, `NumberAnimation` pairs, `ShaderEffect` transitions, `Component.onCompleted` open anims.
- `theme/Theme.qml`: static Iceberg Dark palette, `blockMeter`/`frameHeader`/`frameFooter` helpers, no elevation/surface roles, no radius.
- `components/StatusBar.qml`: fixed-width slices, no marquee, hardcoded 28px bar.
- `components/TaskTracker.qml`: native + kdotool dual tracking; inline delegates, no hover scale/press feedback.
- `components/MediaHUD.qml`: static frame glyphs, no marquee, inline scrubber.
- `components/WifiWidget.qml`: inline expand/collapse, no marquee.
- `components/AppLauncher.qml`: inline list, no item press/scale feedback.
- `services/FocusedWindow.qml`: singleton, fine as-is.
- `components/SpectrumVisualizer.qml`: lookas bridge, fine as-is; bottom margin calibration hack works.

Docs consulted: `quickshell/docs/quickshell_compiled_docs.md` (ShellRoot/PanelWindow/Scope/Variants/Process/SplitParser), `DankMaterialShell/quickshell/Common/{Theme,Appearance,DankAnim,ShellLayout}.qml`, `Persona-Quickshell/{shell.qml,Layers/Capsule.qml,Layers/Clock.qml,Widgets/Marquee.qml,Data/*.qml}`, `README.md` (existing rice identity: Iceberg Dark, Lain-adjacent, Departure Mono, blue roses, Copland logo).

## Task list (execute in order)

### 1. Theme extension — surface & elevation roles
File: `quickshell/.config/quickshell/theme/Theme.qml`
- Add `radius` (e.g. 6–8), `radiusLg`, `elevation` shadow color/blur/offset tokens.
- Add surface roles: `surface`, `surfaceVariant`, `surfaceContainer`, `surfaceContainerHigh`, `onSurface`, `onSurfaceVariant` derived from existing Iceberg palette.
- Add `elevationLevel1`..`elevationLevel4` objects (`blurPx`, `offsetY`, `alpha`) modeled on DankMaterialShell `Theme.qml` elevation tokens.
- Keep all existing properties/signals unchanged so widgets don't break.
- KDE color sync (`applyKdeColors`) must recompute derived surfaces.

### 2. Shared popup transition library
File: new `quickshell/.config/quickshell/components/Popup.qml` (or `components/PopupTransition.qml`)
- A reusable `Item`/component exposing `startClose(callback)`, open/close `NumberAnimation` pair, transition `ShaderEffect` (dissolve default, optional per-popup shader), and `playingTransition`/`transitionProgress` properties.
- Parameterize: duration open/close, easing, shader path, bg color.
- Delete the duplicated ~150-line transition block from each of the 5 loader `Component`s in `shell.qml` and replace with the shared helper.

### 3. StatusBar polish
File: `quickshell/.config/quickshell/components/StatusBar.qml`
- Apply `Theme.radius` + elevation shadow to bar slices; replace hardcoded `implicitWidth`/`Layout.preferredWidth` ratios with a responsive `RowLayout` (left/center/right) using `Layout.fillWidth: true`.
- Marquee for `focusedTitle` when it overflows (Persona-Quickshell `Widgets/Marquee.qml` pattern).
- Media slice: hover scale + active accent; keep telemetry-driven metadata.

### 4. TaskTracker polish
File: `quickshell/.config/quickshell/components/TaskTracker.qml`
- Add hover scale + press feedback to pinned-app delegates; selected state uses `Theme.surfaceContainerHigh` + border.
- Unpinned running-app repeater: rounded chips with `Theme.radius`, subtle background.
- Keep native `ToplevelManager` → kdotool fallback logic intact (KDE-correct).

### 5. MediaHUD polish
File: `quickshell/.config/quickshell/components/MediaHUD.qml`
- Add `Theme.radius` + elevation to the card; album art gets `Theme.radius` crop + `MultiEffect` shadow.
- Marquee for track title/album when overflowing.
- Scrubber: use `Theme.radius` on progress bar; keep `mediaPositionStale` indeterminate behavior.
- Hover/press feedback on prev/play/next.

### 6. WifiWidget + BluetoothControlCenter polish
Files: `quickshell/.config/quickshell/components/WifiWidget.qml`, `BluetoothControlCenter.qml`
- `Theme.radius` + elevation on cards/list rows.
- Marquee SSID when overflowing; active-row highlight via `Theme.surfaceContainerHigh`.
- Keep expand/collapse + spinner behavior.

### 7. AppLauncher polish
File: `quickshell/.config/quickshell/components/AppLauncher.qml`
- Rounded search field (`Theme.radius`), selected row uses `Theme.surfaceContainerHigh` + border, hover scale on rows.
- Keep `DesktopEntries` + filter + Ctrl+N/P/J/K bindings.

### 8. Per-screen background layer (Scope/Variants)
File: `shell.qml` (Variants block) — convert the `Variants { model: Quickshell.screens ... SpectrumVisualizer }` block to the `Scope { Variants { ... } }` per-screen pattern from docs, keeping SpectrumVisualizer per screen. No behavior change, just the idiomatic pattern.

### 9. README context — inspiration & aesthetic
File: `README.md` (root). Add an "Aesthetic & inspiration" section documenting:
- Rice identity: Iceberg Dark palette, Lain-adjacent (not pure-Lain), Departure Mono + Maple Mono, blue roses, Copland OS braille glyph, "navishell" name.
- Adopted-from references with adaptation notes: DankMaterialShell (surface/elevation roles, spring curves, shared Theme), Persona-Quickshell (Scope/Variants per-screen, Marquee, MultiEffect glow/mask).
- Explicit exclusions: no wallpaper/matugen dynamic theming, no Material 3 reskin, no anime wallpaper look.
- Credit the two reference projects (already partially in Credits — expand with what was adopted vs. what was kept as rice identity).
Note: plan-mode agent does not edit non-plan docs; this task is flagged for the implementation agent.

### 10. Validation
- `qmllint` on all edited QML files (if available).
- `make test` / `make test-bash` / `make test-py` (bash telemetry + python save-offset tests) — must pass.
- Restart shell via `make shell`; visually verify: popups open/close with shared transition, radius + shadow present, marquee scrolls on overflow, bar responsive.
- Regression check: battery/wifi/media/volume/brightness/kb/focus telemetry still updates (existing bash tests cover command formats).

## Out of scope (v2 candidates)
- `Quickshell.Services.Mpris` migration (replace playerctl pipe).
- Wallpaper/matugen dynamic theming (explicitly excluded).
- New widgets (clock capsule, volume/brightness OSD, search layer).
- Per-monitor wallpaper support.

## Risks / notes
- `Theme.qml` is a `pragma Singleton`; adding derived computed properties must not break `applyKdeColors` re-application.
- The shared transition helper must preserve per-popup shader choice (dissolve/crtwipe/signallock/fade) and the `Component.onCompleted` open anim so popups still animate in on first show.
- `SplitParser` telemetry parsing in `shell.qml` is unchanged; do not touch the `onRead` handler except loader boilerplate removal.
