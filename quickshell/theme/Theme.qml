pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string fontMono: "Departure Mono Nerd Font Mono" // Or "Hack", "Fira Code", "JetBrains Mono"
    readonly property color terminalGreen: Qt.rgba(180/255, 190/255, 130/255, 0.4) // Positive alpha accent
    readonly property int borderThin: 1

    // --- 1. SET THE PATH TO YOUR THEME FILE ---
    // You can point this directly to your stowed config or ~/.config/kdeglobals
    readonly property string colorSchemePath: "../../colors_kde/IcebergDark.colors"

    // --- 2. THE PARSING ENGINE ---
    // Internal helper to read the file and extract values
    function getIniColor(section, key, fallback) {
        // Simple regex or string parsing to find "[Section]" then "key=r,g,b"
        // For absolute robustness, you can read via Quickshell's FileReader
        return fallback; 
    }

    // --- 3. EXPOSED COLORS MAPPED FROM YOUR INI ---
    // We convert the INI's "22,24,33" string format into usable Qt colors
    readonly property color bgNormal:    Qt.rgba(22/255, 24/255, 33/255, 1.0)      // [Background:Normal]
    readonly property color bgHeader:    Qt.rgba(30/255, 33/255, 50/255, 1.0)      // [Background:Header]
    readonly property color fgNormal:    Qt.rgba(198/255, 200/255, 209/255, 1.0)  // [Foreground:Normal]
    readonly property color fgMuted:     Qt.rgba(107/255, 112/255, 137/255, 1.0)  // [Foreground:Inactive]
    readonly property color accentBlue:  Qt.rgba(132/255, 160/255, 198/255, 1.0)  // [Foreground:Link]
    readonly property color accentGreen: Qt.rgba(180/255, 190/255, 130/255, 1.0)  // [Foreground:Positive]

    // --- 4. YOUR STYLISTIC CONTROL OVERRIDES ---
    // This is where you manipulate the scheme to give you full aesthetic control
    readonly property int radiusCompact: 6
    readonly property int radiusLarge: 12
    readonly property int padding: 10
    
    // Custom modifications of the system scheme
    readonly property color widgetBg: Qt.alpha(bgHeader, 0.85) // Transparent card accent
    readonly property color borderMain: Qt.rgba(accentBlue.r, accentBlue.g, accentBlue.b, 0.2) // Subtle accent borders
}
