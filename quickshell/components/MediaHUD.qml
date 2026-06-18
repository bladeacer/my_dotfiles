import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: mediaWindow
    WlrLayershell.layer: WlrLayer.Overlay
    
    anchors { top: true }
    WlrLayershell.margins { top: 28 }
    
    implicitWidth: 320; implicitHeight: 96
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // ── NATIVE PROCESS HANDLERS ──
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
            anchors.fill: parent; color: Theme.widgetBg; border.color: Theme.accentBlue; border.width: 1
            
            // Prevent clicks inside the HUD from closing it
            MouseArea { anchors.fill: parent; propagateComposedEvents: false }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 6
                Text { text: "┌── [ LAYER_AUDIO // COGNITIVE_PIPELINE ]"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue }
                Text { text: `  ${root.mediaMetadata}`; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal; elide: Text.ElideRight; Layout.fillWidth: true }
                
                RowLayout {
                    spacing: 16; Layout.alignment: Qt.AlignCenter
                    
                    Text { 
                        text: "<< PREV"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: { cmdPrev.running = false; cmdPrev.running = true; } 
                        } 
                    }
                    Text { 
                        text: "|| TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: { cmdToggle.running = false; cmdToggle.running = true; } 
                        } 
                    }
                    Text { 
                        text: "NEXT >>"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: { cmdNext.running = false; cmdNext.running = true; } 
                        } 
                    }
                }
                Text { text: "└────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
            }
        }
    }
}
