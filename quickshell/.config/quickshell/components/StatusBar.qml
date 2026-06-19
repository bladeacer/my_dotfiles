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

        Text {
            text: "\u2502"
            font.family: Theme.fontMono; font.pixelSize: 11
            color: Theme.fgMuted
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

        Text {
            text: "[" + root.keyboardLayout + "]"
            font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted
        }

        Text { text: "\u2502"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }

        MouseArea {
            Layout.fillHeight: true; width: btLabel.implicitWidth; cursorShape: Qt.PointingHandCursor
            onClicked: bar.btClicked()
            Text {
                id: btLabel; anchors.verticalCenter: parent.verticalCenter
                text: root.btStatus; font.family: Theme.fontMono; font.pixelSize: 11
                color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
            }
        }

        Text { text: "\u2502"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }

        RowLayout {
            spacing: 3; Layout.fillHeight: true
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: { var c = root.batteryCapacity; if (c >= 90) return "\u2261"; if (c >= 60) return "\u25b0"; return "\u25ae" }
                font.family: Theme.fontMono; font.pixelSize: 11
                color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
            }
            Rectangle {
                Layout.alignment: Qt.AlignVCenter; width: 18; height: 5; color: Theme.borderMain
                Rectangle {
                    width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
                    height: parent.height
                    color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
                }
            }
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.batteryCapacity + "%"; font.family: Theme.fontMono; font.pixelSize: 11
                color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.fgNormal
            }
        }

        Text { text: "\u2502"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }

        MouseArea {
            Layout.fillHeight: true; Layout.preferredWidth: wifiLabel.implicitWidth + 8; cursorShape: Qt.PointingHandCursor
            onClicked: bar.wifiClicked()
            Text {
                id: wifiLabel; anchors.verticalCenter: parent.verticalCenter
                text: "WIFI [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + (root.activeWifiSSID === "DISCONNECTED" ? "NONE" : root.activeWifiSSID)
                font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        Text { text: "\u2502"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }

        MouseArea {
            Layout.fillHeight: true; width: sysLabel.implicitWidth; cursorShape: Qt.PointingHandCursor
            onClicked: bar.sysClicked()
            Text {
                id: sysLabel; anchors.verticalCenter: parent.verticalCenter
                text: "SYS"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        Text { text: "\u2502"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }

        Text {
            text: root.currentTimestamp; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
        }
    }
}
