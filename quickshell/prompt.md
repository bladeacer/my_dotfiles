# MISSION BRIEF // REWRITE ARCHITECTURE TASK

You are explicitly authorized to completely wipe, nuke, and rewrite the existing Quickshell setup from scratch to build a clean, unified, and hyper-performant shell interface.

## 1. TARGET PLATFORM ENVIRONMENT & ZERO-DEPENDENCY MANDATE
* **Operating System:** EndeavourOS (Arch Linux base)
* **Desktop Infrastructure:** KDE Plasma 6 Framework Environment (Wayland Layer Protocol)
* **Core UI Engine:** Quickshell
* **Anti-Dependency Directive:** Keep the environment strictly un-opinionated. Do not invoke external monolithic UI programs like Rofi, Waybar, or Dunst. Write native QML implementations for components (e.g., build your own application launcher, task bar, and notification layouts natively inside the shell framework).
* **Hardware Interop:** Use native KDE/DBus parameters, standard tool binaries (`wpctl`, `brightnessctl`), or filesystem descriptors (`/sys/class/*`).

## 2. THEMES, ANIMATIONS & GLSL VISUALS
* **Palette Asset:** Extract and strictly color-map styles from `../IcebergDark.colors`.
* **Visual Direction:** Minimalist, retro-technical, command-line terminal aesthetics inspired by Serial Experiments Lain (90s anime style). Safely weave in contextual Lain concepts like "The Wired" or "Cyberia" into panel labeling schemas where appropriate.
* **Separation of Concerns:** * **Blue Rose:** Handled strictly as an ANSI Truecolor/ASCII art graphic engine loader.
    * **Matrix:** Refers explicitly to structural layout data streams, grid configurations, and systemic code arrangements. These two concepts must remain distinct.
* **Animations & Shaders:** Implement hardware-accelerated menu transitions and sliding frames using custom QML animations and embedded GLSL Fragment Shaders (`ShaderEffect`) ported from `Persona-Quickshell`.
* **Audio Visualizer:** Provide a fully realized, stable `cava`-driven audio spectrum visualizer using an asynchronous pipe into a raw data array, utilizing GLSL effects or matrix blocks to paint the equalizer bands cleanly.

## 3. UI STYLE PROFILES & DESIGN CONSTRAINTS
* **Typography:** Enforce `font.family: "Departure Mono Nerd Font Mono"` across all text components globally.
* **Design Language Limitations:** Strictly restrict graphic design components to Extended ASCII characters and native Departure Mono typographic glyph elements exclusively (e.g., `┌`, `─`, `┐`, `└`, `┘`, `│`, `◈`, `▰`). No modern multi-colored graphical emojis or generic icon packs allowed.
* **Data Status Meters:** Map telemetry signal levels and progress tracking strictly to block-matrix symbol sets:
    * `[▂▄▆█]` for Values > 75%
    * `[▂▄▆░]` for Values > 50%
    * `[▂▄░░]` for Values > 25%
    * `[▂░░░]` for Values > 0%
    * `[░░░░]` for Status Empty/Standby
* **Battery Module:** Implement a dedicated hardware node tracking element utilizing block headers containing structural charging state metrics (`⚡` / `▰`).
* **Header Framing Structural Style Reference:**
    `Text { text: "┌── [ LAYER_AUDIO // CORE_STATE ]──────────┐"; font.family: "Departure Mono Nerd Font Mono"; font.pixelSize: 10; color: Theme.accentBlue }`

## 4. COMPONENT REGISTRY & INTERACTIVE MATRIX
The bar and desktop overlay ecosystem must handle the following components flawlessly:
* **StatusBar (28px Top Panel):** * `[NAVI_OS]` Branding Identifier.
    * **Currently Focused Window Name:** Live display of active application title tracking.
    * **Task Bar Pinned/Active Items:** Light layout tracking workspace index/tasks.
    * **Keyboard Layout Indicator:** Show active layout (e.g., `US`, `JA`).
    * **System Telemetry Panel Triggers:** Clickable triggers for network, audio, and hardware levels.
* **System Control Dropdown Matrix:**
    * **Volume & Backlight Controls:** Precise range sliders utilizing the block status meters.
    * **Network & Wireless Scan Widget:** SSID list parsing using the block-strength format.
    * **Logout Matrix Controller:** Secure power actions overlay (Halt, Reboot, Sleep, Logout).
* **Application Launcher:** Full keyboard-navigable matrix layout with dynamic fuzzy-search capability.

## 5. HOTKEY ROUTING MATRIX (VIM-STYLE PARADIGM)
Global keys use standard Meta modifiers, while internal navigation overlays strictly enforce Vim movement keys (`H`, `J`, `K`, `L` / Enter / Escape):
* `Meta + Space`: Toggle Application Launcher Menu.
* `Meta + S`: Toggle System Control Center Overlay.
* `Escape`: Instantly collapse/close any active popup window layer.
* **Menu-Internal Keybinds:** Focus maps to `J` (Move Down), `K` (Move Up), `H`/`L` (Page Context Adjustments), and `Enter` (Execute/Select).

## 6. EXTENSIVE SPECIFICATION REFERENCES
* **Quickshell Architecture:** Use the compiled framework references found in `quickshell_compiled_docs.md`.
* **Layout Designs:** Reference `~/Desktop/projects/Persona-Quickshell` and `~/Desktop/projects/DankMaterialShell` to extract layout concepts, structural code organization strategies, fluid layout animations, and telemetry modules. (Note: Avoid using `noctalia` due to heavy C++ dependencies).

## 7. DEVELOPMENT RULES
* **Code Quality:** Keep components completely modular, functional, and performant. Avoid duplicate processes and memory leak property bindings.
* **Documentation:** Add short, actionable terminal comments only where layout logic or GLSL matrices are highly complex.
