pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool connected: false
    property string activeSSID: "DISCONNECTED"
    property int activeStrength: 0
    property var nearbyNetworks: []
    property string _rawBuffer: ""
    property int refreshPending: 0
    property string connectTarget: ""
    property int connectPending: 0
    property bool scanning: false
    property bool connecting: false

    // ── Fast active connection check ──
    Process {
        id: activeScan
        command: ["bash", "-c",
            "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'no:disconnected:0'"]
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

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { activeScan.running = false; activeScan.running = true }
    }

    // ── Network list scan ──
    Process {
        id: listScan
        command: ["bash", "-c",
            "LC_ALL=C nmcli -t -f ACTIVE,SIGNAL,SSID,SECURITY dev wifi list 2>/dev/null | head -30"]
        onRunningChanged: { scanning = running }
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "") return
                _rawBuffer += line.trim() + "\n"
            }
        }
        onExited: (exitCode) => {
            if (_rawBuffer === "") return
            var PLACEHOLDER = "\x00COLON\x00"
            var lines = _rawBuffer.trim().split("\n")
            var nets = []
            var foundActive = false
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].replace(/\\:/g, PLACEHOLDER)
                var p = line.split(":")
                if (p.length >= 3 && p[2]) {
                    var ssid = p[2].replace(new RegExp(PLACEHOLDER, "g"), ":")
                    var strength = parseInt(p[1]) || 0
                    var isActive = p[0] === "yes"
                    var sec = p.length >= 4 ? p[3].replace(new RegExp(PLACEHOLDER, "g"), ":") : ""
                    nets.push({ ssid: ssid, strength: strength, security: sec, active: isActive })
                    if (isActive) foundActive = true
                }
            }
            if (foundActive) {
                var activeNet = nets.find(function(n) { return n.active })
                if (activeNet) {
                    connected = true
                    activeSSID = activeNet.ssid.toUpperCase()
                    activeStrength = activeNet.strength
                }
            }
            nearbyNetworks = nets
            _rawBuffer = ""
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { listScan.running = false; listScan.running = true }
    }

    // Property trigger — set from outside (e.g. WifiWidget refresh button)
    onRefreshPendingChanged: {
        if (refreshPending > 0) {
            _rawBuffer = ""
            listScan.running = false
            listScan.running = true
            refreshPending = 0
        }
    }

    // ── Connect process ──
    Process {
        id: connectProcess
        command: []
        running: false
        onRunningChanged: { if (!running) connecting = false }
    }

    // ── Connection trigger ──
    onConnectPendingChanged: {
        if (connectPending > 0 && connectTarget !== "") {
            connectProcess.command = ["bash", "-c", "nmcli dev wifi connect \"" + connectTarget.replace(/"/g, "\\\"") + "\""]
            connectProcess.running = false
            connectProcess.running = true
            connecting = true
            connectPending = 0
        }
    }
}
