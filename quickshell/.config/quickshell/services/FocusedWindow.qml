pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  property string title: ""
  property string appId: ""

  property Process kwinQuery: Process {
    command: ["bash", "-c",
      "qdbus org.kde.KWin /KWin queryWindowInfo 2>/dev/null | " +
      "grep -E '^(Title|DesktopFile):' | " +
      "sed 's/^Title: *//; s/^DesktopFile: *//' | " +
      "head -2 | tr '\\n' '|' || true"
    ]
    running: false
    stdout: SplitParser {
      onRead: (line) => {
        var parts = line.trim().split("|");
        if (parts.length >= 2 && parts[0] !== "") {
          root.title = parts[0];
          root.appId = parts[1].split("/").pop().replace(".desktop", "");
        }
      }
    }
  }

  property Timer pollTimer: Timer {
    interval: 800; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      // Try Quickshell.windows first (wlr-foreign-toplevel)
      var wins = Quickshell.windows;
      if (wins && wins.length > 0) {
        for (var i = 0; i < wins.length; i++) {
          if (wins[i] && wins[i].active) {
            root.appId = wins[i].appId || "";
            root.title = wins[i].title || root.appId;
            return;
          }
        }
      }
      // Fallback: try KDE D-Bus
      kwinQuery.running = false;
      kwinQuery.running = true;
    }
  }
}
