pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property QtObject activeWindow: {
        var wins = Quickshell.windows
        if (!wins) return null
        for (var i = 0; i < wins.length; i++) {
            if (wins[i].active || wins[i].focused) return wins[i]
        }
        return null
    }

    readonly property string title: activeWindow ? activeWindow.title : ""
    readonly property string appId: activeWindow ? activeWindow.appId : ""
    readonly property string wmClass: activeWindow ? activeWindow.wmClass : ""
}
