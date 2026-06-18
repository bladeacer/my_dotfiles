import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
  id: sysContainer
  // FIXED: Fill the full screen space provided by the parent PanelWindow track
  anchors.fill: parent

  // FIXED: Semi-transparent hybrid backdrop matching the Wifi style profiles
  color: Qt.rgba(Theme.bgHeader.r, Theme.bgHeader.g, Theme.bgHeader.b, 0.75)
  border.color: Theme.accentBlue
  border.width: 1

  property real currentVolume: 0.0
  property real currentBrightness: 0.0
  property string webcamStatus: "UNKNOWN"
  property string blueRoseText: ""
  property string confirmAction: ""

  // Blue rose art loader
  Process {
    id: roseReader
    command: ["bash", "-c", "cat \"$HOME/my_dotfiles/logo/blue_rose\" 2>/dev/null | head -16 || true"]
    running: true

    // FIXED: Changed onRead to onStreamFinished so the aggregated stream data is actually collected
    stdout: StdioCollector { 
      onStreamFinished: { 
        if (text && text.trim() !== "") {
          sysContainer.blueRoseText = ansi24ToHtml(text); 
        } 
      } 
    }
  }

  function ansi24ToHtml(input) {
    if (!input) return "";

    let lines = input.split("\n");
    let processedLines = [];

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (line.trim() === "") continue;

        // 1. Escape HTML constraints so the blocks map cleanly
        let safeStr = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

        // Keep track of active open tags on this specific line
        let hasOpenFont = false;

        // 2. Parse 24-bit Truecolor Sequences
        let ansi24Regex = /\x1b\[38[;:]2[;:](\d+)[;:](\d+)[;:](\d+)m/g;
        safeStr = safeStr.replace(ansi24Regex, function(match, r, g, b) {
            let hexR = parseInt(r).toString(16).padStart(2, '0');
            let hexG = parseInt(g).toString(16).padStart(2, '0');
            let hexB = parseInt(b).toString(16).padStart(2, '0');
            
            let prefix = hasOpenFont ? "</font>" : "";
            hasOpenFont = true; // State tracker active
            return `${prefix}<font color="#${hexR}${hexG}${hexB}">`;
        });

        // 3. Clear Terminal Resets
        let resetRegex = /\x1b\[0?m/g;
        safeStr = safeStr.replace(resetRegex, function() {
            if (hasOpenFont) {
                hasOpenFont = false;
                return "</font>";
            }
            return "";
        });

        // 4. Structural Safety Catch: Clean up any lingering open tags
        if (hasOpenFont) {
            safeStr += "</font>";
        }

        processedLines.push(safeStr);
    }

    // Join with strict break tags so QML interprets the array as structured HTML
    return processedLines.join("<br/>");
  }

  Process { id: readVol; command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]; running: true; stdout: SplitParser { onRead: (line) => { var v = parseFloat(line.trim()); if(!isNaN(v)) currentVolume = Math.min(v, 1.0); } } }
  Process { id: readBright; command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]; running: true; stdout: SplitParser { onRead: (line) => { var p = parseInt(line.trim()); if(!isNaN(p)) currentBrightness = Math.min(Math.max(p / 100.0, 0.0), 1.0); } } }
  Process { id: readWebcam; command: ["bash", "-c", "lsmod | grep -q uvcvideo && echo 'ACTIVE' || echo 'MUTED'"]; running: true; stdout: SplitParser { onRead: (line) => { webcamStatus = line.trim().toUpperCase(); } } }

  Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { readVol.running = false; readVol.running = true; readBright.running = false; readBright.running = true; readWebcam.running = false; readWebcam.running = true; } }

  Process { id: cmdToggleBt; command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"] }
  Process { id: cmdLogout; command: ["qdbus", "org.kde.Shutdown", "/Shutdown", "logout"] }
  Process { id: cmdReboot; command: ["systemctl", "reboot"] }
  Process { id: cmdPoweroff; command: ["systemctl", "poweroff"] }
  Process { id: cmdSleep; command: ["systemctl", "suspend"] }

  Process { id: volSet; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.5"]; onRunningChanged: if(!running) readVol.running = true }
  Process { id: brightSet; command: ["brightnessctl", "set", "50%"]; onRunningChanged: if(!running) readBright.running = true }
  Process { id: cmdToggleCam; command: ["bash", "-c", "lsmod | grep -q uvcvideo && pkexec modprobe -r uvcvideo || pkexec modprobe uvcvideo"]; onRunningChanged: if(!running) readWebcam.running = true }

  RowLayout {
    anchors.fill: parent; anchors.margins: 24; spacing: 24

    Rectangle {
      Layout.preferredWidth: 320; Layout.fillHeight: true
      color: Qt.rgba(0, 0, 0, 0.2)
      border.color: Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.25)
      border.width: 1
      clip: true

      Text {
        anchors.centerIn: parent

        // Use your parsed rich text variable, fallback to FontAwesome icon if empty
        text: sysContainer.blueRoseText !== "" ? sysContainer.blueRoseText : "\uf042"

        // CRITICAL: Instructs QML to render the parsed hex blocks natively
        textFormat: Text.RichText

        font.family: Theme.fontMono
        // Because truecolor art relies on half-blocks/full-blocks (▄/▀/█) mapping 
        // across lines, a small pixelSize combined with close line spacing matches 
        // your matrix perfectly without breaking font geometry.
        font.pixelSize: sysContainer.blueRoseText !== "" ? 7 : 24
        lineHeight: 0.8

        // Fallback color context if the file fails or is missing
        color: Theme.accentBlue
      }
    }

    // Right: Control parameters
    ColumnLayout {
      Layout.fillWidth: true; Layout.fillHeight: true; spacing: 14

      Text { text: "┌── [ HARDWARE_IO // CONTROL ] ────────────────────────────────────────┐"; font.family: Theme.fontMono; font.pixelSize: 13; color: Theme.accentBlue }

      // Toggle grid
      GridLayout {
        columns: 3; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: Theme.borderMain
          Text { anchors.centerIn: parent; text: "RF_LINK // BT_TOGGLE"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgNormal }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggleBt.running = false; cmdToggleBt.running = true; } }
        }
        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1;
          border.color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.borderMain
          Text { anchors.centerIn: parent; text: "OPTICAL // " + webcamStatus; font.family: Theme.fontMono; font.pixelSize: 11; color: webcamStatus === "ACTIVE" ? Theme.accentBlue : Theme.fgMuted }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggleCam.running = false; cmdToggleCam.running = true; } }
        }
        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: Theme.borderMain
          Text { anchors.centerIn: parent; text: "WIFI // SCAN"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
        }
      }

      // Volume scrub
      Text { text: "AUDIO_GAIN // [ " + Math.round(currentVolume * 100) + "% ]"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
      Rectangle {
        Layout.fillWidth: true; height: 16; color: Theme.borderMain
        Rectangle { width: parent.width * currentVolume; height: parent.height; color: Theme.accentBlue }
        MouseArea {
          anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onPressed: (mouse) => { var pct = Math.max(0, Math.min(1, mouse.x / width)); volSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct.toFixed(2)]; volSet.running = false; volSet.running = true; }
          onPositionChanged: (mouse) => { if (pressed) { var pct = Math.max(0, Math.min(1, mouse.x / width)); volSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct.toFixed(2)]; volSet.running = false; volSet.running = true; } }
        }
      }

      // Brightness scrub
      Text { text: "BACKLIGHT  // [ " + Math.round(currentBrightness * 100) + "% ]"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted }
      Rectangle {
        Layout.fillWidth: true; height: 16; color: Theme.borderMain
        Rectangle { width: parent.width * currentBrightness; height: parent.height; color: Theme.accentBlue }
        MouseArea {
          anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onPressed: (mouse) => { var pct = Math.max(0, Math.min(1, mouse.x / width)); brightSet.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"]; brightSet.running = false; brightSet.running = true; }
          onPositionChanged: (mouse) => { if (pressed) { var pct = Math.max(0, Math.min(1, mouse.x / width)); brightSet.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"]; brightSet.running = false; brightSet.running = true; } }
        }
      }

      Text { text: "┌── [ POWER_MGMT // SHUTDOWN_MATRIX ] ──────────────────────────────────┐"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }

      GridLayout {
        columns: 4; Layout.fillWidth: true; rowSpacing: 8; columnSpacing: 8

        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "KDE // LOGOUT"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sysContainer.confirmAction = "logout"; }
        }
        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "SYS // SLEEP"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sysContainer.confirmAction = "sleep"; }
        }
        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "SYS // REBOOT"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sysContainer.confirmAction = "reboot"; }
        }
        Rectangle {
          Layout.fillWidth: true; height: 46; color: "transparent"; border.width: 1; border.color: "#FF5555"
          Text { anchors.centerIn: parent; text: "SYS // HALT"; font.family: Theme.fontMono; font.pixelSize: 11; color: "#FF5555" }
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sysContainer.confirmAction = "poweroff"; }
        }
      }

      Item { Layout.fillHeight: true }
      Text { text: "└──────────────────────────────────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 11; color: Theme.fgMuted; Layout.fillWidth: true }
    }
  }

  // Confirmation overlay for power actions
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.8)
    visible: sysContainer.confirmAction !== ""

    ColumnLayout {
      anchors.centerIn: parent
      spacing: 20

      Text {
        text: "CONFIRM // " + (sysContainer.confirmAction || "").toUpperCase() + " ?"
        font.family: Theme.fontMono; font.pixelSize: 18; color: "#FF5555"
        Layout.alignment: Qt.AlignHCenter
      }

      // Action Row Matrix
      RowLayout {
        spacing: 24
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
          width: 140; height: 48; color: "transparent"
          border.width: 1; border.color: Theme.accentBlue
          Text { anchors.centerIn: parent; text: "[ Y ]  EXECUTE"; font.family: Theme.fontMono; font.pixelSize: 13; color: Theme.accentBlue }
          MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: {
              var cmd = sysContainer.confirmAction;
              sysContainer.confirmAction = "";
              if (cmd === "logout") { cmdLogout.running = false; cmdLogout.running = true; }
              else if (cmd === "sleep") { cmdSleep.running = false; cmdSleep.running = true; }
              else if (cmd === "reboot") { cmdReboot.running = false; cmdReboot.running = true; }
              else if (cmd === "poweroff") { cmdPoweroff.running = false; cmdPoweroff.running = true; }
            }
          }
        }

        Rectangle {
          width: 140; height: 48; color: "transparent"
          border.width: 1; border.color: Theme.fgMuted
          Text { anchors.centerIn: parent; text: "[ N ]  CANCEL"; font.family: Theme.fontMono; font.pixelSize: 13; color: Theme.fgMuted }
          MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: sysContainer.confirmAction = ""
          }
        }
      }
    }

    MouseArea { anchors.fill: parent; onClicked: sysContainer.confirmAction = "" }
  }
}
