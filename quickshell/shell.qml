import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io // <-- Need this for the IPC engine
import "components"
import "theme"

ShellRoot {
    // ── 1. RIGHT SIDE BAR (Wifi) ──
    PanelWindow {
        id: widgetBar
        WlrLayershell.layer: WlrLayer.Overlay
        anchors { top: true; right: true }
        
        implicitWidth: 320
        implicitHeight: 600
        color: "transparent"
        
        // This registers 'widget_bar' into the quickshell msg map explicitly!
        IpcHandler {
            target: "widget_bar"
            function toggleVisibility(): void {
                widgetBar.visible = !widgetBar.visible;
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12
            WifiWidget { width: parent.width }
        }
    }

    // ── 2. CENTERED LAUNCHER WINDOW ──
    PanelWindow {
        id: launcherWindow
        WlrLayershell.layer: WlrLayer.Overlay
        anchors {} // No anchors centers the surface on Wayland
        
        implicitWidth: 560
        implicitHeight: 400
        color: "transparent"
        visible: false 

        // This registers 'launcher_hud' into the quickshell msg map explicitly!
        IpcHandler {
            target: "launcher_hud"
            function toggleVisibility(): void {
                launcherWindow.visible = !launcherWindow.visible;
            }
        }

        Launcher {}
    }
}
