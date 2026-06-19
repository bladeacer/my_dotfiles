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
        spacing: 1

        Repeater {
            model: 24

            delegate: Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 3

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.04)
                }

                Rectangle {
                    width: parent.width
                    height: parent.height * Math.min(1.0, Math.max(0.02, spectrum.bands[index]))
                    anchors.bottom: parent.bottom
                    color: Theme.accentBlue
                    opacity: 0.12
                }
            }
        }
    }
}
