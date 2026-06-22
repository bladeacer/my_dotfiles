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
    property string mediaAlbum: ""
    property string mediaComposer: ""
    property string mediaStatus: "stopped"
    property string mediaArtUrl: ""
    property int batteryCapacity: 0
    property bool batteryCharging: false
    property string batteryStatus: "BAT // --%"
    property string btStatus: "BT // DOWN"
    property string activeWifiSSID: "DISCONNECTED"
    property int wifiSignalStrength: 0
    property string focusedTitle: ""
    property string focusedAppId: ""
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
        id: telemetryPipe
        command: ["bash", "-c",
            "while true; do " +
            "echo \"BAT:$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo --)\"; " +
            "echo \"PWR:$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown)\"; " +
            "echo \"POS:$(playerctl position 2>/dev/null || echo 0)\"; " +
            "echo \"BT:$([ $(bluetoothctl devices Connected 2>/dev/null | wc -l) -gt 0 ] && echo UP || echo DOWN)\"; " +
            "echo \"WIFI:$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'NO:DISCONNECTED:0')\"; " +
            "echo \"MEDIA:$(playerctl metadata --format '{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}|{{ xesam:album }}|{{ xesam:composer }}' 2>/dev/null)\"; " +
            "echo \"VOL:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}' || echo 0)\"; " +
            "echo \"BRIGHT:$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo 0)\"; " +
            "echo \"KB:$(fcitx5-remote -n 2>/dev/null | sed 's/.*-//' | head -1 || setxkbmap -query 2>/dev/null | grep layout | awk '{print toupper($2)}' || echo 'US')\"; " +
            "WIN=$(kdotool getactivewindow 2>/dev/null); " +
            "if [ -n \"$WIN\" ]; then " +
            "INFO=$(qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo \"$WIN\" 2>&1); " +
            "TITLE=$(echo \"$INFO\" | grep '^caption:' | sed 's/^caption: //'); " +
            "APP=$(echo \"$INFO\" | grep '^desktopFile:' | sed 's/^desktopFile: //'); " +
            "if [ -n \"$APP\" ] && [ \"$APP\" != \"plasmashell\" ]; then " +
            "echo \"FOCUS_TITLE:$TITLE\"; " +
            "echo \"FOCUS_APP:$APP\"; " +
            "fi; " +
            "fi; " +
            "sleep 0.5; " +
            "done"
        ]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                    var t = line.trim()
                    if (t.startsWith("BAT:")) {
                        var v = t.substring(4).trim()
                        var c = parseInt(v)
                        if (!isNaN(c)) batteryCapacity = c
                        var pct = v !== "" && v !== "--" ? v + "%" : "--%"
                        batteryStatus = (batteryCharging ? "[+]" : (batteryCapacity <= 15 ? "[!]" : "[-]")) + " BAT " + pct
                    } else if (t.startsWith("PWR:")) {
                        batteryCharging = t.substring(4).trim().toLowerCase() === "charging"
                        var pct = batteryCapacity >= 0 ? batteryCapacity + "%" : "--%"
                        batteryStatus = (batteryCharging ? "[+]" : (batteryCapacity <= 15 ? "[!]" : "[-]")) + " BAT " + pct
                    } else if (t.startsWith("POS:")) {
                        var pos = parseFloat(t.substring(4))
                        if (!isNaN(pos)) mediaPosition = Math.round(pos)
                    } else if (t.startsWith("BT:")) {
                        btStatus = "BT // " + t.substring(3).trim().toUpperCase()
                    } else if (t.startsWith("WIFI:")) {
                    var seg = t.substring(5).split(":")
                    if (seg.length >= 3 && seg[0] === "yes") { activeWifiSSID = seg[1].toUpperCase(); wifiSignalStrength = parseInt(seg[2]); Services.WifiService.connected = true; Services.WifiService.activeSSID = seg[1].toUpperCase(); Services.WifiService.activeStrength = parseInt(seg[2]) }
                    else { activeWifiSSID = "DISCONNECTED"; wifiSignalStrength = 0; Services.WifiService.connected = false; Services.WifiService.activeSSID = "DISCONNECTED"; Services.WifiService.activeStrength = 0 }
                } else if (t.startsWith("MEDIA:")) {
                    var seg = t.substring(6).split("|")
                    if (seg.length >= 3 && seg[0] !== "") {
                        mediaMetadata = seg[0].toUpperCase(); mediaStatus = seg[1].toLowerCase()
                        mediaArtUrl = seg[2] ? seg[2].replace("file://", "") : ""
                        if (seg.length >= 4 && seg[3]) { var raw = parseInt(seg[3]); mediaLength = (!isNaN(raw) && raw > 0) ? Math.round(raw / 1000000) : 1 }
                        else { mediaLength = 1 }
                        mediaAlbum = seg.length >= 5 && seg[4] ? seg[4].toUpperCase() : ""
                        mediaComposer = seg.length >= 6 && seg[5] ? seg[5].toUpperCase() : ""
                    } else { mediaMetadata = "TRACK // IDLE"; mediaStatus = "stopped"; mediaArtUrl = ""; mediaLength = 1; mediaAlbum = ""; mediaComposer = "" }
                } else if (t.startsWith("VOL:")) {
                    var v = parseFloat(t.substring(4))
                    if (!isNaN(v)) currentVolume = Math.min(v, 1.0)
                } else if (t.startsWith("BRIGHT:")) {
                    var p = parseInt(t.substring(7))
                    if (!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0)
                } else if (t.startsWith("FOCUS_TITLE:")) {
                    focusedTitle = t.substring(12)
                    Services.FocusedWindow._kdeTitle = focusedTitle
                } else if (t.startsWith("FOCUS_APP:")) {
                    focusedAppId = t.substring(10)
                    Services.FocusedWindow._kdeAppId = focusedAppId
                } else if (t.startsWith("KB:")) {
                    var k = t.substring(3).trim()
                    if (k !== "") keyboardLayout = k.toUpperCase()
                }
            }
        }
    }


    function openWifiFromSys() { sysLoader.active = false; togglePopup(wifiLoader) }
    function openBtFromSys() { sysLoader.active = false; togglePopup(btLoader) }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.focusable: WlrKeyboardFocus.None
            anchors { top: true; left: true; right: true; bottom: true }
            color: "transparent"

            Components.SpectrumVisualizer { anchors.fill: parent; opacity: 0.8; screenName: modelData.name }
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
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { launcherLoader.active = false; event.accepted = true } }
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
                layer.enabled: true; layer.samples: 4

                Components.SystemControlCenter { id: sysControl; anchors.fill: parent; onCloseRequested: sysLoader.active = false; onOpenWifiRequested: openWifiFromSys; onOpenBtRequested: openBtFromSys }

                ShaderEffect {
                    id: waveShader
                    anchors.fill: parent; opacity: 0; visible: false
                    property real sweep: -0.3
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/tidal.frag.qsb"
                    layer.enabled: true; layer.samples: 4

                    Component.onCompleted: Qt.callLater(waveAnim.restart)

                    SequentialAnimation {
                        id: waveAnim
                        onStarted: { waveShader.visible = true; waveShader.opacity = 0 }
                        ParallelAnimation {
                            NumberAnimation { target: waveShader; property: "sweep"; from: -0.3; to: 1.3; duration: 1800; easing.type: Easing.InOutSine }
                            SequentialAnimation {
                                NumberAnimation { target: waveShader; property: "opacity"; from: 0; to: 0.8; duration: 300 }
                                PauseAnimation { duration: 1000 }
                                NumberAnimation { target: waveShader; property: "opacity"; from: 0.8; to: 0; duration: 500 }
                            }
                        }
                        onFinished: { waveShader.visible = false }
                    }
                }
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
            implicitWidth: 450; implicitHeight: 130
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { mediaHUDLoader.active = false; event.accepted = true } }
                Components.MediaHUD { anchors.fill: parent; onCloseRequested: mediaHUDLoader.active = false }
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
            Behavior on implicitHeight { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }
            color: "transparent"
            Rectangle {
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { wifiLoader.active = false; event.accepted = true } }
                Components.WifiWidget { id: wifiWidget; anchors.fill: parent; onCloseRequested: wifiLoader.active = false }
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
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { btLoader.active = false; event.accepted = true } }
                Components.BluetoothControlCenter { anchors.fill: parent; onCloseRequested: btLoader.active = false }
            }
        }
    }
}
