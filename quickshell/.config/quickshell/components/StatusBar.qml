import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services" as Services
import "../theme"

RowLayout {
    id: bar
    spacing: 0

    signal btClicked()
    signal wifiClicked()
    signal sysClicked()

    RowLayout {
        Layout.preferredWidth: parent.width * 0.32
        Layout.fillHeight: true
        spacing: 4
        Layout.leftMargin: 8
        clip: true

        Text {
            text: "\u25c8 NAVI_OS"
            font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true
            color: Theme.accentBlue
        }

        TaskTracker { Layout.fillHeight: true }

        Text {
            text: Services.FocusedWindow.title !== ""
                ? "[" + Services.FocusedWindow.title.substring(0, 28) + "]"
                : ""
            font.family: Theme.fontMono; font.pixelSize: 11
            color: Theme.fgMuted; elide: Text.ElideRight
            visible: Services.FocusedWindow.title !== ""
        }
    }

    Item {
        Layout.preferredWidth: parent.width * 0.28
        Layout.fillHeight: true; clip: true
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            Text {
                anchors.centerIn: parent
                text: root.mediaStatus === "playing" ? "\u266b " + root.mediaMetadata : root.mediaMetadata
                font.family: Theme.fontMono; font.pixelSize: 11
                color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.accentBlue
                elide: Text.ElideRight; width: Math.min(implicitWidth, parent.width - 10)
            }
            onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
        }
    }

    RowLayout {
        Layout.preferredWidth: parent.width * 0.44
        Layout.fillHeight: true; spacing: 3; Layout.rightMargin: 10
        Layout.alignment: Qt.AlignRight

        MouseArea {
            Layout.fillHeight: true; width: btLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            onClicked: bar.btClicked()
            Text {
                id: btLabel; anchors.verticalCenter: parent.verticalCenter
                text: root.btStatus; font.family: Theme.fontMono; font.pixelSize: 11
                color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
            }
        }

        MouseArea {
            Layout.fillHeight: true; width: batLabel.implicitWidth + batBar.width + 6; cursorShape: Qt.PointingHandCursor
            onClicked: bar.sysClicked()
            RowLayout {
                id: batRow; spacing: 2; anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: batLabel
                    text: {
                        var c = root.batteryCapacity
                        var meter = c >= 75 ? "\u2588" : c >= 50 ? "\u2586" : c >= 25 ? "\u2584" : "\u2582"
                        return "[ " + meter + " ] " + root.batteryCapacity + "%"
                    }
                    font.family: Theme.fontMono; font.pixelSize: 11
                    color: root.batteryCapacity <= 15 ? Theme.accentRed : root.batteryCharging ? Theme.accentGreen : Theme.fgNormal
                }
                Rectangle {
                    id: batBar; width: 18; height: 5; color: Theme.borderMain; visible: !root.batteryCharging
                    Rectangle {
                        width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
                        height: parent.height
                        color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
                    }
                }
            }
        }

        Text {
            text: "[" + root.keyboardLayout + "]"
            font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted
        }

        MouseArea {
            Layout.fillHeight: true; Layout.preferredWidth: wifiLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            onClicked: bar.wifiClicked()
            Text {
                id: wifiLabel; anchors.verticalCenter: parent.verticalCenter
                text: "WIFI [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + (root.activeWifiSSID === "DISCONNECTED" ? "NONE" : root.activeWifiSSID)
                font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        MouseArea {
            Layout.fillHeight: true; width: sysLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            onClicked: bar.sysClicked()
            Text {
                id: sysLabel; anchors.verticalCenter: parent.verticalCenter
                text: "SYS"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        Text {
            text: root.currentTimestamp; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
        }
    }
}
