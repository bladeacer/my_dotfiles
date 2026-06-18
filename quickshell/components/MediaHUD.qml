import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: mediaWindow
    WlrLayershell.layer: WlrLayer.Overlay
    
    // FIX: Full width layer alignment definition forces compositor boundary indexing below the top bar
    anchors { top: true; left: true; right: true }
    WlrLayershell.margins { top: 26 } // Explicit offset equal to the status bar height
    
    implicitHeight: 96
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Process { id: cmdPrev; command: ["playerctl", "previous"] }
    Process { id: cmdToggle; command: ["playerctl", "play-pause"] }
    Process { id: cmdNext; command: ["playerctl", "next"] }

    FocusScope {
        anchors.fill: parent; focus: true
        Keys.onEscapePressed: mediaHUDLoader.active = false

        MouseArea {
            anchors.fill: parent
            onClicked: mediaHUDLoader.active = false
        }

        Rectangle {
            // Constrain visual window box to look like a floating clean panel
            width: 320; height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.widgetBg; border.color: Theme.accentBlue; border.width: 1
            
            MouseArea { anchors.fill: parent; propagateComposedEvents: false }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 4
                Text { text: "┌── [ LAYER_AUDIO // COGNITIVE_PIPELINE ]"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue }
                Text { text: `  ${root.mediaMetadata}`; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal; elide: Text.ElideRight; Layout.fillWidth: true }
                
                RowLayout {
                    spacing: 16; Layout.alignment: Qt.AlignCenter
                    
                    Text { 
                        text: "<< PREV"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
                        MouseArea { anchors.fill: parent; onClicked: { cmdPrev.running = false; cmdPrev.running = true; } } 
                    }
                    Text { 
                        text: "|| TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue
                        MouseArea { anchors.fill: parent; onClicked: { cmdToggle.running = false; cmdToggle.running = true; } } 
                    }
                    Text { 
                        text: "NEXT >>"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
                        MouseArea { anchors.fill: parent; onClicked: { cmdNext.running = false; cmdNext.running = true; } } 
                    }
                }
                Text { text: "└────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
            }
        }
    }
}
