import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: viz
    color: "transparent"
    implicitWidth: 320
    implicitHeight: 48

    property var data: []

    Process {
        id: cavaRunner
        command: ["bash", "-c",
            "exec cava -p $HOME/my_dotfiles/quickshell/.config/quickshell/cava_config 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "") return
                var parts = line.trim().split(";")
                var arr = []
                for (var i = 0; i < parts.length; i++) {
                    var v = parseFloat(parts[i])
                    arr.push(isNaN(v) ? 0 : v)
                }
                viz.data = arr
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: 24

            delegate: Rectangle {
                width: 6
                height: {
                    var idx = index
                    var arr = viz.data
                    if (arr.length === 0) return 2
                    var normIdx = Math.floor(idx / 24 * arr.length)
                    if (normIdx >= arr.length) normIdx = arr.length - 1
                    return Math.max(2, arr[normIdx] * viz.height)
                }
                color: Theme.accentBlue
                opacity: 0.7 + (height / viz.height) * 0.3
                y: viz.height - height

                Behavior on height { NumberAnimation { duration: 60; easing.type: Easing.Linear } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
