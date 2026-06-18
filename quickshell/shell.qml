import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "components"
import "theme"

ShellRoot {
    id: root

    Component.onCompleted: {
        Quickshell.registerShortcut("Meta+Space", () => launcherLoader.active = !launcherLoader.active);
        Quickshell.registerShortcut("Meta+N", () => wifiLoader.active = !wifiLoader.active);
        Quickshell.registerShortcut("Meta+S", () => sysLoader.active = !sysLoader.active);
    }

    // ── DATA STORAGE ENGINE ──
    property string currentTimestamp: "0000.00.00 │ 00:00:00"
    property string batteryTelemetry: "BAT // --%"
    property string bluetoothTelemetry: "BT // DOWN"
    property string wifiTelemetry: "WLAN // IDLE"
    property string mediaMetadata: "TRACK // IDLE"

    // Time Engine
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let d = new Date();
            let pad = (n) => n.toString().padStart(2, '0');
            root.currentTimestamp = `${d.getFullYear()}.${pad(d.getMonth()+1)}.${pad(d.getDate())} │ ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
        }
    }

    // Isolated Battery Parser
    Process {
        id: batPipe
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: SplitParser {
            onRead: (line) => { root.batteryTelemetry = line.trim() !== "" ? `BAT // ${line.trim()}%` : "BAT // --%"; }
        }
    }

    // Isolated Bluetooth Parser
    Process {
        id: btPipe
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'UP' || echo 'DOWN'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => { root.bluetoothTelemetry = `BT // ${line.trim().toUpperCase()}`; }
        }
    }

    // Isolated Wi-Fi Router Parser
    Process {
        id: wifiPipe
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d':' -f2 || echo 'DISCONNECTED'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                let out = line.trim();
                root.wifiTelemetry = (out === "" || out === "DISCONNECTED") ? "WLAN // DISCONNECTED" : `WLAN // ${out.toUpperCase()}`;
            }
        }
    }

    // Isolated Media Tracker Engine
    Process {
        id: mediaPipe
        command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}"]
        running: true
        stdout: SplitParser {
            onRead: (line) => { root.mediaMetadata = line.trim() !== "" ? `TRACK // ${line.toUpperCase()}` : "TRACK // IDLE"; }
        }
    }

    // Global Polling Loop (Triggers every 3 seconds)
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            batPipe.running = false; batPipe.running = true;
            btPipe.running = false; btPipe.running = true;
            wifiPipe.running = false; wifiPipe.running = true;
            mediaPipe.running = false; mediaPipe.running = true;
        }
    } 

    // ── CORE BAR PANEL ──
    PanelWindow {
        id: statusBar
        WlrLayershell.layer: WlrLayer.Top
        anchors { top: true; left: true; right: true }
        implicitHeight: 26
        color: Theme.widgetBg

        RowLayout {
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.preferredWidth: parent.width * 0.30
                Layout.fillHeight: true; spacing: 10; Layout.leftMargin: 12
                Text { text: "NAVI_OS │"; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; color: Theme.accentBlue }
                TaskTracker { Layout.fillHeight: true }
            }

            Item {
                Layout.preferredWidth: parent.width * 0.30
                Layout.fillHeight: true; clip: true
                MouseArea {
                    anchors.fill: parent
                    Text {
                        anchors.centerIn: parent; text: root.mediaMetadata
                        font.family: Theme.fontMono; font.pixelSize: 10
                        color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.accentBlue
                        elide: Text.ElideRight; width: Math.min(implicitWidth, parent.width - 10)
                    }
                    onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
                }
            }

            StatusRight {
                Layout.preferredWidth: parent.width * 0.40
                Layout.fillHeight: true; Layout.rightMargin: 12
                onWifiClicked: wifiLoader.active = !wifiLoader.active
                onSysClicked: sysLoader.active = !sysLoader.active
            }
        }
    }

    // ── STYLIZED HOOK LAYERS ──
    Loader { id: mediaHUDLoader; active: false; sourceComponent: mediaComp }
    Component { id: mediaComp; MediaHUD {} }

    Loader { id: launcherLoader; active: false; sourceComponent: launchComp }
    Component { 
      id: launchComp
      PanelWindow { 
        WlrLayershell.layer: WlrLayer.Overlay

        // FIX: Replaced anchors.fill: parent with explicit layer shell edge targeting
        anchors { top: true; bottom: true; left: true; right: true }

        color: "transparent"
        Launcher { 
          onCloseRequested: { launcherLoader.active = false; } 
        } 
      } 
    }

    Loader { id: wifiLoader; active: false; sourceComponent: wifiComp }
    Component { 
        id: wifiComp
        PanelWindow { 
            WlrLayershell.layer: WlrLayer.Overlay
            anchors { top: true; right: true }
            WlrLayershell.margins { top: 32; right: 12 }
            implicitWidth: 360; implicitHeight: 480
            color: "transparent"
            FocusScope { 
                anchors.fill: parent; focus: true
                Keys.onEscapePressed: { wifiLoader.active = false; }
                WifiControlCenter { 
                    onCloseRequested: { wifiLoader.active = false; } 
                } 
            } 
        } 
    }

    Loader { id: sysLoader; active: false; sourceComponent: sysComp }
    Component { 
        id: sysComp
        PanelWindow { 
            WlrLayershell.layer: WlrLayer.Overlay
            anchors { top: true; right: true }
            WlrLayershell.margins { top: 32; right: 12 }
            implicitWidth: 320; implicitHeight: 400
            color: "transparent"
            FocusScope { 
                anchors.fill: parent; focus: true
                Keys.onEscapePressed: { sysLoader.active = false; }
                SystemControlCenter { 
                    onCloseRequested: { sysLoader.active = false; } 
                } 
            } 
        } 
    }
}
