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

        // ── Header ──
        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 56

            RowLayout {
                anchors.left: parent.left; anchors.right: refreshBtn.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12; anchors.rightMargin: 6
                spacing: 12

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

            // Refresh button — separate hitbox on the right edge
            Text {
                id: refreshBtn
                text: "\u65b0"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 12
                color: Theme.fgMuted
                font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: WifiService.refreshPending = 1
                }
            }

            // Collapse/expand — covers everything except the refresh button
            MouseArea {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: refreshBtn.left
                anchors.rightMargin: 4
                cursorShape: Qt.PointingHandCursor
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
                width: networkList.width; height: 30
                color: modelData && modelData.active ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.08) : "transparent"
                border.color: rowMouse.containsMouse ? Theme.accentBlue : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8

                    Text {
                        text: (modelData && modelData.active ? "\u00bb " : "\u00b7 ") + (modelData ? modelData.ssid : "")
                        color: modelData && modelData.active ? Theme.accentBlue : (rowMouse.containsMouse ? Theme.fgNormal : Theme.fgMuted)
                        font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }

                    Text {
                        text: modelData && modelData.security ? modelData.security : ""
                        color: Theme.fgMuted
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                        visible: modelData && modelData.security !== ""
                    }

                    Text {
                        text: Theme.blockMeter(modelData ? modelData.strength : 0)
                        color: modelData && modelData.active ? Theme.accentBlue : Theme.fgMuted
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                    }
                }

                MouseArea {
                    id: rowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData && !modelData.active) {
                            WifiService.connectTarget = modelData.ssid
                            WifiService.connectPending = 1
                        }
                    }
                }
            }
        }
    }
}
