import QtQuick
import Quickshell
import Quickshell.Wayland
import "components"
import "theme"

ShellRoot {
    PanelWindow {
        id: widgetBar

        // FIX: Modern layer-shell enum syntax
        WlrLayershell.layer: WlrLayer.Overlay
        
        anchors {
            top: true
            right: true
        }
        
        // FIX: Using implicit sizes to satisfy deprecation warnings
        implicitWidth: 300
        implicitHeight: 500
        color: "transparent"

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: Theme.padding

            WifiWidget {
                width: parent.width
            }
        }
    }
}
