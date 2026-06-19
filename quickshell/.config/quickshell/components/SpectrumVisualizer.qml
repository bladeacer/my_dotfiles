import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: spectrum
    clip: true

    property var bands: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Process {
        id: cavaProc
        command: ["cava", "-p", "/home/data/.config/quickshell/cava_config"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(";")
                var vals = []
                for (var i = 0; i < 24; i++) {
                    var v = i < parts.length ? parseFloat(parts[i]) : 0
                    vals.push(isNaN(v) ? 0 : Math.min(v / 100.0, 1.0))
                }
                spectrum.bands = vals
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: 24

            delegate: Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 6
                color: "transparent"

                Rectangle {
                    width: parent.width
                    height: parent.height * Math.min(1.0, Math.max(0.03, spectrum.bands[index] * 1.8))
                    anchors.bottom: parent.bottom
                    radius: 1
                    color: Theme.accentBlue
                    opacity: 0.2 + 0.15 * spectrum.bands[index]
                }
            }
        }
    }
}
