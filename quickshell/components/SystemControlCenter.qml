import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

Rectangle {
    id: sysContainer
    // FIX: Set explicit size frameworks so the popup wrapper matches baseline geometry
    implicitWidth: 320
    implicitHeight: 400
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text { text: "┌── [ HARDWARE_IO // CONTROL ] ────"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.accentBlue }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 8
            columnSpacing: 8

            // Bluetooth Quick Toggle Node
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.borderMain
                Text { anchors.centerIn: parent; text: "RF_LINK // BT_TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let p = Quickshell.createProcess(["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]);
                        p.running = true;
                    }
                }
            }
            
            // Camera Privacy Shutter Node
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.accentBlue
                Text { anchors.centerIn: parent; text: "OPTICAL // TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.accentBlue }
            }
            
            // Notifications Mute Node
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.borderMain
                Text { anchors.centerIn: parent; text: "DAEMON // SILENT"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            }
            
            // Session Terminator Node
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: "#FF5555"
                Text { anchors.centerIn: parent; text: "HALT // LOGOUT"; font.family: Theme.fontMono; font.pixelSize: 9; color: "#FF5555" }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.createProcess(["loginctl", "terminate-session", "self"]).running = true
                }
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

            Text { text: `CELL_CAPACITANCE // ${root.batteryTelemetry.replace("BAT // ", "")}`; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
        }

        Item { Layout.fillHeight: true }
        Text { text: "└────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
    }
}
