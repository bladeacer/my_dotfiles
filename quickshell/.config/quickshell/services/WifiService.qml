pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var activeNetwork: null
    readonly property bool connected: activeNetwork !== null
    
    property string wifiRawStatus: "disabled"
    readonly property bool wifiEnabled: wifiRawStatus === "enabled"

    // ── New property holding the array of nearby networks ──
    property var nearbyNetworks: []

    function update(): void {
        wifiStatusProc.running = true;
        getNetworkList.running = true;
    }

    Process {
        id: subscriber
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser { onRead: root.update() }
    }

    Process {
        id: wifiStatusProc
        running: true
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: { root.wifiRawStatus = text.trim(); } }
    }

    // Parses the full list of SSIDs, signals, and active statuses
    Process {
        id: getNetworkList
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,SSID", "d", "w"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                let listAccumulator = [];
                let foundActive = null;

                for (const line of lines) {
                    const parts = line.split(":");
                    const ssidName = parts[2] ?? "";
                    if (!ssidName || ssidName.trim() === "") continue;

                    let netObj = {
                        active: parts[0] === "yes",
                        strength: parseInt(parts[1]) ?? 0,
                        ssid: ssidName
                    };

                    if (netObj.active) foundActive = netObj;
                    
                    // Deduplicate SSIDs so the menu stays clean
                    if (!listAccumulator.some(n => n.ssid === netObj.ssid)) {
                        listAccumulator.push(netObj);
                    }
                }
                
                root.activeNetwork = foundActive;
                // Sort by strength descending so best networks stay on top
                root.nearbyNetworks = listAccumulator.sort((a, b) => b.strength - a.strength);
            }
        }
    }

    // Global action method that components can invoke on click
    function connectToNetwork(ssid) {
        connectProc.command = ["nmcli", "d", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    Process { id: connectProc }

    Component.onCompleted: update()
}
