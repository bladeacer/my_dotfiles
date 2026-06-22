pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property bool connected: false
    property string activeSSID: "DISCONNECTED"
    property int activeStrength: 0
    property var nearbyNetworks: []
    property string _rawBuffer: ""

    Process {
        id: activeScan
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'no:disconnected:0'"]
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(":")
                if (parts.length < 3) return
                if (parts[0] === "yes") {
                    connected = true
                    activeSSID = (parts[1] || "").toUpperCase()
                    activeStrength = parseInt(parts[2]) || 0
                } else {
                    connected = false
                    activeSSID = "DISCONNECTED"
                    activeStrength = 0
                }
            }
        }
    }

    Process {
        id: listScan
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | head -30"]
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "") return
                _rawBuffer += line.trim() + "\n"
            }
        }
        onRunningChanged: {
            if (!running && _rawBuffer !== "") {
                var lines = _rawBuffer.trim().split("\n")
                var nets = []
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].split(":")
                    if (p.length >= 2 && p[0]) {
                        var sec = p.length >= 3 ? p[2] : ""
                        nets.push({ ssid: p[0], strength: parseInt(p[1]) || 0, security: sec })
                    }
                }
                nearbyNetworks = nets
                _rawBuffer = ""
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { activeScan.running = false; activeScan.running = true }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { listScan.running = false; listScan.running = true }
    }

    function updateActiveData(ssid, strength) {
        connected = ssid !== "DISCONNECTED" && ssid !== ""
        activeSSID = ssid
        activeStrength = strength || 0
    }

    function refreshScan() {
        listScan.running = false
        listScan.running = true
    }

    function connectToNetwork(ssid) {
        var p = Quickshell.createProcess(["nmcli", "dev", "wifi", "connect", ssid])
        p.running = true
    }

    function disconnect() {
        var p = Quickshell.createProcess(["nmcli", "dev", "disconnect", "wifi"])
        p.running = true
    }
}
