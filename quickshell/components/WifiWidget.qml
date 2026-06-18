import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../services"
import "../theme" 

Rectangle {
    id: wifiCard
    width: parent ? parent.width : 300 // Safe fallback initialization
    
    property bool expanded: false
    implicitHeight: expanded ? 300 : 60
    clip: true 
    
    radius: Theme.radiusLarge
    color: Theme.widgetBg
    border.color: expanded ? Theme.accentBlue : Theme.borderMain
    border.width: 1

    Behavior on implicitHeight { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── TOP SECTION (Main Toggle Bar) ──
        // Wrapped in an Item to safely house the hover/click MouseArea outside layout rule breaks
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                spacing: 8

                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusCompact
                    color: WifiService.connected ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.1) : Qt.rgba(Theme.fgMuted.r, Theme.fgMuted.g, Theme.fgMuted.b, 0.1)

                    Text {
                        anchors.centerIn: parent
                        text: WifiService.wifiEnabled ? (WifiService.connected ? "󰤨" : "󰤯") : "󰤮"
                        color: WifiService.connected ? Theme.accentBlue : Theme.fgMuted
                        font.pointSize: 14
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: WifiService.connected ? WifiService.activeNetwork.ssid : "Disconnected"
                        color: Theme.fgNormal; font.weight: Font.Bold; font.pointSize: 10
                    }
                    Text {
                        text: WifiService.connected ? `Connected (${WifiService.activeNetwork.strength}%)` : "Click to view networks"
                        color: Theme.fgMuted; font.pointSize: 8
                    }
                }

                Text {
                    text: ""
                    font.pointSize: 10
                    color: Theme.fgMuted
                    rotation: wifiCard.expanded ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 200 } }
                }
            }

            // Moved out of RowLayout hierarchy so anchors.fill works perfectly with zero warnings
            MouseArea {
                id: headerMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: wifiCard.expanded = !wifiCard.expanded
            }
        }

        // ── EXPANDABLE AREA (Styled Network ListView) ──
        ListView {
            id: networkList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.padding
            model: WifiService.nearbyNetworks
            spacing: 4
            visible: opacity > 0
            opacity: wifiCard.expanded ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            delegate: Rectangle {
                // Fix: Evaluates the geometry safely against the ListView engine directly
                width: networkList.width
                height: 40
                radius: Theme.radiusCompact
                color: modelData.active ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.15) 
                                        : (rowMouse.containsMouse ? Qt.rgba(Theme.fgNormal.r, Theme.fgNormal.g, Theme.fgNormal.b, 0.05) : "transparent")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: modelData.ssid
                        color: modelData.active ? Theme.accentBlue : Theme.fgNormal
                        font.pointSize: 9
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: `${modelData.strength}%`
                        color: Theme.fgMuted
                        font.pointSize: 8
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        WifiService.connectToNetwork(modelData.ssid);
                    }
                }
            }
        }
    }
}
