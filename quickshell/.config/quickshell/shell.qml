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
        launcherLoader.active = false
        sysLoader.active = false
        mediaHUDLoader.active = false
        wifiLoader.active = false
        btLoader.active = false
    }

    function togglePopup(loader) {
        if (loader.active) { loader.active = false; return }
        closeAllPopups()
        loader.active = true
    }

    Process {
        id: ipcReader
        command: ["bash", "-c", "mkdir -p /tmp/quickshell && [ ! -p /tmp/quickshell/ipc ] && mkfifo /tmp/quickshell/ipc; exec tail -f /tmp/quickshell/ipc"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var action = line.trim().toLowerCase()
                if (action === "toggle-launcher") togglePopup(launcherLoader)
                else if (action === "toggle-syscontrol") togglePopup(sysLoader)
            }
        }
    }

    Shortcut { sequence: "Meta+Space"; onActivated: togglePopup(launcherLoader) }
    Shortcut { sequence: "Meta+S"; onActivated: togglePopup(sysLoader) }
    Shortcut { sequence: "Escape"; onActivated: closeAllPopups() }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            var pad = function(n) { return n.toString().padStart(2, '0') }
            currentTimestamp = d.getFullYear() + "-" + pad(d.getMonth()+1) + "-" + pad(d.getDate()) + " // " + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds())
        }
    }

    Process {
        id: batPipe; command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser { onRead: (line) => { var c = parseInt(line.trim()); if (!isNaN(c)) batteryCapacity = c; batteryStatus = line.trim() !== "" ? "BAT // " + line.trim() + "%" : "BAT // --%" } }
    }

    Process {
        id: btPipe; command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'UP' || echo 'DOWN'"]
        running: true
        stdout: SplitParser { onRead: (line) => { btStatus = "BT // " + line.trim().toUpperCase() } }
    }

    Process {
        id: wifiPipe; command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'NO:DISCONNECTED:0'"]
        running: true
        stdout: SplitParser { onRead: (line) => { var seg = line.trim().split(":"); if (seg.length >= 3 && seg[0] === "yes") { activeWifiSSID = seg[1].toUpperCase(); wifiSignalStrength = parseInt(seg[2]) } else { activeWifiSSID = "DISCONNECTED"; wifiSignalStrength = 0 } } }
    }

    Process {
        id: mediaPipe; command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}"]
        running: true
        stdout: SplitParser { onRead: (line) => { var seg = line.trim().split("|"); if (seg.length >= 3 && seg[0] !== "") { mediaMetadata = seg[0].toUpperCase(); mediaStatus = seg[1].toLowerCase(); mediaArtUrl = seg[2] ? seg[2].replace("file://", "") : ""; if (seg.length >= 4 && seg[3]) { var raw = parseInt(seg[3]); mediaLength = (!isNaN(raw) && raw > 0) ? Math.round(raw / 1000000) : 1 } else { mediaLength = 1 } } else { mediaMetadata = "TRACK // IDLE"; mediaStatus = "stopped"; mediaArtUrl = ""; mediaLength = 1 } } }
    }

    Process {
        id: mediaPosPipe; command: ["playerctl", "position"]
        running: true
        stdout: SplitParser { onRead: (line) => { var p = parseFloat(line.trim()); if (!isNaN(p)) mediaPosition = Math.round(p) } }
    }

    Process {
        id: volPipe; command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        running: true
        stdout: SplitParser { onRead: (line) => { var v = parseFloat(line.trim()); if (!isNaN(v)) currentVolume = Math.min(v, 1.0) } }
    }

    Process {
        id: brightPipe; command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: SplitParser { onRead: (line) => { var p = parseInt(line.trim()); if (!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0) } }
    }

    Process {
        id: kbPipe; command: ["bash", "-c", "fcitx5-remote -n 2>/dev/null | sed 's/.*-//' | head -1 || setxkbmap -query 2>/dev/null | grep layout | awk '{print toupper($2)}' || echo 'US'"]
        running: true
        stdout: SplitParser { onRead: (line) => { if (line.trim() !== "") keyboardLayout = line.trim().toUpperCase() } }
    }

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

    PanelWindow {
        id: bar
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.focusable: WlrKeyboardFocus.None
        anchors { top: true; left: true; right: true }
        implicitHeight: 28
        color: Theme.widgetBg

        Components.StatusBar {
            anchors.fill: parent
            onBtClicked: togglePopup(btLoader)
            onWifiClicked: togglePopup(wifiLoader)
            onSysClicked: togglePopup(sysLoader)
        }
    }

    Loader { id: launcherLoader; active: false; sourceComponent: launchComp }
    Component {
        id: launchComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 580; implicitHeight: 420
            color: Theme.widgetBg
            Rectangle {
                anchors.fill: parent; color: "transparent"
                border.color: Theme.accentBlue; border.width: 1
                Components.AppLauncher { anchors.fill: parent; onCloseRequested: launcherLoader.active = false }
            }
        }
    }

    Loader { id: sysLoader; active: false; sourceComponent: sysComp }
    Component {
        id: sysComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 880; implicitHeight: 640
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                ShaderEffect {
                    anchors.fill: parent
                    property real time: 0
                    fragmentShader: Qt.resolvedUrl("shaders/tidal.frag.qsb")
                    NumberAnimation on time { from: 0; to: 6.28; duration: 4000; loops: Animation.Infinite }
                }
                Components.SystemControlCenter { anchors.fill: parent; onCloseRequested: sysLoader.active = false; onOpenWifiRequested: togglePopup(wifiLoader) }
            }
        }
    }

    Loader { id: mediaHUDLoader; active: false; sourceComponent: mediaHUDComp }
    Component {
        id: mediaHUDComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.None
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 450; implicitHeight: 98
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                Components.MediaHUD { anchors.fill: parent }
            }
        }
    }

    Loader { id: wifiLoader; active: false; sourceComponent: wifiComp }
    Component {
        id: wifiComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            anchors.right: true
            margins.top: 28; margins.right: 10
            implicitWidth: 380; implicitHeight: wifiWidget.implicitHeight
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                Components.WifiWidget { id: wifiWidget; anchors.fill: parent }
            }
        }
    }

    Loader { id: btLoader; active: false; sourceComponent: btComp }
    Component {
        id: btComp
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            anchors.right: true
            margins.top: 28; margins.right: 120
            implicitWidth: 300; implicitHeight: 350
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                Components.BluetoothControlCenter { anchors.fill: parent }
            }
        }
    }
}
