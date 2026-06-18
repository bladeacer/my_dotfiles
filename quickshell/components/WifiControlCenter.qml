import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

Rectangle {
    id: wifiContainer
    anchors.fill: parent
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: 1

    signal closeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text { text: "┌── [ PROTOCOL.LAYER.WLAN // WIRE ]"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.accentBlue }
            Item { Layout.fillWidth: true }
            Text { 
                text: "[ DISCONNECT_HUD ]"
                font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted
                MouseArea { anchors.fill: parent; onClicked: wifiContainer.closeRequested() }
            }
        }

        ListView {
            id: wifiList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ["NODE_7A9F_5G", "LOCAL_LINK_UNSECURE", "WIRED_BACKBONE_TRUNK"]

            delegate: Rectangle {
                width: wifiList.width
                height: 32
                color: "transparent"
                border.color: Qt.rgba(Theme.borderMain.r, Theme.borderMain.g, Theme.borderMain.b, 0.15)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    Text { text: `LINK » ${modelData}`; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
                    Item { Layout.fillWidth: true }
                    Text { text: "[ SYNC_NODE ]"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.accentBlue }
                }
            }
        }
        
        Text { text: "└────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
    }
}
