import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
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
            color: Network.connected ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.1) : Qt.rgba(Theme.fgMuted.r, Theme.fgMuted.g, Theme.fgMuted.b, 0.1)

            Text {
                anchors.centerIn: parent
                // Added safety checks for Network.wifi existence
                text: (Network.wifi && Network.wifi.enabled) 
                      ? (Network.connected ? "󰤨" : "󰤯") 
                      : "󰤮"
                color: Network.connected ? Theme.accentBlue : Theme.fgMuted
                font.pointSize: 14
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                // Safely checks if wifi and activeNetwork exist before pulling the SSID
                text: (Network.wifi && Network.wifi.activeNetwork) ? Network.wifi.activeNetwork.ssid : "Disconnected"
                color: Theme.fgNormal
                font.weight: Font.Bold
                font.pointSize: 10
                Layout.alignment: Qt.AlignLeft
            }

            Text {
                // Safely handles the signal strength percentage string mapping
                text: Network.connected ? `Connected (${(Network.wifi && Network.wifi.activeNetwork) ? Network.wifi.activeNetwork.signalStrength : 0}%)` : "No Connection"
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
