import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".config/quickshell/components" as Components

ShellRoot {
    id: root

    property var offsets: ({})
    property var touched: ({})
    property var active: ({})
    property var dragStart: ({})
    property real dragTick: 0
    property string status: "drag bars, press Enter to save"

    settings.watchFiles: false

    function formula(h) { return h * 101/318 - 5.3491 }

    FileView {
        id: calFile
        path: Qt.resolvedUrl(".config/quickshell/calibrations.json")
        blockLoading: true
    }

    function loadCalibrations() {
        calFile.reload()
        var txt = calFile.text()
        if (!txt) return
        try {
            var cal = JSON.parse(txt)
            print("Existing calibrations:", JSON.stringify(cal))
            for (var name in cal) {
                var savedVal = cal[name]
                for (var i = 0; i < Quickshell.screens.length; i++) {
                    if (Quickshell.screens[i].name === name) {
                        var h = Quickshell.screens[i].height
                        root.offsets[name] = savedVal - formula(h)
                        print("  " + name + " (" + h + "px): calibration=" + savedVal.toFixed(1)
                            + " formula=" + formula(h).toFixed(1)
                            + " offset=" + root.offsets[name].toFixed(1))
                        break
                    }
                }
            }
        } catch (e) {
            print("Failed to parse calibrations:", e)
        }
    }

    Component.onCompleted: loadCalibrations()

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            focusable: true
            WlrLayershell.layer: WlrLayer.Overlay
            anchors { top: true; left: true; right: true; bottom: true }
            color: "#00000000"

            Components.SpectrumVisualizer {
                id: vis
                anchors.fill: parent
                calibrations: ({})
                screenName: modelData.name
                adjustmentOffset: {
                    root.dragTick
                    return root.offsets[modelData.name] || 0
                }
            }

            MouseArea {
                anchors.fill: parent

                onPressed: (mouse) => {
                    if (!modelData) { print("no modelData!"); return }
                    var name = modelData.name
                    print("pressed " + name)
                    if (root.offsets[name] === undefined) root.offsets[name] = 0
                    root.dragStart[name] = { y: mouse.y, off: root.offsets[name] }
                    root.active[name] = true
                    root.touched[name] = true
                }

                onPositionChanged: (mouse) => {
                    if (!modelData) return
                    var name = modelData.name
                    if (!root.active[name]) return
                    var ds = root.dragStart[name]
                    if (!ds) return
                    root.offsets[name] = ds.off - (mouse.y - ds.y)
                    root.dragTick++
                }

                onReleased: {
                    if (!modelData) return
                    root.active[modelData.name] = false
                }
            }

            Shortcut { sequence: "Return"; onActivated: root.saveCalibration() }
            Shortcut { sequence: "Escape"; onActivated: Qt.quit() }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 20
                width: hudText.width + 40
                height: hudText.height + 30
                radius: 6
                color: "#cc161821"
                border.color: "#84a0c6"
                border.width: 1

                Text {
                    id: hudText
                    anchors.centerIn: parent
                    color: "#c6c8d1"
                    font.family: "Departure Mono Nerd Font Mono"
                    font.pixelSize: 11
                    lineHeight: 1.6
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        root.dragTick
                        var name = modelData ? modelData.name : "?"
                        var h = modelData ? modelData.height : 0
                        var off = root.offsets[name] || 0
                        var pos = root.formula(h) + off
                        var s = name + ": " + h + "px  pos=" + pos.toFixed(1) + " (offset=" + off.toFixed(1) + ")"
                        for (var k in root.offsets) {
                            if (k === name) continue
                            var o = root.offsets[k] || 0
                            s += "\n" + k + ": offset=" + o.toFixed(1) + " (not saved)"
                        }
                        return s + "\n" + root.status
                    }
                }
            }
        }
    }

    Process {
        id: saver
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                print("[save]", line)
            }
        }
        onExited: {
            root.status = "saved!  [Escape] quit"
            root.touched = ({})
            root.dragTick++
        }
    }

    function saveCalibration() {
        var args = ["python3", "/home/data/my_dotfiles/quickshell/save-offset.py"]
        for (var name in root.touched) {
            var screen = null
            for (var i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === name) {
                    screen = Quickshell.screens[i]
                    break
                }
            }
            if (!screen) continue
            var h = screen.height
            var calibratedPos = root.formula(h) + (root.offsets[name] || 0)
            args.push(name)
            args.push(String(calibratedPos.toFixed(1)))
        }
        if (Object.keys(root.touched).length === 0) {
            root.status = "nothing to save — drag a bar first"
            return
        }
        root.status = "saving..."
        saver.command = args
        saver.running = false
        saver.running = true
        print("Saving:", args.join(" "))
    }
}
