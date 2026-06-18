import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../services"
import "../theme" 

Rectangle {
    id: wifiCard
    width: parent ? parent.width : 300
    
    property bool expanded: false
    implicitHeight: expanded ? 320 : 64
    clip: true 
    
    radius: 0 
    color: Theme.widgetBg
    border.color: expanded ? Theme.accentBlue : Theme.borderMain
    border.width: Theme.borderThin

    // Fixed retro stutter: Standard linear transition, but pixel-snapped
    Behavior on implicitHeight { 
        NumberAnimation { duration: 140; easing.type: Easing.Linear } 
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            Text { text: "┌"; color: Theme.fgMuted; font.family: Theme.fontMono; anchors { top: parent.top; left: parent.left; margins: 6 } }
            Text { text: "┐"; color: Theme.fgMuted; font.family: Theme.fontMono; anchors { top: parent.top; right: parent.right; margins: 6 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: WifiService.wifiEnabled ? (WifiService.connected ? "▰" : "▱") : "×"
                    color: WifiService.connected ? Theme.accentBlue : Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 14
                    
                    Timer {
                        interval: 750
                        running: !WifiService.connected
                        repeat: true
                        onTriggered: parent.text = (parent.text === "▱" ? "░" : "▱")
                        onRunningChanged: if(!running) parent.text = WifiService.wifiEnabled ? "▰" : "×"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: `WIRED_SYS // ${WifiService.connected ? WifiService.activeNetwork.ssid : "NULL"}`
                        color: Theme.fgNormal
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                    }
                    
                    Text {
                        property int strength: WifiService.connected ? WifiService.activeNetwork.strength : 0
                        text: {
                            if (!WifiService.connected) return "STATUS :: STDBY_MODE";
                            let bars = Math.ceil(strength / 20);
                            let filled = "█████".substring(0, bars);
                            let empty = "░░░░░".substring(0, 5 - bars);
                            return `LINK_METR [${filled}${empty}] ${strength}%`;
                        }
                        color: Theme.fgMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                    }
                }

                Text {
                    text: expanded ? "[-] LAY_02" : "[+] LAY_01"
                    color: expanded ? Theme.accentBlue : Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: wifiCard.expanded = !wifiCard.expanded
            }
        }

        Text {
            Layout.fillWidth: true
            text: "─".repeat(width / 7)
            color: Theme.borderMain
            font.family: Theme.fontMono
            font.pixelSize: 11
            visible: wifiCard.expanded
            clip: true
        }

        ListView {
            id: networkList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            model: WifiService.nearbyNetworks
            spacing: 2
            visible: opacity > 0
            opacity: wifiCard.expanded ? 1.0 : 0.0

            delegate: Rectangle {
                width: networkList.width
                height: 32
                radius: 0 
                
                color: modelData.active ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.08) : "transparent"
                border.color: rowMouse.containsMouse ? Theme.accentBlue : "transparent"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    Text {
                        text: `${modelData.active ? "» " : "· "}${modelData.ssid}`
                        color: modelData.active ? Theme.accentBlue : (rowMouse.containsMouse ? Theme.fgNormal : Theme.fgMuted)
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        property int bars: Math.ceil(modelData.strength / 25)
                        text: "▮▮▮▮".substring(0, bars) + "▯▯▯▯".substring(0, 4 - bars)
                        color: modelData.active ? Theme.accentBlue : Theme.fgMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { WifiService.connectToNetwork(modelData.ssid); }
                }
            }
        }
    }
}
