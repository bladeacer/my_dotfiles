pragma Singleton
import QtQuick
import Quickshell

QtObject {
  id: root

  property string title: ""
  property string appId: ""

  property Timer pollTimer: Timer {
    interval: 800; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      var wins = Quickshell.windows;
      if (!wins) {
        root.title = "";
        root.appId = "";
        return;
      }
      for (var i = 0; i < wins.length; i++) {
        if (wins[i] && wins[i].active) {
          root.appId = wins[i].appId || "";
          root.title = wins[i].title || root.appId;
          return;
        }
      }
      root.title = "";
      root.appId = "";
    }
  }
}
