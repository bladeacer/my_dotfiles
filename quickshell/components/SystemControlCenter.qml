import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

Rectangle {
    id: sysContainer
    anchors.fill: parent
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: 1

    signal closeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text { text: "┌── [ COGNITIVE_DEVICE_IO // NAVI ] ────"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.accentBlue }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            
            // FIX: Replaced invalid 'spacing' property with correct grid parameters
            rowSpacing: 8
            columnSpacing: 8

            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.borderMain
                Text { anchors.centerIn: parent; text: "RF_LINK // BLUETOOTH_ON"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
            }
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.accentBlue
                Text { anchors.centerIn: parent; text: "OPTICAL // WEBCAM_BLOCKED"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.accentBlue }
            }
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.borderMain
                Text { anchors.centerIn: parent; text: "DAEMON // NOTIFS_MUTED"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            }
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: "#FF5555"
                Text { anchors.centerIn: parent; text: "HALT // TERMINATE_SESSION"; font.family: Theme.fontMono; font.pixelSize: 9; color: "#FF5555" }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text { text: "AUDIO_GAIN // [ 0x50 ]"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            Rectangle { Layout.fillWidth: true; height: 2; color: Theme.borderMain; Rectangle { width: parent.width * 0.8; height: parent.height; color: Theme.accentBlue } }

            Item { height: 2 }

            Text { text: "BACKLIGHT  // [ 0x41 ]"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            Rectangle { Layout.fillWidth: true; height: 2; color: Theme.borderMain; Rectangle { width: parent.width * 0.65; height: parent.height; color: Theme.accentBlue } }
            
            Item { height: 2 }

            Text { text: "CELL_CAPACITANCE // 92% [ DISCHARGING ]"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
        }

        Item { Layout.fillHeight: true }
        Text { text: "└────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
    }
}
