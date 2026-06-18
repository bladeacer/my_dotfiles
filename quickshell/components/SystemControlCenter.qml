import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: sysContainer
    implicitWidth: 320
    implicitHeight: 400
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: 1

    // ── VOLATILE TELEMETRY STORAGE ──
    property real currentVolume: 0.0
    property real currentBrightness: 0.0
    property string webcamStatus: "UNKNOWN"

    // ── SYSTEM READ PIPES (POLLING DATA ENGINES) ──
    Process {
        id: readVol
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        running: true
        stdout: SplitParser { onRead: (line) => { let v = parseFloat(line.trim()); if(!isNaN(v)) currentVolume = Math.min(v, 1.0); } }
    }

    // FIX: Scrapes machine-readable brightness percentages directly inside a clean shell pipe
    Process {
        id: readBright
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: SplitParser { 
            onRead: (line) => { 
                let p = parseInt(line.trim()); 
                if(!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0); 
            } 
        }
    }

    Process {
        id: readWebcam
        command: ["bash", "-c", "lsmod | grep -q uvcvideo && echo 'ACTIVE' || echo 'MUTED'"]
        running: true
        stdout: SplitParser { onRead: (line) => { webcamStatus = line.trim().toUpperCase(); } }
    }

    // Refresh telemetry bounds every 1000ms
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            readVol.running = false; readVol.running = true;
            readBright.running = false; readBright.running = true;
            readWebcam.running = false; readWebcam.running = true;
        }
    }

    // ── SYSTEM CONTROL ACTIONS (WRITE COMMANDS) ──
    Process { id: cmdToggleBt; command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"] }
    Process { id: cmdLogout; command: ["qdbus", "org.kde.ksmserver", "/KSMServer", "logout", "0", "0", "0"] }
    Process { id: cmdReboot; command: ["systemctl", "reboot"] }
    Process { id: cmdPoweroff; command: ["systemctl", "poweroff"] }

    // Audio Exec Engines
    Process { id: volUp; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]; onRunningChanged: if(!running) readVol.running = true }
    Process { id: volDown; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]; onRunningChanged: if(!running) readVol.running = true }

    // Brightness Exec Engines
    Process { id: brightUp; command: ["brightnessctl", "set", "+10%"]; onRunningChanged: if(!running) readBright.running = true }
    Process { id: brightDown; command: ["brightnessctl", "set", "10%-"]; onRunningChanged: if(!running) readBright.running = true }

    // Webcam Kernel Shutter Modifier
    Process { id: cmdToggleCam; command: ["bash", "-c", "lsmod | grep -q uvcvideo && pkexec modprobe -r uvcvideo || pkexec modprobe uvcvideo"]; onRunningChanged: if(!running) readWebcam.running = true }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text { text: "┌── [ HARDWARE_IO // CONTROL ] ────"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.accentBlue }

        GridLayout {
            columns: 2; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

            // Bluetooth
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: Theme.borderMain
                Text { anchors.centerIn: parent; text: "RF_LINK // BT_TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggleBt.running = false; cmdToggleBt.running = true; } }
            }
            
            // Interactive Webcam Node
            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; 
                border.color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.borderMain
                Text { 
                    anchors.centerIn: parent; 
                    text: `OPTICAL // ${webcamStatus}`; 
                    font.family: Theme.fontMono; font.pixelSize: 9; 
                    color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.fgMuted 
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { cmdToggleCam.running = false; cmdToggleCam.running = true; }
                }
            }
        }

        Item { height: 2 }
        Text { text: "┌── [ POWER_MGMT // SHUTDOWN_MATRIX ]"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }

        GridLayout {
            columns: 3; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: "#FF5555"
                Text { anchors.centerIn: parent; text: "KDE // LOGOUT"; font.family: Theme.fontMono; font.pixelSize: 9; color: "#FF5555" }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdLogout.running = false; cmdLogout.running = true; } }
            }

            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: "#FF5555"
                Text { anchors.centerIn: parent; text: "SYS // REBOOT"; font.family: Theme.fontMono; font.pixelSize: 9; color: "#FF5555" }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdReboot.running = false; cmdReboot.running = true; } }
            }

            Rectangle {
                Layout.fillWidth: true; height: 36; color: "transparent"; border.width: 1; border.color: "#FF5555"
                Text { anchors.centerIn: parent; text: "SYS // HALT"; font.family: Theme.fontMono; font.pixelSize: 9; color: "#FF5555" }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdPoweroff.running = false; cmdPoweroff.running = true; } }
            }
        }

        Item { height: 4 }

        // Live Telemetry Gauges Layer
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // Audio Level Control Strip
            Text { text: `AUDIO_GAIN // [ ${Math.round(currentVolume * 100)}% ]`; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            Rectangle { 
                Layout.fillWidth: true; height: 12; color: Theme.borderMain
                Rectangle { width: parent.width * currentVolume; height: parent.height; color: Theme.accentBlue } 
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => { if(mouse.x > width/2) { volUp.running = false; volUp.running = true; } else { volDown.running = false; volDown.running = true; } }
                    onWheel: (wheel) => { if(wheel.angleDelta.y > 0) { volUp.running = false; volUp.running = true; } else { volDown.running = false; volDown.running = true; } }
                }
            }

            Item { height: 2 }

            // Backlight Level Control Strip
            Text { text: `BACKLIGHT  // [ ${Math.round(currentBrightness * 100)}% ]`; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
            Rectangle { 
                Layout.fillWidth: true; height: 12; color: Theme.borderMain
                Rectangle { width: parent.width * currentBrightness; height: parent.height; color: Theme.accentBlue } 
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => { if(mouse.x > width/2) { brightUp.running = false; brightUp.running = true; } else { brightDown.running = false; brightDown.running = true; } }
                    onWheel: (wheel) => { if(wheel.angleDelta.y > 0) { brightUp.running = false; brightUp.running = true; } else { brightDown.running = false; brightDown.running = true; } }
                }
            }
        }

        Item { Layout.fillHeight: true }
        Text { text: "└────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
    }
}
