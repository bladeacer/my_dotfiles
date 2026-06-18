import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
  id: compRoot
  color: Theme.widgetBg
  border.color: Theme.accentBlue
  border.width: 1

  // ── INTERNAL TELEMETRY MATRIX ──
  property var parsedDevices: []
  property string accumulatedRaw: ""
  property int spinIndex: 0
  readonly property var spinChars: ["—", "\\", "│", "/"]

  Timer {
    interval: 250; running: true; repeat: true
    onTriggered: compRoot.spinIndex = (compRoot.spinIndex + 1) % 4
  }

  // Optimized background script pipeline
  Process {
    id: btDevicesPipe
    command: ["bash", "-c", "bluetoothctl devices Paired | while read -r line; do mac=$(echo \"$line\" | cut -d' ' -f2); name=$(echo \"$line\" | cut -d' ' -f3-); info=$(bluetoothctl info \"$mac\"); if echo \"$info\" | grep -q \"Connected: yes\"; then type=\"UNKNOWN\"; echo \"$info\" | grep -q \"Icon: audio\" && type=\"AUDIO\"; echo \"$info\" | grep -q \"Icon: input\" && type=\"INPUT\"; echo \"CONNECTED|$name|$mac|$type\"; else echo \"DISCONNECTED|$name|$mac|--\"; fi; done"]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        if (line.trim() !== "") {
          compRoot.accumulatedRaw += line.trim() + "\n";
        }
      }
    }
    onRunningChanged: {
      if (!running) {
        // Atomic commit avoids destroying Repeater children mid-stream
        let lines = compRoot.accumulatedRaw.trim().split("\n");
        let validDevices = [];
        for (let i = 0; i < lines.length; i++) {
          if (lines[i].trim() !== "") {
            validDevices.push(lines[i].trim());
          }
        }
        compRoot.parsedDevices = validDevices;
      }
    }
  }

  // Query Refresher
  Timer {
    interval: 3000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      compRoot.accumulatedRaw = "";
      btDevicesPipe.running = false;
      btDevicesPipe.running = true;
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      Text {
        text: `┌── [ BT_MANAGER // SCAN_${compRoot.spinChars[compRoot.spinIndex]} ]`
        font.family: Theme.fontMono
        font.pixelSize: 10
        color: Theme.accentBlue
      }
    }

    Flickable {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      contentWidth: deviceColumn.implicitWidth
      contentHeight: deviceColumn.implicitHeight
      flickableDirection: Flickable.VerticalFlick

      ColumnLayout {
        id: deviceColumn
        spacing: 6
        width: compRoot.width - 28

        Repeater {
          model: compRoot.parsedDevices

          delegate: RowLayout {
            Layout.fillWidth: true
            
            readonly property var parts: modelData.split("|")
            readonly property bool isConnected: parts[0] === "CONNECTED"
            readonly property string devName: parts[1] ?? "UNKNOWN"
            readonly property string devMac: parts[2] ?? "00:00:00:00:00:00"
            readonly property string devType: parts[3] ?? "--"

            Text {
              text: isConnected ? ` [*] [${devType}] ${devName}` : ` [ ] [--] ${devName}`
              font.family: Theme.fontMono
              font.pixelSize: 10
              color: isConnected ? Theme.accentBlue : Theme.fgMuted
              Layout.fillWidth: true
              elide: Text.ElideRight
            }

            Text {
              text: isConnected ? "[ DISCONNECT ]" : "[ CONNECT ]"
              font.family: Theme.fontMono
              font.pixelSize: 9
              color: isConnected ? Theme.borderMain : Theme.accentBlue

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  let action = isConnected ? "disconnect" : "connect";
                  let p = Quickshell.createProcess(["bluetoothctl", action, devMac]);
                  p.running = true;
                }
              }
            }
          }
        }
      }
    }

    // ── FOOTER MATRIX OPERATIONS ──
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4

      Text {
        text: "├────────────────────────────────────────┤"
        font.family: Theme.fontMono
        font.pixelSize: 10
        color: Theme.fgMuted
      }
      
      RowLayout {
        Text {
          text: "  [ DISCONNECT ALL TERMINALS ]"
          font.family: Theme.fontMono
          font.pixelSize: 10
          color: Theme.accentBlue

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              let p = Quickshell.createProcess(["bash", "-c", "bluetoothctl devices Paired | cut -d' ' -f2 | xargs -I{} bluetoothctl disconnect {}"]);
              p.running = true;
            }
          }
        }
      }
      
      Text {
        text: "└────────────────────────────────────────┘"
        font.family: Theme.fontMono
        font.pixelSize: 10
        color: Theme.fgMuted
      }
    }
  }
}
