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
            "if [ -n \"$APP\" ] && ! echo \"$APP\" | grep -qi 'plasmashell'; then " +
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
                    if (seg.length >= 3 && seg[0] === "yes") { activeWifiSSID = seg[1].toUpperCase(); wifiSignalStrength = parseInt(seg[2]) || 0; Services.WifiService.connected = true; Services.WifiService.activeSSID = seg[1].toUpperCase(); Services.WifiService.activeStrength = parseInt(seg[2]) || 0 }
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
                    var app = t.substring(10)
                    if (app.toLowerCase().indexOf("plasmashell") === -1) {
                        focusedAppId = app
                        Services.FocusedWindow._kdeAppId = app
                    } else {
                        focusedAppId = ""
                        focusedTitle = ""
                        Services.FocusedWindow._kdeAppId = ""
                        Services.FocusedWindow._kdeTitle = ""
                    }
                } else if (t.startsWith("KB:")) {
                    var k = t.substring(3).trim()
                    if (k !== "") keyboardLayout = k.toUpperCase()
                }
            }
        }
    }


    function openWifiFromSys() {
        if (sysLoader.item)
            sysLoader.item.startCloseTransition(function() { closeAllPopups(); wifiLoader.active = true })
        else
            togglePopup(wifiLoader)
    }
    function openBtFromSys() {
        if (sysLoader.item)
            sysLoader.item.startCloseTransition(function() { closeAllPopups(); btLoader.active = true })
        else
            togglePopup(btLoader)
    }

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
            id: launchWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 580; implicitHeight: 420
            color: "transparent"

            function startCloseTransition(callback) {
                launchContainer.startClose(callback)
            }

            Rectangle {
                id: launchContainer
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { launchContainer.startClose(function() { launcherLoader.active = false }); event.accepted = true } }
                Components.AppLauncher { anchors.fill: parent; onCloseRequested: launchContainer.startClose(function() { launcherLoader.active = false }) }

                ShaderEffect {
                    visible: launchContainer.playingTransition
                    anchors.fill: parent
                    property real progress: launchContainer.transitionProgress
                    property color transBgColor: Theme.widgetBg
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/transition_dissolve.frag.qsb"
                }

                property real transitionProgress: 1
                property bool playingTransition: false
                property var closeCallback: null
                property var startClose: function(callback) {
                    if (launchOpenAnim.running) launchOpenAnim.stop()
                    closeCallback = callback
                    playingTransition = true
                    transitionProgress = 1
                    launchCloseAnim.start()
                }

                NumberAnimation on transitionProgress {
                    id: launchOpenAnim
                    from: 0; to: 1; duration: 400
                    easing.type: Easing.OutCubic
                    onFinished: {
                        launchContainer.playingTransition = false
                        launchContainer.transitionProgress = 1
                    }
                }
                NumberAnimation on transitionProgress {
                    id: launchCloseAnim
                    from: 1; to: 0; duration: 300
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (launchContainer.closeCallback) {
                            var cb = launchContainer.closeCallback
                            launchContainer.closeCallback = null
                            cb()
                        }
                    }
                }

                Component.onCompleted: {
                    launchContainer.playingTransition = true
                    launchContainer.transitionProgress = 0
                    launchOpenAnim.start()
                }
            }
        }
    }

    Loader { id: sysLoader; active: false; sourceComponent: sysComp }
    Component {
        id: sysComp
        PanelWindow {
            id: sysWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 880; implicitHeight: 640
            color: "transparent"

            function startCloseTransition(callback) {
                sysContainer.startClose(callback)
            }

            Rectangle {
                id: sysContainer
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { sysContainer.startClose(function() { sysLoader.active = false }); event.accepted = true } }

                Components.SystemControlCenter { id: sysControl; anchors.fill: parent; onCloseRequested: sysContainer.startClose(function() { sysLoader.active = false }); onOpenWifiRequested: openWifiFromSys(); onOpenBtRequested: openBtFromSys() }

                ShaderEffect {
                    anchors.fill: parent
                    opacity: 1.0
                    property real time: 0
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/cyber_classic.frag.qsb"
                }

                ShaderEffect {
                    visible: sysContainer.playingTransition
                    anchors.fill: parent
                    property real progress: sysContainer.transitionProgress
                    property color transBgColor: Theme.widgetBg
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/transition_crtwipe.frag.qsb"
                }

                property real transitionProgress: 1
                property bool playingTransition: false
                property var closeCallback: null
                property var startClose: function(callback) {
                    if (sysOpenAnim.running) sysOpenAnim.stop()
                    closeCallback = callback
                    playingTransition = true
                    transitionProgress = 1
                    sysCloseAnim.start()
                }

                NumberAnimation on transitionProgress {
                    id: sysOpenAnim
                    from: 0; to: 1; duration: 350
                    easing.type: Easing.OutCubic
                    onFinished: {
                        sysContainer.playingTransition = false
                        sysContainer.transitionProgress = 1
                    }
                }
                NumberAnimation on transitionProgress {
                    id: sysCloseAnim
                    from: 1; to: 0; duration: 250
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (sysContainer.closeCallback) {
                            var cb = sysContainer.closeCallback
                            sysContainer.closeCallback = null
                            cb()
                        }
                    }
                }

                Component.onCompleted: {
                    sysContainer.playingTransition = true
                    sysContainer.transitionProgress = 0
                    sysOpenAnim.start()
                }
            }
        }
    }

    Loader { id: mediaHUDLoader; active: false; sourceComponent: mediaHUDComp }
    Component {
        id: mediaHUDComp
        PanelWindow {
            id: mediaHUDWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.None
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            margins.top: 28
            implicitWidth: 450; implicitHeight: 130
            color: "transparent"

            function startCloseTransition(callback) {
                mediaHUDContainer.startClose(callback)
            }

            Rectangle {
                id: mediaHUDContainer
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { mediaHUDContainer.startClose(function() { mediaHUDLoader.active = false }); event.accepted = true } }
                Components.MediaHUD { anchors.fill: parent; onCloseRequested: mediaHUDContainer.startClose(function() { mediaHUDLoader.active = false }) }

                ShaderEffect {
                    anchors.fill: parent
                    opacity: 1.0
                    property real time: 0
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/fluid_dream.frag.qsb"
                    NumberAnimation on time {
                        from: 0; to: 10000; duration: 10000000
                        running: true; loops: Animation.Infinite
                    }
                }

                ShaderEffect {
                    visible: mediaHUDContainer.playingTransition
                    anchors.fill: parent
                    property real progress: mediaHUDContainer.transitionProgress
                    property color transBgColor: Theme.widgetBg
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/transition_fade.frag.qsb"
                }

                property real transitionProgress: 1
                property bool playingTransition: false
                property var closeCallback: null
                property var startClose: function(callback) {
                    if (mediaOpenAnim.running) mediaOpenAnim.stop()
                    closeCallback = callback
                    playingTransition = true
                    transitionProgress = 1
                    mediaCloseAnim.start()
                }

                NumberAnimation on transitionProgress {
                    id: mediaOpenAnim
                    from: 0; to: 1; duration: 500
                    easing.type: Easing.OutCubic
                    onFinished: {
                        mediaHUDContainer.playingTransition = false
                        mediaHUDContainer.transitionProgress = 1
                    }
                }
                NumberAnimation on transitionProgress {
                    id: mediaCloseAnim
                    from: 1; to: 0; duration: 350
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (mediaHUDContainer.closeCallback) {
                            var cb = mediaHUDContainer.closeCallback
                            mediaHUDContainer.closeCallback = null
                            cb()
                        }
                    }
                }

                Component.onCompleted: {
                    mediaHUDContainer.playingTransition = true
                    mediaHUDContainer.transitionProgress = 0
                    mediaOpenAnim.start()
                }
            }
        }
    }

    Loader { id: wifiLoader; active: false; sourceComponent: wifiComp }
    Component {
        id: wifiComp
        PanelWindow {
            id: wifiWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            anchors.right: true
            margins.top: 28; margins.right: 10
            implicitWidth: 380; implicitHeight: wifiWidget.implicitHeight
            Behavior on implicitHeight { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }
            color: "transparent"

            function startCloseTransition(callback) {
                wifiContainer.startClose(callback)
            }

            Rectangle {
                id: wifiContainer
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { wifiContainer.startClose(function() { wifiLoader.active = false }); event.accepted = true } }
                Components.WifiWidget { id: wifiWidget; anchors.fill: parent; onCloseRequested: wifiContainer.startClose(function() { wifiLoader.active = false }) }

                ShaderEffect {
                    anchors.fill: parent
                    opacity: 1.0
                    property real time: 0
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/digital_rose.frag.qsb"
                    NumberAnimation on time {
                        from: 0; to: 10000; duration: 10000000
                        running: true; loops: Animation.Infinite
                    }
                }

                ShaderEffect {
                    visible: wifiContainer.playingTransition
                    anchors.fill: parent
                    property real direction: wifiContainer.transitionDirection
                    property real progress: wifiContainer.transitionProgress
                    property color transBgColor: Theme.widgetBg
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/transition_rosebloom.frag.qsb"
                }

                property real transitionProgress: 1
                property real transitionDirection: 1.0
                property bool playingTransition: false
                property var closeCallback: null
                property var startClose: function(callback) {
                    if (wifiOpenAnim.running) wifiOpenAnim.stop()
                    transitionDirection = 0.0
                    closeCallback = callback
                    playingTransition = true
                    transitionProgress = 1
                    wifiCloseAnim.start()
                }

                NumberAnimation on transitionProgress {
                    id: wifiOpenAnim
                    from: 0; to: 1; duration: 350
                    easing.type: Easing.OutCubic
                    onFinished: {
                        wifiContainer.playingTransition = false
                        wifiContainer.transitionProgress = 1
                    }
                }
                NumberAnimation on transitionProgress {
                    id: wifiCloseAnim
                    from: 1; to: 0; duration: 250
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (wifiContainer.closeCallback) {
                            var cb = wifiContainer.closeCallback
                            wifiContainer.closeCallback = null
                            cb()
                        }
                    }
                }

                Component.onCompleted: {
                    wifiContainer.playingTransition = true
                    wifiContainer.transitionDirection = 1.0
                    wifiContainer.transitionProgress = 0
                    wifiOpenAnim.start()
                }
            }
        }
    }

    Loader { id: btLoader; active: false; sourceComponent: btComp }
    Component {
        id: btComp
        PanelWindow {
            id: btWindow
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.focusable: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusiveZone: -1
            anchors.top: true
            anchors.right: true
            margins.top: 28; margins.right: 120
            implicitWidth: 300; implicitHeight: 350
            color: "transparent"

            function startCloseTransition(callback) {
                btContainer.startClose(callback)
            }

            Rectangle {
                id: btContainer
                anchors.fill: parent; color: Theme.widgetBg
                border.color: Theme.accentBlue; border.width: 1
                focus: true
                Keys.onPressed: function(event) { if (event.key === Qt.Key_Escape) { btContainer.startClose(function() { btLoader.active = false }); event.accepted = true } }
                Components.BluetoothControlCenter { anchors.fill: parent; onCloseRequested: btContainer.startClose(function() { btLoader.active = false }) }

                ShaderEffect {
                    anchors.fill: parent
                    opacity: 1.0
                    property real time: 0
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/iceberg_chill.frag.qsb"
                }

                ShaderEffect {
                    visible: btContainer.playingTransition
                    anchors.fill: parent
                    property real progress: btContainer.transitionProgress
                    property color transBgColor: Theme.widgetBg
                    fragmentShader: "file:///home/data/my_dotfiles/quickshell/.config/quickshell/shaders/transition_crtwipe.frag.qsb"
                }

                property real transitionProgress: 1
                property bool playingTransition: false
                property var closeCallback: null
                property var startClose: function(callback) {
                    if (btOpenAnim.running) btOpenAnim.stop()
                    closeCallback = callback
                    playingTransition = true
                    transitionProgress = 1
                    btCloseAnim.start()
                }

                NumberAnimation on transitionProgress {
                    id: btOpenAnim
                    from: 0; to: 1; duration: 400
                    easing.type: Easing.OutCubic
                    onFinished: {
                        btContainer.playingTransition = false
                        btContainer.transitionProgress = 1
                    }
                }
                NumberAnimation on transitionProgress {
                    id: btCloseAnim
                    from: 1; to: 0; duration: 300
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (btContainer.closeCallback) {
                            var cb = btContainer.closeCallback
                            btContainer.closeCallback = null
                            cb()
                        }
                    }
                }

                Component.onCompleted: {
                    btContainer.playingTransition = true
                    btContainer.transitionProgress = 0
                    btOpenAnim.start()
                }
            }
        }
    }
}
