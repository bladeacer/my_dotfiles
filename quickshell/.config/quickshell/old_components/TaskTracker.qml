import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

RowLayout {
  id: taskRoot
  spacing: 4
  Layout.fillHeight: true

  property var pinnedApps: []
  property bool kdeLoaded: false

  readonly property var defaultPinned: [
    "org.kde.konsole", "firefox", "dolphin",
    "org.kde.kate", "org.kde.discover", "code"
  ]

  // ── REUSABLE LAUNCH PROCESS (REPLACES DYNAMIC ENGINE OBJECT CREATION) ──
  Process {
    id: appLauncher
    function launch(desktopId) {
      command = ["bash", "-c", "gtk-launch " + desktopId + ".desktop &"];
      running = false;
      running = true;
    }
  }

  // Load pinned config from KDE assets
  Process {
    id: pinnedReader
    command: ["bash", "-c",
      "for f in \"$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc\"; do " +
      "grep '^launchers=' \"$f\" 2>/dev/null && break; " +
      "done | head -1 | sed 's/^launchers=//' | tr ',' '\\n' | " +
      "sed 's/^applications://' | sed 's/\\.desktop$//'"
    ]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        var id = line.trim();
        if (id !== "") {
          kdeLoaded = true;
          var list = taskRoot.pinnedApps.slice();
          if (list.indexOf(id) === -1) {
            list.push(id);
            taskRoot.pinnedApps = list;
          }
        }
      }
    }
    onRunningChanged: {
      if (!running && !kdeLoaded) {
        taskRoot.pinnedApps = taskRoot.defaultPinned;
      }
    }
  }

  // Pinned app launchers
  Repeater {
    model: taskRoot.pinnedApps

    delegate: Rectangle {
      height: 20
      implicitWidth: pinLabel.implicitWidth + 10
      Layout.alignment: Qt.AlignVCenter // Perfect centering within status bar row
      color: "transparent"
      border.color: Theme.fgMuted
      border.width: 1

      Text {
        id: pinLabel
        anchors.centerIn: parent
        text: modelData.split(".").pop().toUpperCase()
        font.family: Theme.fontMono
        font.pixelSize: 9
        color: Theme.fgMuted
      }
      
      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: appLauncher.launch(modelData)
      }
    }
  }

  // Separator line
  Text {
    text: taskRoot.pinnedApps.length > 0 ? "│" : ""
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgMuted
    Layout.alignment: Qt.AlignVCenter
  }

  // Active running Wayland client window blocks
  Repeater {
    model: Quickshell.windows && Quickshell.windows.length > 0 ? Quickshell.windows : []

    delegate: Rectangle {
      height: 20
      implicitWidth: taskLabel.implicitWidth + 10
      Layout.alignment: Qt.AlignVCenter // Perfect centering within status bar row
      color: modelData.active ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
      border.width: 1
      border.color: modelData.active ? Theme.accentBlue : Qt.rgba(1, 1, 1, 0.2)

      Text {
        id: taskLabel
        anchors.centerIn: parent
        text: {
          var label = modelData.appId || modelData.title || "WIN";
          return label.split(".").pop().toUpperCase().substring(0, 10);
        }
        font.family: Theme.fontMono
        font.pixelSize: 9
        color: modelData.active ? Theme.accentBlue : Theme.fgMuted
      }
    }
  }
}
