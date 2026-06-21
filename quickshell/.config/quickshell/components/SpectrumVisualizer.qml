import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: spectrum
    clip: true

    property var bands: []
    property real barWidthRatio: (28/2879 + 20/2559) / 2
    property real gapWidthRatio: (13/2879 + 10/2559) / 2
    property int barCount: Math.floor(1 / (barWidthRatio + gapWidthRatio))
    property real barPx: parent.width * barWidthRatio
    property real gapPx: parent.width * gapWidthRatio
    property real adjustmentOffset: 0
    property string screenName: ""
    property var calibrations: ({})

    FileView {
        id: calFile
        path: Qt.resolvedUrl("../calibrations.json")
        blockLoading: true
    }

    Component.onCompleted: {
        calFile.reload()
        var txt = calFile.text()
        if (txt) {
            try { calibrations = JSON.parse(txt) }
            catch (e) { calibrations = ({}) }
        }
        var a = []
        for (var i = 0; i < barCount; i++) a.push(0)
        bands = a
    }

    Process {
        id: lookasProc
        command: ["/home/data/my_dotfiles/quickshell/lookas-bridge/target/release/lookas-bridge"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(/\s+/)
                var vals = []
                for (var i = 0; i < barCount; i++) {
                    var v = i < parts.length ? parseFloat(parts[i]) : 0
                    vals.push(isNaN(v) ? 0 : v)
                }
                spectrum.bands = vals
            }
        }
    }

    Row {
        id: barRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (
            calibrations[screenName] ??
            calibrations[String(parent.height)] ??
            parent.height * 101/318 - 5.3491
        ) + adjustmentOffset
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height * 800/1800
        spacing: gapPx

        Repeater {
            model: barCount

            delegate: Item {
                width: spectrum.barPx
                height: barRow.height

                Rectangle {
                    width: parent.width
                    property real val: spectrum.bands[index] || 0
                    height: parent.height * Math.min(0.85, Math.max(0.01, val * 1.2))
                    anchors.bottom: parent.bottom
                    radius: 1
                    color: Theme.accentBlue
                    opacity: 0.2 + 0.4 * val
                }
            }
        }
    }
}
