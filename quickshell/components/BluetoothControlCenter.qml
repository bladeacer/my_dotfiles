import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: compRoot
    anchors.fill: parent
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: 1

    signal onCloseRequested()

    property string deviceListRaw: ""
    
    Process {
        id: btDevicesPipe
        command: ["bash", "-c", "bluetoothctl devices Paired | while read -r line; do mac=$(echo \"$line\" | cut -d' ' -f2); name=$(echo \"$line\" | cut -d' ' -f3-); info=$(bluetoothctl info \"$mac\"); if echo \"$info\" | grep -q \"Connected: yes\"; then echo \"[*] $name ($mac)\"; else echo \"[ ] $name ($mac)\"; fi; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() !== "") {
                    compRoot.deviceListRaw += "  " + line.trim() + "\n";
                }
            }
        }
    }

    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            compRoot.deviceListRaw = "";
            btDevicesPipe.running = false;
            btDevicesPipe.running = true;
        }
    }

    // Modal Background Click Dismissal Handler
    MouseArea {
        anchors.fill: parent
        onClicked: compRoot.onCloseRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // Prevent layout clicks from bubbling up to dismissal backdrop
        MouseArea {
            Layout.fillWidth: true; Layout.fillHeight: true
            propagateComposedEvents: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // Header Frame
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "┌── [ BT_NODE_MANAGER // LINK_STATE ]"
                        font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "[X]"
                        font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted
                        MouseArea {
                            anchors.fill: parent
                            onClicked: compRoot.onCloseRequested()
                        }
                    }
                }

                // FIX: Native Flickable text viewport container replacing ScrollView
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: deviceText.implicitWidth
                    contentHeight: deviceText.implicitHeight
                    flickableDirection: Flickable.VerticalFlick

                    Text {
                        id: deviceText
                        text: compRoot.deviceListRaw !== "" ? compRoot.deviceListRaw : "  NO PAIRED TELEMETRY FOUND"
                        font.family: Theme.fontMono; font.pixelSize: 10
                        color: Theme.fgNormal
                        lineHeight: 1.4
                    }
                }

                // Footer Control Unit Matrix
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "├────────────────────────────────────────┤"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
                    RowLayout {
                        spacing: 16
                        Text {
                            text: "  [ DISCONNECT ALL ]"
                            font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    let p = Quickshell.createProcess(["bash", "-c", "bluetoothctl devices Paired | cut -d' ' -f2 | xargs -I{} bluetoothctl disconnect {}"]);
                                    p.running = true;
                                }
                            }
                        }
                    }
                    Text { text: "└────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
                }
            }
        }
    }
}
