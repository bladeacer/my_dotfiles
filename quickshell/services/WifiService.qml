pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Fixed: Removed 'readonly' so JS can update this dynamically ──
    property var activeNetwork: null
    readonly property bool connected: activeNetwork !== null
    
    // ── Fixed: Tracks the string state from the collector ──
    property string wifiRawStatus: "disabled"
    readonly property bool wifiEnabled: wifiRawStatus === "enabled"

    function update(): void {
        wifiStatusProc.running = true;
        getCurrentSsid.running = true;
    }

    // 1. Monitors network state updates in real-time
    Process {
        id: subscriber
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: root.update()
        }
    }

    // 2. Checks if Wi-Fi hardware radio is on or off
    Process {
        id: wifiStatusProc
        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        // Fixed: Properly collecting the stdout stream text
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiRawStatus = text.trim();
            }
        }
    }

    // 3. Fetches only the currently active SSID data line
    Process {
        id: getCurrentSsid
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,SSID", "d", "w"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                let foundActive = null;

                for (const line of lines) {
                    const parts = line.split(":");
                    if (parts[0] === "yes") {
                        foundActive = {
                            ssid: parts[2] ?? "Unknown Network",
                            strength: parseInt(parts[1]) ?? 0
                        };
                        break;
                    }
                }
                root.activeNetwork = foundActive;
            }
        }
    }

    Component.onCompleted: update()
}
