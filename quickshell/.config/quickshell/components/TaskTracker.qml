import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

RowLayout {
  id: taskRoot
  spacing: 6

  property var pinnedApps: []
  property var runningApps: ({})

  // Read pinned apps from KDE's IconsOnlyTaskManager config
  Process {
    id: pinnedReader
    command: [
      "bash", "-c",
      "grep '^launchers=' \"$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc\" 2>/dev/null | " +
      "head -1 | sed 's/^launchers=//' | tr ',' '\\n' | sed 's/^applications://' | sed 's/\\.desktop$//'"
    ]
    running: true
    stdout: SplitParser {
      onRead: (line) => {
        var id = line.trim();
        if (id !== "") {
          var list = taskRoot.pinnedApps;
          list.push(id);
          taskRoot.pinnedApps = list;
        }
      }
    }
  }

  // Track running windows (poll-based, no change signal available)
  Timer {
    interval: 1500; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      var map = {};
      var wins = Quickshell.windows;
      if (wins) {
        for (var i = 0; i < wins.length; i++) {
          var w = wins[i];
          if (w && w.appId) map[w.appId.toLowerCase()] = true;
        }
      }
      taskRoot.runningApps = map;
    }
  }

  // Pinned app launchers
  Repeater {
    model: taskRoot.pinnedApps

    delegate: Rectangle {
      height: 20
      implicitWidth: pinLabel.implicitWidth + 10
      color: {
        var appId = modelData.toLowerCase();
        return taskRoot.runningApps[appId] ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.15) : "transparent";
      }
      border.color: taskRoot.runningApps[modelData.toLowerCase()] ? Theme.accentBlue : Qt.rgba(Theme.borderMain.r, Theme.borderMain.g, Theme.borderMain.b, 0.2)
      border.width: 1

      Text {
        id: pinLabel
        anchors.centerIn: parent
        text: modelData.toUpperCase()
        font.family: Theme.fontMono; font.pixelSize: 9
        color: taskRoot.runningApps[modelData.toLowerCase()] ? Theme.fgNormal : Theme.fgMuted
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          var appId = modelData;
          var cmd = "gtk-launch " + appId + ".desktop &";
          var p = Quickshell.createProcess(["bash", "-c", cmd]);
          p.running = true;
        }
      }
    }
  }

  // Separator
  Text {
    text: "│"
    font.family: Theme.fontMono; font.pixelSize: 9
    color: Theme.fgMuted
  }

  // Running windows
  Repeater {
    model: Quickshell.windows ? Quickshell.windows : 0

    delegate: Rectangle {
      height: 20
      implicitWidth: taskLabel.implicitWidth + 10
      color: modelData.active ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.12) : "transparent"
      border.color: modelData.active ? Theme.accentBlue : Qt.rgba(Theme.borderMain.r, Theme.borderMain.g, Theme.borderMain.b, 0.2)
      border.width: 1

      Text {
        id: taskLabel
        anchors.centerIn: parent
        text: {
          var label = "";
          if (modelData.appId) label = modelData.appId.split(".").pop().toUpperCase();
          else if (modelData.title) label = modelData.title.split(" - ").shift().toUpperCase();
          else label = "WIN";
          return label.substring(0, 12);
        }
        font.family: Theme.fontMono; font.pixelSize: 9
        color: modelData.active ? Theme.fgNormal : Theme.fgMuted
      }
    }
  }
}
