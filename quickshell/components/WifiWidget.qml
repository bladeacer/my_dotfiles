import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../services" // <-- Import your service folder
import "../theme" 

Rectangle {
    id: wifiCard
    height: 60
    
    radius: Theme.radiusLarge
    color: Theme.widgetBg
    border.color: hoverArea.containsMouse ? Theme.accentBlue : Theme.borderMain
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.padding
        spacing: 8

        Rectangle {
            width: 32
            height: 32
            radius: Theme.radiusCompact
            color: WifiService.connected ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.1) : Qt.rgba(Theme.fgMuted.r, Theme.fgMuted.g, Theme.fgMuted.b, 0.1)

            Text {
                anchors.centerIn: parent
                // Check against your parsed backend state flags
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
                color: Theme.fgNormal
                font.weight: Font.Bold
                font.pointSize: 10
                Layout.alignment: Qt.AlignLeft
            }

            Text {
                text: WifiService.connected ? `Connected (${WifiService.activeNetwork.strength}%)` : "No Connection"
                color: Theme.fgMuted
                font.pointSize: 8
                Layout.alignment: Qt.AlignLeft
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
