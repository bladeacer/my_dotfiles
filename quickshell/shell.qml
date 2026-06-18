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

    Connections {
        target: Quickshell
        ignoreUnknownSignals: true
        function onActiveWindowChanged() {
            if (Quickshell.activeWindow === dynamicLauncherWindow && launcherLoader.item) {
                launcherLoader.item.requestInputFocus();
            }
        }
    }

    Component {
        id: launcherComponent
        
        PanelWindow {
            id: dynamicLauncherWindow
            WlrLayershell.layer: WlrLayer.Overlay
            
            // Anchoring everywhere stretches the surface context to capture out-of-bounds clicks safely
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            Launcher {
                onCloseRequested: {
                    launcherLoader.sourceComponent = null;
                }
            }
        }
    }
}
