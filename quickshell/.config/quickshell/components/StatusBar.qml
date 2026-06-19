import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services" as Services
import "../theme"

RowLayout {
    id: bar
    spacing: 0

    // ── LEFT: NAVI_OS + TASK TRACKER + FOCUSED WINDOW ──
    RowLayout {
        Layout.preferredWidth: parent.width * 0.38
        Layout.fillHeight: true
        spacing: 6
        Layout.leftMargin: 10
        clip: true

        Text {
            text: "\u25c8 NAVI_OS"
            font.family: Theme.fontMono
            font.pixelSize: 10
            font.bold: true
            color: Theme.accentBlue
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        TaskTracker { Layout.fillHeight: true }

        Text {
            text: Services.FocusedWindow.title !== ""
                ? "[" + Services.FocusedWindow.title.substring(0, 28) + "]"
                : ""
            font.family: Theme.fontMono
            font.pixelSize: 8
            color: Theme.fgMuted
            elide: Text.ElideRight
            visible: Services.FocusedWindow.title !== ""
        }
    }

    // ── CENTER: MEDIA ──
    Item {
        Layout.preferredWidth: parent.width * 0.28
        Layout.fillHeight: true
        clip: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            Text {
                anchors.centerIn: parent
                text: root.mediaStatus === "playing" ? "\u266b " + root.mediaMetadata : root.mediaMetadata
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.accentBlue
                elide: Text.ElideRight
                width: Math.min(implicitWidth, parent.width - 10)
            }

            onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
        }
    }

    // ── RIGHT: STATUS INDICATORS ──
    RowLayout {
        Layout.preferredWidth: parent.width * 0.34
        Layout.fillHeight: true
        spacing: 4
        Layout.rightMargin: 10
        Layout.alignment: Qt.AlignRight

        // Keyboard layout
        Text {
            text: "[" + root.keyboardLayout + "]"
            font.family: Theme.fontMono
            font.pixelSize: 8
            color: Theme.fgMuted
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        // Bluetooth
        MouseArea {
            Layout.fillHeight: true
            width: btLabel.implicitWidth
            cursorShape: Qt.PointingHandCursor

            Text {
                id: btLabel
                anchors.verticalCenter: parent.verticalCenter
                text: root.btStatus
                font.family: Theme.fontMono
                font.pixelSize: 8
                color: root.btStatus.includes("UP") ? Theme.accentBlue : Theme.fgMuted
            }
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        // Battery
        RowLayout {
            spacing: 3
            Layout.fillHeight: true

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    var c = root.batteryCapacity
                    if (c >= 90) return "\u26a1"
                    if (c >= 60) return "\u25b0"
                    return "\u25ae"
                }
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 18
                height: 5
                color: Theme.borderMain
                Rectangle {
                    width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
                    height: parent.height
                    color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.accentBlue
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.batteryCapacity + "%"
                font.family: Theme.fontMono
                font.pixelSize: 8
                color: root.batteryCapacity <= 15 ? Theme.accentRed : Theme.fgNormal
            }
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        // WiFi
        MouseArea {
            Layout.fillHeight: true
            width: Math.min(wifiLabel.implicitWidth, 130)
            cursorShape: Qt.PointingHandCursor

            Text {
                id: wifiLabel
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                elide: Text.ElideRight
                text: "WIFI [" + Theme.blockMeter(root.wifiSignalStrength) + "] " + (root.activeWifiSSID === "DISCONNECTED" ? "NONE" : root.activeWifiSSID.substring(0, 10))
                font.family: Theme.fontMono
                font.pixelSize: 8
                color: Theme.fgNormal
            }
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        // System toggle
        MouseArea {
            Layout.fillHeight: true
            width: sysLabel.implicitWidth
            cursorShape: Qt.PointingHandCursor
            onClicked: sysLoader.active = !sysLoader.active

            Text {
                id: sysLabel
                anchors.verticalCenter: parent.verticalCenter
                text: "SYS"
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: Theme.fgNormal
            }
        }

        Text {
            text: "\u2502"
            font.family: Theme.fontMono
            font.pixelSize: 9
            color: Theme.fgMuted
        }

        // Clock
        Text {
            text: root.currentTimestamp
            font.family: Theme.fontMono
            font.pixelSize: 8
            color: Theme.fgNormal
        }
    }
}
