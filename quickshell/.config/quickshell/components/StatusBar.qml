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
        spacing: 6
        Layout.leftMargin: 8
        clip: true

        Text {
            text: "\u25c8 NAVI_OS"
            font.family: Theme.fontMono; font.pixelSize: 11; font.bold: true
            color: Theme.fgNormal
            Layout.alignment: Qt.AlignVCenter
        }

        TaskTracker { Layout.fillHeight: true; Layout.alignment: Qt.AlignVCenter }

        Text {
            text: root.focusedTitle !== ""
            ? "FOCUS // " + root.focusedAppId.split(".").pop()
            // + " // " + root.focusedTitle
            : "FOCUS // *_*"
            font.family: Theme.fontMono; font.pixelSize: 11
            color: root.focusedTitle !== "" ? Theme.accentPurple : Theme.fgMuted
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 360
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
                font.family: Theme.fontMono; font.pixelSize: 11; font.bold: root.mediaStatus === "playing"
                color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.fgNormal
                elide: Text.ElideRight; width: Math.min(implicitWidth, parent.width - 10)
            }
            onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
        }
    }

    RowLayout {
        Layout.preferredWidth: parent.width * 0.44
        Layout.fillHeight: true; spacing: 8; Layout.rightMargin: 12
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

        Item {
            Layout.fillHeight: true; implicitWidth: btLabel.implicitWidth + 4
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.btClicked() }
            Text {
                id: btLabel; anchors.verticalCenter: parent.verticalCenter
                text: root.btStatus; font.family: Theme.fontMono; font.pixelSize: 11
                color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
            }
        }

        Item {
            Layout.fillHeight: true
            implicitWidth: batLabel.implicitWidth + batBar.width + 24
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.sysClicked() }
            RowLayout {
                spacing: 4; anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: batLabel
                    text: root.batteryStatus
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

        Item {
            Layout.fillHeight: true; implicitWidth: wiredLabel.implicitWidth + 4
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.wifiClicked() }
            Text {
                id: wiredLabel; anchors.verticalCenter: parent.verticalCenter
                text: "WIRED [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + (root.activeWifiSSID === "DISCONNECTED" ? "NONE" : root.activeWifiSSID)
                font.family: Theme.fontMono; font.pixelSize: 11
                color: root.activeWifiSSID === "DISCONNECTED" ? Theme.fgMuted : Theme.accentPink
            }
        }

        Item {
            Layout.fillHeight: true; implicitWidth: sysLabel.implicitWidth + 4
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.sysClicked() }
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
