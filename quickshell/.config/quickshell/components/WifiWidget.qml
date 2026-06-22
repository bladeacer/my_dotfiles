import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../services"
import "../theme"

Rectangle {
    id: wifiCard
    implicitWidth: 380
    implicitHeight: expanded ? 480 : 64
    clip: true
    color: Theme.widgetBg
    border.color: expanded ? Theme.accentBlue : Theme.borderMain
    border.width: Theme.borderThin

    property bool expanded: true

    signal closeRequested()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true }
    }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 56

            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 12

                Text {
                    text: WifiService.connected ? "\u25b0" : "\u2591"
                    color: WifiService.connected ? Theme.accentBlue : Theme.fgMuted
                    font.family: Theme.fontMono; font.pixelSize: 16
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text {
                        text: "WIRED_SYS // " + (WifiService.connected ? WifiService.activeSSID : "NULL")
                        color: Theme.fgNormal; font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    }
                    Text {
                        text: "LINK_METR [" + Theme.blockMeter(WifiService.activeStrength) + "] " + WifiService.activeStrength + "%"
                        color: Theme.fgMuted; font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                    }
                }

                Text {
                    text: wifiCard.expanded ? "[-] COLLAPSE" : "[+] EXPAND"
                    color: wifiCard.expanded ? Theme.accentBlue : Theme.fgMuted
                    font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                }
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: wifiCard.expanded = !wifiCard.expanded
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 1; color: Theme.borderMain; visible: wifiCard.expanded
        }

        ListView {
            id: networkList
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 8
            model: WifiService.nearbyNetworks
            spacing: 2; visible: wifiCard.expanded; clip: true

            delegate: Rectangle {
                id: netDelegate
                required property var modelData
                width: networkList.width; height: 30
                property bool isActive: modelData && WifiService.activeSSID !== "" && modelData.ssid.toUpperCase() === WifiService.activeSSID
                color: isActive ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.08) : "transparent"
                border.color: rowMouse.containsMouse ? Theme.accentBlue : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8

                    Text {
                        text: (isActive ? "\u00bb " : "\u00b7 ") + (modelData ? modelData.ssid : "")
                        color: isActive ? Theme.accentBlue : (rowMouse.containsMouse ? Theme.fgNormal : Theme.fgMuted)
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }

                    Text {
                        text: Theme.blockMeter(modelData ? modelData.strength : 0)
                        color: isActive ? Theme.accentBlue : Theme.fgMuted
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                    }
                }

                MouseArea {
                    id: rowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (modelData) WifiService.connectToNetwork(modelData.ssid) }
                }
            }
        }
    }
}
