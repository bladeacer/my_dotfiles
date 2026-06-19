pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string title: ""
    property string appId: ""

    property string wmClass: ""

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var wins = Quickshell.windows
            if (!wins || wins.length === 0) return
            for (var i = 0; i < wins.length; i++) {
                if (wins[i].active) {
                    title = wins[i].title || ""
                    appId = wins[i].appId || ""
                    wmClass = wins[i].wmClass || ""
                    return
                }
            }
            title = ""
            appId = ""
            wmClass = ""
        }
    }
}
