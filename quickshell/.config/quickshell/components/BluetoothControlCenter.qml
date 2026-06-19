import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: btRoot
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    property var parsedDevices: []
    property string accumulatedRaw: ""
    property int spinIndex: 0

    signal closeRequested()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true }
    }
    readonly property var spinChars: ["\u2014", "\\", "\u2502", "/"]

    Timer {
        interval: 250; running: true; repeat: true
        onTriggered: btRoot.spinIndex = (btRoot.spinIndex + 1) % 4
    }

    Process {
        id: btDevicesPipe
        command: ["bash", "-c", "bluetoothctl devices Paired | while read -r line; do mac=$(echo \"$line\" | cut -d' ' -f2); name=$(echo \"$line\" | cut -d' ' -f3-); info=$(bluetoothctl info \"$mac\"); if echo \"$info\" | grep -q \"Connected: yes\"; then type=\"UNKNOWN\"; echo \"$info\" | grep -q \"Icon: audio\" && type=\"AUDIO\"; echo \"$info\" | grep -q \"Icon: input\" && type=\"INPUT\"; echo \"CONNECTED|$name|$mac|$type\"; else echo \"DISCONNECTED|$name|$mac|--\"; fi; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "") accumulatedRaw += line.trim() + "\n"
            }
        }
        onRunningChanged: {
            if (!running) {
                var lines = accumulatedRaw.trim().split("\n")
                var valid = []
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].trim() !== "") valid.push(lines[i].trim())
                }
                parsedDevices = valid
            }
        }
    }

    Process { id: btCtl }

    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { accumulatedRaw = ""; btDevicesPipe.running = false; btDevicesPipe.running = true }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 14; spacing: 8

        Text {
            text: Theme.frameHeader("BT_MANAGER // SCAN_" + btRoot.spinChars[btRoot.spinIndex])
            color: Theme.accentBlue
            font.family: Theme.fontMono; font.pixelSize: Theme.textMd
        }

        Flickable {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            contentWidth: devCol.implicitWidth; contentHeight: devCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: devCol
                spacing: 6
                width: btRoot.width - 28

                Repeater {
                    model: btRoot.parsedDevices

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        readonly property var parts: modelData.split("|")
                        readonly property bool isConnected: parts[0] === "CONNECTED"
                        readonly property string devName: parts[1] ?? "UNKNOWN"
                        readonly property string devMac: parts[2] ?? "00:00:00:00:00:00"
                        readonly property string devType: parts[3] ?? "--"

                        Text {
                            text: (isConnected ? "[*]" : "[ ]") + " [" + devType + "] " + devName
                            font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                            color: isConnected ? Theme.accentBlue : Theme.fgMuted
                            Layout.fillWidth: true; elide: Text.ElideRight
                        }

                        Text {
                            text: isConnected ? "[DISCONNECT]" : "[CONNECT]"
                            font.family: Theme.fontMono; font.pixelSize: Theme.textSm
                            color: isConnected ? Theme.borderMain : Theme.accentBlue
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var action = isConnected ? "disconnect" : "connect"
                                    btCtl.command = ["bluetoothctl", action, devMac]
                                    btCtl.running = true
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text {
                text: "   [DISCONNECT ALL]"
                font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.accentBlue
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        btCtl.command = ["bash", "-c", "bluetoothctl devices Paired | cut -d' ' -f2 | xargs -I{} bluetoothctl disconnect {}"]
                        btCtl.running = true
                    }
                }
            }
            Text {
                text: Theme.frameFooter()
                font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgMuted
            }
        }
    }
}
