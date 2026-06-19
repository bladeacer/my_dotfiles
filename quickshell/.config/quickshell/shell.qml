import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "components" as Components
import "services" as Services
import "theme"

ShellRoot {
    id: root

    property string currentTimestamp: "0000-00-00 // 00:00:00"
    property string mediaMetadata: "TRACK // IDLE"
    property string mediaStatus: "stopped"
    property string mediaArtUrl: ""
    property int batteryCapacity: 0
    property string batteryStatus: "BAT // --%"
    property string btStatus: "BT // DOWN"
    property string activeWifiSSID: "DISCONNECTED"
    property int wifiSignalStrength: 0
    property int mediaPosition: 0
    property int mediaLength: 1
    property real currentVolume: 0.0
    property real currentBrightness: 0.0
    property string keyboardLayout: "US"

    function closeAllPopups() {
        sysLoader.active = false
        launcherLoader.active = false
        mediaHUDLoader.active = false
    }

    // IPC FIFO listener
    Process {
        id: ipcReader
        command: ["bash", "-c", "mkdir -p /tmp/quickshell && [ ! -p /tmp/quickshell/ipc ] && mkfifo /tmp/quickshell/ipc; exec tail -f /tmp/quickshell/ipc"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var action = line.trim().toLowerCase()
                if (action === "toggle-launcher") launcherLoader.active = !launcherLoader.active
                else if (action === "toggle-syscontrol") sysLoader.active = !sysLoader.active
            }
        }
    }

    // Hotkey Matrix
    Shortcut { sequence: "Meta+Space"; onActivated: launcherLoader.active = !launcherLoader.active }
    Shortcut { sequence: "Meta+S"; onActivated: sysLoader.active = !sysLoader.active }
    Shortcut { sequence: "Escape"; onActivated: closeAllPopups() }

    // Timer
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            var pad = function(n) { return n.toString().padStart(2, '0') }
            currentTimestamp = d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate()) + " // " + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds())
        }
    }

    // Battery
    Process {
        id: batPipe
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var c = parseInt(line.trim())
                if (!isNaN(c)) batteryCapacity = c
                batteryStatus = line.trim() !== "" ? "BAT // " + line.trim() + "%" : "BAT // --%"
            }
        }
    }

    // Bluetooth
    Process {
        id: btPipe
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'UP' || echo 'DOWN'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => { btStatus = "BT // " + line.trim().toUpperCase() }
        }
    }

    // Network
    Process {
        id: wifiPipe
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'NO:DISCONNECTED:0'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var seg = line.trim().split(":")
                if (seg.length >= 3 && seg[0] === "yes") {
                    activeWifiSSID = seg[1].toUpperCase()
                    wifiSignalStrength = parseInt(seg[2])
                } else {
                    activeWifiSSID = "DISCONNECTED"
                    wifiSignalStrength = 0
                }
            }
        }
    }

    // Media metadata
    Process {
        id: mediaPipe
        command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var seg = line.trim().split("|")
                if (seg.length >= 3 && seg[0] !== "") {
                    mediaMetadata = seg[0].toUpperCase()
                    mediaStatus = seg[1].toLowerCase()
                    mediaArtUrl = seg[2] ? seg[2].replace("file://", "") : ""
                    if (seg.length >= 4 && seg[3]) {
                        var raw = parseInt(seg[3])
                        mediaLength = (!isNaN(raw) && raw > 0) ? Math.round(raw / 1000000) : 1
                    } else {
                        mediaLength = 1
                    }
                } else {
                    mediaMetadata = "TRACK // IDLE"
                    mediaStatus = "stopped"
                    mediaArtUrl = ""
                    mediaLength = 1
                }
            }
        }
    }

    // Media position
    Process {
        id: mediaPosPipe
        command: ["playerctl", "position"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var p = parseFloat(line.trim())
                if (!isNaN(p)) mediaPosition = Math.round(p)
            }
        }
    }

    // Volume
    Process {
        id: volPipe
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var v = parseFloat(line.trim())
                if (!isNaN(v)) currentVolume = Math.min(v, 1.0)
            }
        }
    }

    // Brightness
    Process {
        id: brightPipe
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var p = parseInt(line.trim())
                if (!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0)
            }
        }
    }

    // Keyboard layout
    Process {
        id: kbPipe
        command: ["bash", "-c", "setxkbmap -query 2>/dev/null | grep layout | awk '{print $2}' || echo 'US'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "") keyboardLayout = line.trim().toUpperCase()
            }
        }
    }

    // Polling timer
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            batPipe.running = false; batPipe.running = true
            btPipe.running = false; btPipe.running = true
            wifiPipe.running = false; wifiPipe.running = true
            mediaPipe.running = false; mediaPipe.running = true
            volPipe.running = false; volPipe.running = true
            brightPipe.running = false; brightPipe.running = true
            kbPipe.running = false; kbPipe.running = true
        }
    }

    // ── MAIN STATUSBAR ──
    PanelWindow {
        id: bar
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.focusable: WlrKeyboardFocus.None
        anchors { top: true; left: true; right: true }
        implicitHeight: Theme.barHeight
        color: Theme.widgetBg

        Components.StatusBar { anchors.fill: parent }
    }

    // ── OVERLAYS ──
    Loader { id: launcherLoader; active: false; sourceComponent: launchComp }
    Component {
        id: launchComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            anchors.top: true
            margins.top: 32
            implicitWidth: 580
            implicitHeight: 420
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.widgetBg
                border.color: Theme.accentBlue
                border.width: 1

                Components.AppLauncher {
                    anchors.fill: parent
                    onCloseRequested: launcherLoader.active = false
                }
            }
        }
    }

    Loader { id: sysLoader; active: false; sourceComponent: sysComp }
    Component {
        id: sysComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            anchors.top: true
            margins.top: 32
            implicitWidth: 880
            implicitHeight: 640
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.widgetBg
                border.color: Theme.accentBlue
                border.width: 1

                Components.SystemControlCenter {
                    anchors.fill: parent
                }
            }
        }
    }

    Loader { id: mediaHUDLoader; active: false; sourceComponent: mediaHUDComp }
    Component {
        id: mediaHUDComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "media_hud"
            anchors { top: true; left: true; right: true }
            margins.top: 28
            implicitHeight: 135
            color: "transparent"

            Components.MediaHUD { anchors.fill: parent }
        }
    }
}
