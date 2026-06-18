import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "components" as Components
import "services" as Services
import "theme"

ShellRoot {
  id: root

  Process {
    id: ipcReader
    command: ["bash", "-c", "mkdir -p /tmp/quickshell && [ ! -p /tmp/quickshell/ipc ] && mkfifo /tmp/quickshell/ipc; exec tail -f /tmp/quickshell/ipc"]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        let action = line.trim().toLowerCase();
        if (action === "toggle-launcher") {
          launcherLoader.active = !launcherLoader.active;
        } else if (action === "toggle-syscontrol") {
          sysLoader.active = !sysLoader.active;
        }
      }
    }
  }

  // ── HOTKEY ROUTING MATRIX ──
  Shortcut { sequence: "Meta+Space"; onActivated: launcherLoader.active = !launcherLoader.active }
  Shortcut { sequence: "Meta+S"; onActivated: sysLoader.active = !sysLoader.active }
  Shortcut { sequence: "Escape"; onActivated: closeAllPopups() }

  function closeAllPopups() {
    launcherLoader.active = false;
    btLoader.active = false;
    wifiLoader.active = false;
    sysLoader.active = false;
    mediaHUDLoader.active = false;
  }

  // ── DATA TELEMETRY STORAGE ──
  property string currentTimestamp: "0000-00-00 // 00:00:00"
  property string mediaMetadata: "TRACK // IDLE"
  property string mediaStatus: "stopped"
  property string mediaArtUrl: ""
  property string batteryTelemetry: "BAT // --%"
  property int batteryCapacity: 0
  property string bluetoothTelemetry: "BT // DOWN"
  property string activeWifiSSID: "DISCONNECTED"
  property int wifiSignalStrength: 0
  property int mediaPosition: 0
  property int mediaLength: 1 

  // Network Telemetry Engine
  Process {
    id: wifiPipe
    command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'NO:DISCONNECTED:0'"]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        let segments = line.trim().split(":");
        if (segments.length >= 3 && segments[0] === "yes") {
          root.activeWifiSSID = segments[1].toUpperCase();
          root.wifiSignalStrength = parseInt(segments[2]);
        } else {
          root.activeWifiSSID = "DISCONNECTED";
          root.wifiSignalStrength = 0;
        }
      }
    }
  }

  // High frequency position tracker pipe
  Process {
    id: mediaPosPipe
    command: ["playerctl", "position"]
    running: true
    stdout: SplitParser { 
      onRead: (line) => { 
        let p = parseFloat(line.trim());
        if(!isNaN(p)) root.mediaPosition = Math.round(p);
      } 
    }
  }

  // Unified Date & Time Formatter Engine
  Timer {
    interval: 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      let d = new Date();
      let pad = (n) => n.toString().padStart(2, '0');
      root.currentTimestamp = `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} // ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
      mediaPosPipe.running = false; mediaPosPipe.running = true;
    }
  }

  // Battery Node Tracker
  Process {
    id: batPipe
    command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
    running: true
    stdout: SplitParser { onRead: (line) => { var c = parseInt(line.trim()); if (!isNaN(c)) root.batteryCapacity = c; root.batteryTelemetry = line.trim() !== "" ? `BAT // ${line.trim()}%` : "BAT // --%"; } }
  }

  // Bluetooth Link State Tracker
  Process {
    id: btPipe
    command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'UP' || echo 'DOWN'"]
    running: true
    stdout: SplitParser { onRead: (line) => { root.bluetoothTelemetry = `BT // ${line.trim().toUpperCase()}`; } }
  }

  // Complete Multi-Field Media Engine
  Process {
    id: mediaPipe
    command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}"]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        let segments = line.trim().split("|");
        if (segments.length >= 3 && segments[0] !== "") {
          root.mediaMetadata = segments[0].toUpperCase();
          root.mediaStatus = segments[1].toLowerCase();
          root.mediaArtUrl = segments[2] ? segments[2].replace("file://", "") : "";

          if (segments.length >= 4 && segments[3]) {
            let rawLength = parseInt(segments[3]);
            root.mediaLength = (!isNaN(rawLength) && rawLength > 0) ? Math.round(rawLength / 1000000) : 1;
          } else {
            root.mediaLength = 1;
          }
        } else {
          root.mediaMetadata = "TRACK // IDLE";
          root.mediaStatus = "stopped";
          root.mediaArtUrl = "";
          root.mediaLength = 1; 
        }
      }
    }
  } 

  Timer {
    interval: 2000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      batPipe.running = false; batPipe.running = true;
      btPipe.running = false; btPipe.running = true;
      wifiPipe.running = false; wifiPipe.running = true;
      mediaPipe.running = false; mediaPipe.running = true;
    }
  }

  // ── MAIN PANEL DESKTOP BAR ──
  PanelWindow {
    id: statusBar
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.focusable: WlrKeyboardFocus.None
    anchors { top: true; left: true; right: true }
    implicitHeight: 28
    color: Theme.widgetBg

    RowLayout {
      anchors.fill: parent; spacing: 0

      // Left: logo + task tracker + focused window
      RowLayout {
        Layout.preferredWidth: parent.width * 0.35
        Layout.fillHeight: true; spacing: 8; Layout.leftMargin: 12; clip: true

        Text {
          text: "NAVI_OS"
          font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true
          color: Theme.accentBlue
        }

        Components.TaskTracker { Layout.fillHeight: true }

        Text {
          text: Services.FocusedWindow.title !== ""
          ? "[" + Services.FocusedWindow.title.substring(0, 24) + "]"
          : ""
          font.family: Theme.fontMono; font.pixelSize: 8
          color: Theme.fgMuted
          elide: Text.ElideRight
          visible: Services.FocusedWindow.title !== ""
        }
      }

      // Center: media metadata (clickable)
      Item {
        Layout.preferredWidth: parent.width * 0.30
        Layout.fillHeight: true; clip: true
        MouseArea {
          anchors.fill: parent
          Text {
            anchors.centerIn: parent; text: root.mediaMetadata
            font.family: Theme.fontMono; font.pixelSize: 9
            color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.accentBlue
            elide: Text.ElideRight; width: Math.min(implicitWidth, parent.width - 10)
          }
          onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
        }
      }

      // Right: status indicators
      Components.StatusRight {
        Layout.preferredWidth: parent.width * 0.35
        Layout.fillHeight: true; Layout.rightMargin: 12

        onBtClicked: {
          let target = !btLoader.active;
          wifiLoader.active = false;
          sysLoader.active = false;
          btLoader.active = target;
        }

        onWifiCtrlClicked: {
          let target = !wifiLoader.active;
          btLoader.active = false;
          sysLoader.active = false;
          wifiLoader.active = target;
        }

        onSysClicked: {
          let target = !sysLoader.active;
          btLoader.active = false;
          wifiLoader.active = false;
          sysLoader.active = target;
        }
      }
    }
  }

  // ── PANEL WINDOW OVERLAYS ──

  Loader { 
    id: mediaHUDLoader; 
    active: false; 
    sourceComponent: mediaHUDExclusiveComp 
  }

  Component {
    id: mediaHUDExclusiveComp

    PanelWindow {
      id: exclusiveHUDWin
      // Fix: Use correct modern Wayland protocol specifications instead of mixed enums
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.namespace: "exclusive_hud"
      
      anchors { top: true; left: true; right: true }
      margins.top: 28 // Render precisely below status bar track bounds
      implicitHeight: 135 
      color: "transparent"

      Components.MediaHUD {
        anchors.fill: parent
      }
    }
  }

  Loader { id: launcherLoader; active: false; sourceComponent: launchComp }
  Component {
    id: launchComp
    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      
      // FIX: Standardize layout positioning flags for Quickshell
      anchors.top: true 
      margins.top: 32
      
      implicitWidth: 560
      implicitHeight: 400
      color: "transparent"

      Rectangle {
        anchors.fill: parent
        color: Theme.widgetBg
        border.color: Theme.accentBlue; border.width: 1

        Components.Launcher { 
          anchors.fill: parent 
          onCloseRequested: launcherLoader.active = false 
        }
      }
    }
  }

  Loader { id: btLoader; active: false; sourceComponent: btComp }
  Component {
    id: btComp
    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      anchors { top: true; right: true }
      margins.top: 32
      margins.right: 120
      implicitWidth: 300
      implicitHeight: 350
      color: "transparent"

      Rectangle {
        anchors.fill: parent; color: Theme.widgetBg
        border.color: Theme.accentBlue; border.width: 1
        Components.BluetoothControlCenter { anchors.fill: parent }
      }
    }
  }

  Loader { id: wifiLoader; active: false; sourceComponent: wifiComp }
  Component {
    id: wifiComp
    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      anchors { top: true; right: true }
      margins.top: 32
      margins.right: 60
      implicitWidth: 400
      implicitHeight: 500
      color: "transparent"

      Rectangle {
        anchors.fill: parent; color: Theme.widgetBg
        border.color: Theme.accentBlue; border.width: 1
        Components.WifiWidget { anchors.fill: parent }
      }
    }
  }

  Loader { id: sysLoader; active: false; sourceComponent: sysComp }
  Component {
    id: sysComp
    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      
      // FIX: Safe top-bound anchor with explicit width mapping. 
      // Wayland centers windows with a fixed width automatically when left/right anchors are omitted.
      anchors.top: true
      margins.top: 32
      
      implicitWidth: 960
      implicitHeight: 740
      color: "transparent"

      Components.SystemControlCenter { 
        anchors.fill: parent
      }
    }
  }
}
