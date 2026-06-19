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
        Layout.alignment: Qt.AlignVCenter

        Text {
            text: "\u25c8 NAVI_OS"
            font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true
            color: Theme.accentBlue
            Layout.alignment: Qt.AlignVCenter
        }

        TaskTracker { Layout.fillHeight: true; Layout.alignment: Qt.AlignVCenter }

        Text {
            text: Services.FocusedWindow.title !== ""
                ? Services.FocusedWindow.title
                : "[ DESKTOP ]"
            font.family: Theme.fontMono; font.pixelSize: 11
            color: Theme.fgMuted
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 280
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
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

        MouseArea {
            Layout.fillHeight: true; width: btLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            Layout.alignment: Qt.AlignVCenter
            onClicked: bar.btClicked()
            Text {
                id: btLabel; anchors.verticalCenter: parent.verticalCenter
                text: root.btStatus; font.family: Theme.fontMono; font.pixelSize: 11
                color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
            }
        }

        MouseArea {
            id: batArea
            Layout.fillHeight: true; cursorShape: Qt.PointingHandCursor
            Layout.alignment: Qt.AlignVCenter
            onClicked: bar.sysClicked()
            implicitWidth: batLabel.implicitWidth + batBar.width + 20
            RowLayout {
                spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: batLabel
                    text: root.batteryStatus + " " + Theme.blockMeter(root.batteryCapacity)
                    font.family: Theme.fontMono; font.pixelSize: 11
                    color: root.batteryCharging ? Theme.accentGreen : root.batteryCapacity <= 15 ? Theme.accentRed : Theme.fgNormal
                }
                Rectangle {
                    id: batBar
                    width: 60; height: 10
                    color: Theme.borderMain
                    radius: 1
                    Rectangle {
                        width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
                        height: parent.height
                        color: root.batteryCharging ? Theme.accentGreen : root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
                        radius: 1
                        Behavior on width { NumberAnimation { duration: Theme.animDur; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        Text {
            text: "[" + root.keyboardLayout + "]"
            font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted
            Layout.alignment: Qt.AlignVCenter
        }

        MouseArea {
            Layout.fillHeight: true; Layout.preferredWidth: wiredLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            Layout.alignment: Qt.AlignVCenter
            onClicked: bar.wifiClicked()
            Text {
                id: wiredLabel; anchors.verticalCenter: parent.verticalCenter
                text: "WIRED [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + (root.activeWifiSSID === "DISCONNECTED" ? "NONE" : root.activeWifiSSID)
                font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        MouseArea {
            Layout.fillHeight: true; width: sysLabel.implicitWidth + 4; cursorShape: Qt.PointingHandCursor
            Layout.alignment: Qt.AlignVCenter
            onClicked: bar.sysClicked()
            Text {
                id: sysLabel; anchors.verticalCenter: parent.verticalCenter
                text: "SYS"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            }
        }

        Text {
            text: root.currentTimestamp; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
