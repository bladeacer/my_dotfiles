import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: sysCard
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    property string blueRoseText: ""
    property string confirmAction: ""
    property int selectedTab: 0

    Process {
        id: roseReader
        command: ["bash", "-c", "cat \"$HOME/my_dotfiles/logo/blue_rose\" 2>/dev/null || true"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim() !== "") blueRoseText = ansiToHtml(text)
            }
        }
    }

    Process { id: volSet }
    Process { id: brightSet }
    Process { id: cmdLogout; command: ["qdbus", "org.kde.Shutdown", "/Shutdown", "logout"] }
    Process { id: cmdReboot; command: ["systemctl", "reboot"] }
    Process { id: cmdPoweroff; command: ["systemctl", "poweroff"] }
    Process { id: cmdSleep; command: ["systemctl", "suspend"] }
    Process { id: cmdBluetooth }

    Component.onCompleted: roseReader.running = true

    function ansiToHtml(input) {
        if (!input) return ""
        var lines = input.split("\n")
        var out = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (line.trim() === "") { out.push(""); continue }

            var safe = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
            var fg = null, bg = null, rev = false
            var html = ""
            var pos = 0

            while (pos < safe.length) {
                var escIdx = safe.indexOf("\x1b", pos)
                if (escIdx < 0) {
                    html += ansiSpan(safe.substring(pos), fg, bg, rev)
                    break
                }

                if (escIdx > pos) {
                    html += ansiSpan(safe.substring(pos, escIdx), fg, bg, rev)
                }

                var seqEnd = findAnsiEnd(safe, escIdx + 1)
                if (seqEnd < 0) { html += safe.substring(escIdx); break }

                var seq = safe.substring(escIdx, seqEnd + 1)
                pos = seqEnd + 1

                if (seq === "\x1b[0m" || seq === "\x1b[m") {
                    if (html.length > 0 && html.lastIndexOf("</span>") !== html.length - 7) html += "</span>"
                    fg = null; bg = null; rev = false
                } else if (seq === "\x1b[7m") {
                    rev = true
                } else if (seq === "\x1b[27m") {
                    rev = false
                } else if (seq.indexOf("?25") >= 0 || seq.indexOf("?12") >= 0) {
                    continue
                } else {
                    var nums = []
                    for (var n in seq.match(/\d+/g)) nums.push(parseInt(seq.match(/\d+/g)[n]))
                    var j = 0
                    while (j < nums.length) {
                        if (nums[j] === 38 && j + 4 < nums.length && nums[j+1] === 2) {
                            fg = [null, nums[j+2], nums[j+3], nums[j+4]]
                            j += 5
                        } else if (nums[j] === 48 && j + 4 < nums.length && nums[j+1] === 2) {
                            bg = [null, nums[j+2], nums[j+3], nums[j+4]]
                            j += 5
                        } else { j++ }
                    }
                }
            }

            out.push(html)
        }
        return out.join("<br/>")
    }

    function findAnsiEnd(str, start) {
        var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for (var i = start; i < str.length; i++) {
            if (letters.indexOf(str[i]) >= 0) return i
        }
        return -1
    }

    function ansiSpan(text, fg, bg, rev) {
        if (!text) return ""
        var display = text.replace(/ /g, "\u00a0")
        var useFg = rev ? bg : fg
        var useBg = rev ? fg : bg
        if (useFg || useBg) {
            var style = ""
            if (useFg) style += "color:#" + useFg[1].toString(16).padStart(2,"0") + useFg[2].toString(16).padStart(2,"0") + useFg[3].toString(16).padStart(2,"0") + ";"
            if (useBg) style += "background:#" + useBg[1].toString(16).padStart(2,"0") + useBg[2].toString(16).padStart(2,"0") + useBg[3].toString(16).padStart(2,"0") + ";"
            return "<span style=\"" + style + "\">" + display + "</span>"
        }
        return display
    }

    function confirmThen(action) {
        confirmAction = action
    }

    function execPowerAction(action) {
        confirmAction = ""
        if (action === "logout") { cmdLogout.running = false; cmdLogout.running = true }
        else if (action === "reboot") { cmdReboot.running = false; cmdReboot.running = true }
        else if (action === "poweroff") { cmdPoweroff.running = false; cmdPoweroff.running = true }
        else if (action === "sleep") { cmdSleep.running = false; cmdSleep.running = true }
    }

    signal closeRequested()
    signal openWifiRequested()
    signal openBtRequested()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true }
        else if (event.key === Qt.Key_H) { selectedTab = Math.max(0, selectedTab - 1); event.accepted = true }
        else if (event.key === Qt.Key_L) { selectedTab = Math.min(2, selectedTab + 1); event.accepted = true }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Blue Rose ASCII art panel
        Rectangle {
            Layout.preferredWidth: 360
            Layout.minimumWidth: 120
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            color: Qt.rgba(0, 0, 0, 0.25)
            border.color: Theme.borderMain
            border.width: 1
            clip: true

            Flickable {
                anchors.fill: parent; clip: true
                contentWidth: artText.implicitWidth; contentHeight: artText.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
                Text {
                    id: artText
                    text: blueRoseText !== "" ? blueRoseText : formatBlueRoseFallback()
                    textFormat: Text.RichText
                    font.family: Theme.fontMono
                    font.pixelSize: 6
                    lineHeight: 1.0
                    color: Theme.accentBlue
                }
            }
        }

        // Control panels
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Text {
                text: Theme.frameHeader("HARDWARE_IO // CONTROL")
                color: Theme.accentBlue
                font.family: Theme.fontMono
                font.pixelSize: 13
            }

            StackLayout {
                id: tabStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: selectedTab

                // Tab 0: Audio + Backlight
                ColumnLayout {
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true; height: 40
                            color: "transparent"; border.width: 1; border.color: Theme.borderMain
                            Text { anchors.centerIn: parent; text: "RF_LINK // BT_TOGGLE"; font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgNormal }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor;
                                onClicked: {
                                    cmdBluetooth.command = ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]
                                    cmdBluetooth.running = true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; height: 40
                            color: "transparent"; border.width: 1; border.color: Theme.borderMain
                            Text { anchors.centerIn: parent; text: "WIFI // SCAN"; font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgNormal }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor;
                                onClicked: { closeRequested(); openWifiRequested() }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "AUDIO_GAIN // [" + Math.round(root.currentVolume * 100) + "%] " + Theme.blockMeter(root.currentVolume * 100)
                            font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgMuted
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 16; color: Theme.borderMain
                            Rectangle {
                                width: parent.width * root.currentVolume; height: parent.height; color: Theme.accentBlue
                                Behavior on width { NumberAnimation { duration: Theme.animDur; easing.type: Easing.OutCubic } }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onPressed: function(mouse) { setVol(mouse.x / width) }
                                onPositionChanged: function(mouse) { if (pressed) setVol(mouse.x / width) }
                                function setVol(ratio) {
                                    var pct = Math.max(0, Math.min(1, ratio))
                                    volSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct.toFixed(2)]
                                    volSet.running = false; volSet.running = true
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "BACKLIGHT // [" + Math.round(root.currentBrightness * 100) + "%] " + Theme.blockMeter(root.currentBrightness * 100)
                            font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgMuted
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 16; color: Theme.borderMain
                            Rectangle {
                                width: parent.width * root.currentBrightness; height: parent.height; color: Theme.accentBlue
                                Behavior on width { NumberAnimation { duration: Theme.animDur; easing.type: Easing.OutCubic } }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onPressed: function(mouse) { setBri(mouse.x / width) }
                                onPositionChanged: function(mouse) { if (pressed) setBri(mouse.x / width) }
                                function setBri(ratio) {
                                    var pct = Math.max(0, Math.min(1, ratio))
                                    brightSet.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"]
                                    brightSet.running = false; brightSet.running = true
                                }
                            }
                        }
                    }
                }

                // Tab 1: Network info
                ColumnLayout {
                    spacing: 8

                    Text {
                        text: "WIRED_SYS // " + (root.activeWifiSSID === "DISCONNECTED" ? "NULL" : root.activeWifiSSID)
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgNormal
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { closeRequested(); openWifiRequested() } }
                    }
                    Text {
                        text: "LINK_METR [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + root.wifiSignalStrength + "%"
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgMuted
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { closeRequested(); openWifiRequested() } }
                    }
                    Text {
                        text: "BT_LINK // " + root.btStatus
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                        color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { closeRequested(); openBtRequested() } }
                    }
                }

                // Tab 2: Power actions
                ColumnLayout {
                    spacing: 6

                    Text {
                        text: Theme.frameHeader("POWER_MATRIX // HALT_SEQUENCE")
                        color: Theme.accentRed
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 6

                        Repeater {
                            model: [
                                { label: "HALT",     action: "poweroff", icon: "\u25a0" },
                                { label: "REBOOT",   action: "reboot",   icon: "\u21bb" },
                                { label: "SLEEP",    action: "sleep",    icon: "\u23f8" },
                                { label: "LOGOUT",  action: "logout",   icon: "\u25b6" }
                            ]

                            delegate: Rectangle {
                                implicitWidth: 180; height: 44
                                color: confirmAction === modelData.action ? Qt.rgba(Theme.accentRed.r, Theme.accentRed.g, Theme.accentRed.b, 0.15) : "transparent"
                                border.color: confirmAction === modelData.action ? Theme.accentRed : Theme.borderMain
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: confirmAction === modelData.action
                                        ? "CONFIRM " + modelData.label + " ?"
                                        : modelData.icon + " " + modelData.label
                                    font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                                    color: confirmAction === modelData.action ? Theme.accentRed : Theme.fgNormal
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (confirmAction === modelData.action) execPowerAction(modelData.action)
                                        else confirmAction = modelData.action
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: Theme.frameFooter()
                        color: Theme.fgMuted
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    }
                }
            }

            // Tab selector
            RowLayout {
                spacing: 4
                Repeater {
                    model: ["AUDIO", "NETWORK", "POWER"]
                    delegate: Rectangle {
                        implicitWidth: 80; height: 26
                        color: selectedTab === index ? Theme.selectionBg : "transparent"
                        border.color: selectedTab === index ? Theme.accentBlue : Theme.borderMain
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                            color: selectedTab === index ? Theme.fgNormal : Theme.fgMuted
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: selectedTab = index
                        }
                    }
                }
            }
        }
    }

    function formatBlueRoseFallback() {
        return "\u256d\u2500\u2500\u256e<br/>" +
               "\u2502 \u256d\u256e \u2502<br/>" +
               "\u2502 \u2570\u256f \u2502<br/>" +
               "\u2570\u2500\u2500\u256f<br/>" +
               "<br/>" +
               "// BLUE ROSE<br/>" +
               "  THE WIRED"
    }
}
