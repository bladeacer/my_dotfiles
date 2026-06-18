import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: launcherCard
    anchors.fill: parent
    
    radius: 0
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "┌── [ SYSTEM_EXEC // RUN_PROMPT ] ────────────────────────────────┐"
            color: Theme.accentBlue
            font.family: Theme.fontMono
            font.pixelSize: 11
        }

        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            
            // Binds to the underlying array wrapper cleanly
            model: DesktopEntries.applications

            delegate: Rectangle {
                width: appList.width
                height: 32
                color: appMouse.containsMouse ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.08) : "transparent"
                border.color: appMouse.containsMouse ? Theme.accentBlue : "transparent"
                border.width: 1
                
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    verticalAlignment: Text.AlignVCenter
                    
                    // FIX: Quickshell populates the application data into the 'modelData' variable directly!
                    text: `» ${(modelData && modelData.name ? modelData.name : "UNKNOWN_APP").toUpperCase()}`
                    color: appMouse.containsMouse ? Theme.fgNormal : Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }

                MouseArea {
                    id: appMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // FIX: Safely targets Quickshell's native `.execute()` function signature on modelData
                        if (modelData && typeof modelData.execute === "function") {
                            modelData.execute();
                        }
                        launcherWindow.visible = false;
                    }
                }
            }
        }
        
        Text {
            text: "└────────────────────────────────────────────────────────────────┘"
            color: Theme.fgMuted
            font.family: Theme.fontMono
            font.pixelSize: 11
        }
    }
}
