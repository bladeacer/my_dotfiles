import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
        
        IpcHandler {
            target: "widget_bar"
            function toggleVisibility() {
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

    // ── 2. GLOBAL LAUNCHER IPC MANAGER ──
    IpcHandler {
        target: "launcher_hud"
        function toggleVisibility() {
            if (launcherLoader.status === Loader.Ready && launcherLoader.sourceComponent !== null) {
                launcherLoader.sourceComponent = null;
            } else {
                launcherLoader.sourceComponent = launcherComponent;
            }
        }
    }

    Loader {
        id: launcherLoader
        sourceComponent: null
    }

    Component {
        id: launcherComponent
        
        PanelWindow {
            id: dynamicLauncherWindow
            WlrLayershell.layer: WlrLayer.Overlay
            anchors {} 
            
            implicitWidth: 560
            implicitHeight: 400
            color: "transparent"
            
            // FIX: Forces compositor seat mapping onto this surface frame instantly
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Force

            Launcher {
                onCloseRequested: {
                    launcherLoader.sourceComponent = null;
                }
            }
        }
    }
}
