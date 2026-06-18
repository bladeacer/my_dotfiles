import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "components" as Components
import "theme"

ShellRoot {
  id: root

  // ── HOTKEY ROUTING MATRIX ──
  Shortcut { sequence: "Meta+Space"; onActivated: launcherLoader.active = !launcherLoader.active }
  Shortcut { sequence: "Meta+S"; onActivated: sysLoader.active = !sysLoader.active }

  // ── DATA TELEMETRY STORAGE ──
  property string currentTimestamp: "0000-00-00 // 00:00:00"
  property string mediaMetadata: "TRACK // IDLE"
  property string mediaStatus: "stopped"
  property string mediaArtUrl: ""
  property string batteryTelemetry: "BAT // --%"
  property string bluetoothTelemetry: "BT // DOWN"
  property string activeWifiSSID: "DISCONNECTED"
  property int wifiSignalStrength: 0
  property int mediaPosition: 0
  property int mediaLength: 1 // Guard division by zero errors

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
    stdout: SplitParser { onRead: (line) => { root.batteryTelemetry = line.trim() !== "" ? `BAT // ${line.trim()}%` : "BAT // --%"; } }
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
    // UPDATED: Added |{{ mpris:length }} to capture total media runtime boundaries
    command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}"]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        let segments = line.trim().split("|");
        if (segments.length >= 3 && segments[0] !== "") {
          root.mediaMetadata = segments[0].toUpperCase();
          root.mediaStatus = segments[1].toLowerCase();
          root.mediaArtUrl = segments[2] ? segments[2].replace("file://", "") : "";

          // NEW: Parse out the 4th token parameter, convert microseconds to standard total track seconds
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
          root.mediaLength = 1; // Fallback reset
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
    anchors { top: true; left: true; right: true }
    implicitHeight: 26
    color: Theme.widgetBg

    RowLayout {
      anchors.fill: parent; spacing: 0

      RowLayout {
        Layout.preferredWidth: parent.width * 0.25
        Layout.fillHeight: true; spacing: 10; Layout.leftMargin: 12
        Text { text: "NAVI_OS"; font.family: Theme.fontMono; font.pixelSize: 10; font.bold: true; color: Theme.accentBlue }
        Components.TaskTracker { Layout.fillHeight: true }
      }

      Item {
        Layout.preferredWidth: parent.width * 0.40
        Layout.fillHeight: true; clip: true
        MouseArea {
          anchors.fill: parent
          Text {
            anchors.centerIn: parent; text: root.mediaMetadata
            font.family: Theme.fontMono; font.pixelSize: 10
            color: root.mediaMetadata.includes("IDLE") ? Theme.fgMuted : Theme.accentBlue
            elide: Text.ElideRight; width: Math.min(implicitWidth, parent.width - 10)
          }
          onClicked: mediaHUDLoader.active = !mediaHUDLoader.active
        }
      }

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

  // ── INLINE INJECTED POPUP COMPONENT DEFINITION ──
  // This removes the need for an external file and resolves the missing type error safely
  component LocalInlinePopup : PanelWindow {
    id: popupWindow
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool active: false
    property bool center: true // Set this to true for centered popups, false for tray menus
    property int targetX: 0
    property int targetY: 32   
    default property alias content: container.children

    FocusScope {
      anchors.fill: parent
      focus: popupWindow.active

      Keys.onEscapePressed: popupWindow.active = false
      MouseArea { anchors.fill: parent; onClicked: popupWindow.active = false }

      // This item acts as the positioning anchor space
      Item {
        id: container
        y: popupWindow.targetY

        // Dynamic declarative width tracking of the loaded sub-widget
        width: children.length > 0 ? (children[0].width > 0 ? children[0].width : children[0].implicitWidth) : 0
        height: children.length > 0 ? (children[0].height > 0 ? children[0].height : children[0].implicitHeight) : 0

        // PERFECT CENTERING: Anchors horizontally to the parent window layout
        anchors.horizontalCenter: popupWindow.center ? parent.horizontalCenter : undefined

        // Fallback to manual X placement only if center mode is disabled
        x: popupWindow.center ? 0 : popupWindow.targetX

        MouseArea { anchors.fill: parent; propagateComposedEvents: false }
      }
    }
  }

  // ── MODAL POPUP LAYER COMPONENT LOADERS ──
  Loader { id: mediaHUDLoader; active: false; sourceComponent: mediaComp }
  Component { id: mediaComp; Components.MediaHUD {} }

  Loader { id: launcherLoader; active: false; sourceComponent: launchComp }
  Component {
    id: launchComp
    // Launcher keeps center: true to lock to the terminal workspace center lines
    LocalInlinePopup { 
      active: launcherLoader.active 
      center: true 
      onActiveChanged: launcherLoader.active = active 
      targetY: (root.height - 500) / 2 
      Components.Launcher {} 
    }
  }

  Loader { id: btLoader; active: false; sourceComponent: btComp }
  Component {
    id: btComp
    // Changed center to false so it drops into your system tray anchor bounds safely
    LocalInlinePopup { 
      active: btLoader.active 
      center: false 
      onActiveChanged: btLoader.active = active 
      targetX: root.width - 312 // Corrected from root.width to keep inside screen frame
      Components.BluetoothControlCenter { width: 300; height: 350 } 
    }
  }

  Loader { id: wifiLoader; active: false; sourceComponent: wifiComp }
  Component {
    id: wifiComp
    LocalInlinePopup { 
      active: wifiLoader.active 
      onActiveChanged: wifiLoader.active = active 
      center: false // Dropped center mode so it aligns perfectly underneath the wifi tray icon
      targetX: root.width - 412 // Adjusted for the 400px panel layout width + edge gap

      Components.WifiWidget { width: 400 } 
    }
  }

  Loader { id: sysLoader; active: false; sourceComponent: sysComp }
  Component {
    id: sysComp
    LocalInlinePopup { 
      active: sysLoader.active 
      center: false // Disabled centering mode
      onActiveChanged: sysLoader.active = active 
      targetX: root.width - 332 
      Components.SystemControlCenter { width: 320; height: 400 } 
    }
  } 
}
