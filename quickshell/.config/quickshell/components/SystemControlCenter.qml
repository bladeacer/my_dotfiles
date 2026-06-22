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

    property string coplandText: ""
    property bool useBraille: true
    property string confirmAction: ""
    property int selectedTab: 0

    Process {
        id: artReader
        command: ["bash", "-c", "cat \"$HOME/my_dotfiles/logo/CoplandOS_clean\" 2>/dev/null || true"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) coplandText = text
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

    Component.onCompleted: artReader.running = true

    function formatCoplandFallback() {
        return "    /==\\\n    \\==/\n\n.========-.\n'=========='\n  COPLAND_OS"
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
        if (event.key === Qt.Key_H) { selectedTab = Math.max(0, selectedTab - 1); event.accepted = true }
        else if (event.key === Qt.Key_L) { selectedTab = Math.min(2, selectedTab + 1); event.accepted = true }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // CoplandOS ASCII art panel
        Rectangle {
            Layout.preferredWidth: 360
            Layout.minimumWidth: 120
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            color: "transparent"
            border.color: Theme.borderMain
            border.width: 1
            clip: true

            Text {
                id: artText
                anchors.centerIn: parent
                text: coplandText !== "" ? coplandText : formatCoplandFallback()
                textFormat: Text.PlainText
                font.family: Theme.fontMono
                font.pixelSize: 12
                lineHeight: 1.0
                color: Theme.accentBlue
            }
        }

        // Control panels
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Text {
                text: Theme.frameHeader("HARDWARE_IO // CTRL", 54)
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
                                onClicked: openWifiRequested()
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
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: openWifiRequested() }
                    }
                    Text {
                        text: "BT_LINK // " + root.btStatus
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                        color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: openBtRequested() }
                    }
                }

                // Tab 2: Power actions
                ColumnLayout {
                    spacing: 6

                    Text {
                        text: Theme.frameHeader("PWR_MATRIX // HALT_SEQ", 54)
                        color: Theme.accentRed
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 6
                        Layout.leftMargin: 12

                        Repeater {
                            model: [
                                { icon: "切",  action: "poweroff", label: "Halt" },
                                { icon: "眠",  action: "sleep",    label: "Sleep" },
                                { icon: "出",  action: "logout",   label: "Logout" },
                                { icon: "再",  action: "reboot",   label: "Reboot" }
                            ]

                            delegate: Rectangle {
                                implicitWidth: 180; height: 44
                                color: confirmAction === modelData.action ? Qt.rgba(Theme.accentRed.r, Theme.accentRed.g, Theme.accentRed.b, 0.15) : "transparent"
                                border.color: confirmAction === modelData.action ? Theme.accentRed : Theme.borderMain
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: confirmAction === modelData.action
                                        ? "CONFIRM " + modelData.label + "?"
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
                        text: Theme.frameFooter(54)
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


}
