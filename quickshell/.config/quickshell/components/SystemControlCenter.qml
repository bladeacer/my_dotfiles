import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
  id: sysContainer
  width: Math.min(900, parent ? parent.width - 40 : 900)
  height: Math.min(700, parent ? parent.height - 40 : 700)
  color: Theme.widgetBg
  border.color: Theme.accentBlue
  border.width: 1

  property real currentVolume: 0.0
  property real currentBrightness: 0.0
  property string webcamStatus: "UNKNOWN"
  property string blueRoseText: ""

  // Load blue rose art (strip ANSI, show braille text)
  Process {
    id: roseReader
    command: ["bash", "-c",
      "cat \"$HOME/my_dotfiles/logo/blue_rose\" 2>/dev/null | " +
      "sed 's/\\x1b\\[[0-9;]*m//g; s/\\x1b\\[[?0-9;]*[a-zA-Z]//g; s/\\x1b//g' | " +
      "sed '/^$/d' | head -15 || true"
    ]
    running: true
    stdout: StdioCollector {
      onRead: (data) => {
        if (data && data.trim() !== "") root.blueRoseText = data;
      }
    }
  }

  // Volume reader
  Process {
    id: readVol
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
    running: true
    stdout: SplitParser { onRead: (line) => { var v = parseFloat(line.trim()); if(!isNaN(v)) currentVolume = Math.min(v, 1.0); } }
  }

  // Brightness reader
  Process {
    id: readBright
    command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
    running: true
    stdout: SplitParser { onRead: (line) => { var p = parseInt(line.trim()); if(!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0); } }
  }

  Process {
    id: readWebcam
    command: ["bash", "-c", "lsmod | grep -q uvcvideo && echo 'ACTIVE' || echo 'MUTED'"]
    running: true
    stdout: SplitParser { onRead: (line) => { webcamStatus = line.trim().toUpperCase(); } }
  }

  Timer {
    interval: 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      readVol.running = false; readVol.running = true;
      readBright.running = false; readBright.running = true;
      readWebcam.running = false; readWebcam.running = true;
    }
  }

  Process { id: cmdToggleBt; command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"] }
  Process { id: cmdLogout; command: ["qdbus", "org.kde.Shutdown", "/Shutdown", "logout"] }
  Process { id: cmdReboot; command: ["systemctl", "reboot"] }
  Process { id: cmdPoweroff; command: ["systemctl", "poweroff"] }

  Process { id: volSet; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.5"]; onRunningChanged: if(!running) readVol.running = true }
  Process { id: brightSet; command: ["brightnessctl", "set", "50%"]; onRunningChanged: if(!running) readBright.running = true }
  Process { id: cmdToggleCam; command: ["bash", "-c", "lsmod | grep -q uvcvideo && pkexec modprobe -r uvcvideo || pkexec modprobe uvcvideo"]; onRunningChanged: if(!running) readWebcam.running = true }

  RowLayout {
    anchors.fill: parent; anchors.margins: 16; spacing: 16

    // Left: blue rose art
    Text {
      text: blueRoseText !== "" ? blueRoseText : ""
      font.family: Theme.fontMono; font.pixelSize: 5; lineHeight: 0.7
      color: Theme.accentBlue
      Layout.preferredWidth: 70; Layout.fillHeight: true
      clip: true; elide: Text.ElideNone; wrapMode: Text.NoWrap
    }

    // Right: control panels
    ColumnLayout {
      Layout.fillWidth: true; Layout.fillHeight: true; spacing: 10

      Text { text: "\u250c\u2500\u2500 [ HARDWARE_IO // CONTROL ] \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510"; font.family: Theme.fontMono; font.pixelSize: 13; color: Theme.accentBlue }

      // Toggle grid
      GridLayout {
        columns: 3; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1; border.color: Theme.borderMain
          Text { anchors.centerIn: parent; text: "RF_LINK // BT_TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 12; color: Theme.fgNormal }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggleBt.running = false; cmdToggleBt.running = true; } }
        }

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1;
          border.color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.borderMain
          Text {
            anchors.centerIn: parent; text: "OPTICAL // " + webcamStatus;
            font.family: Theme.fontMono; font.pixelSize: 12;
            color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.fgMuted
          }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggleCam.running = false; cmdToggleCam.running = true; } }
        }

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1; border.color: Theme.borderMain
          Text { anchors.centerIn: parent; text: "WIFI // SCAN"; font.family: Theme.fontMono; font.pixelSize: 12; color: Theme.fgMuted }
        }
      }

      // Volume scrub
      Text { text: "AUDIO_GAIN // [ " + Math.round(currentVolume * 100) + "% ]"; font.family: Theme.fontMono; font.pixelSize: 12; color: Theme.fgMuted }
      Rectangle {
        Layout.fillWidth: true; height: 16; color: Theme.borderMain
        Rectangle {
          width: parent.width * currentVolume; height: parent.height; color: Theme.accentBlue
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onPressed: (mouse) => { var pct = Math.max(0, Math.min(1, mouse.x / width)); volSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct.toFixed(2)]; volSet.running = false; volSet.running = true; }
          onPositionChanged: (mouse) => { if (pressed) { var pct = Math.max(0, Math.min(1, mouse.x / width)); volSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct.toFixed(2)]; volSet.running = false; volSet.running = true; } }
        }
      }

      // Brightness scrub
      Text { text: "BACKLIGHT  // [ " + Math.round(currentBrightness * 100) + "% ]"; font.family: Theme.fontMono; font.pixelSize: 12; color: Theme.fgMuted }
      Rectangle {
        Layout.fillWidth: true; height: 16; color: Theme.borderMain
        Rectangle {
          width: parent.width * currentBrightness; height: parent.height; color: Theme.accentBlue
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onPressed: (mouse) => { var pct = Math.max(0, Math.min(1, mouse.x / width)); brightSet.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"]; brightSet.running = false; brightSet.running = true; }
          onPositionChanged: (mouse) => { if (pressed) { var pct = Math.max(0, Math.min(1, mouse.x / width)); brightSet.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"]; brightSet.running = false; brightSet.running = true; } }
        }
      }

      Text { text: "\u250c\u2500\u2500 [ POWER_MGMT // SHUTDOWN_MATRIX ] \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510"; font.family: Theme.fontMono; font.pixelSize: 12; color: "#FF5555" }

      GridLayout {
        columns: 3; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "KDE // LOGOUT"; font.family: Theme.fontMono; font.pixelSize: 12; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdLogout.running = false; cmdLogout.running = true; } }
        }

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "SYS // REBOOT"; font.family: Theme.fontMono; font.pixelSize: 12; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdReboot.running = false; cmdReboot.running = true; } }
        }

        Rectangle {
          Layout.fillWidth: true; height: 44; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "SYS // HALT"; font.family: Theme.fontMono; font.pixelSize: 12; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdPoweroff.running = false; cmdPoweroff.running = true; } }
        }
      }

      Item { Layout.fillHeight: true }

      Text { text: "\u2514\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2518"; font.family: Theme.fontMono; font.pixelSize: 12; color: Theme.fgMuted }
    }
  }
}
