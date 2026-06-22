import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services" as Services
import "../theme"

RowLayout {
    id: taskRoot
    spacing: 8
    Layout.fillHeight: true
    Layout.leftMargin: 6

    property var pinnedApps: []
    property bool kdeLoaded: false

    readonly property var defaultPinned: [
        "org.kde.konsole", "firefox", "dolphin",
        "org.kde.kate", "org.kde.discover", "code"
    ]

    property var winCounts: ({})
    property var toplevelList: []

    // ── ToplevelManager-based tracking (Hyprland/Niri/Sway) ──
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var counts = {}
            var list = []
            function addWin(w) {
                if (!w) return
                if (list.indexOf(w) !== -1) return
                list.push(w)
                var id = typeof w.appId === 'string' ? w.appId : ""
                if (id !== "") counts[id] = (counts[id] || 0) + 1
            }
            if (typeof ToplevelManager !== 'undefined') {
                var tl = ToplevelManager.toplevels
                if (tl) {
                    if (tl.values) {
                        for (var i = 0; i < tl.values.length; i++) addWin(tl.values[i])
                    } else if (typeof tl.count === 'number') {
                        for (var i = 0; i < tl.count; i++) addWin(tl.get(i))
                    }
                }
            }
            if (Object.keys(counts).length > 0) {
                taskRoot.winCounts = counts
                taskRoot.toplevelList = list
            }
        }
    }

    // ── KDE fallback: enumerate windows via kdotool + KWin D-Bus ──
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!kdeEnum.running) {
                kdeEnum._rawBuffer = ""
                kdeEnum.running = false
                kdeEnum.running = true
            }
        }
    }

    Process {
        id: kdeEnum
        property string _rawBuffer: ""
        command: ["bash", "-c",
            "for id in $(kdotool search '.' 2>/dev/null); do " +
            "c=$(kdotool getwindowclassname $id 2>/dev/null); " +
            "[ \"$c\" = \"plasmashell\" ] && continue; " +
            "[ -z \"$c\" ] && continue; " +
            "i=$(qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo $id 2>&1); " +
            "d=$(echo \"$i\" | grep '^desktopFile:' | sed 's/^desktopFile: //'); " +
            "t=$(echo \"$i\" | grep '^caption:' | sed 's/^caption: //'); " +
            "[ -n \"$d\" ] && echo \"$d|$t\"; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                var l = line.trim()
                if (l !== "") kdeEnum._rawBuffer += l + "\n"
            }
        }
        onRunningChanged: {
            if (!running && _rawBuffer !== "") {
                var lines = _rawBuffer.trim().split("\n")
                var counts = {}
                var list = []
                for (var i = 0; i < lines.length; i++) {
                    var sep = lines[i].indexOf("|")
                    if (sep > 0) {
                        var appId = lines[i].substring(0, sep)
                        var title = lines[i].substring(sep + 1)
                        if (appId && appId !== "plasmashell") {
                            counts[appId] = (counts[appId] || 0) + 1
                            if (taskRoot.pinnedApps.indexOf(appId) === -1) {
                                list.push({ appId: appId, title: title, activated: true })
                            }
                        }
                    }
                }
                taskRoot.winCounts = counts
                taskRoot.toplevelList = list
                _rawBuffer = ""
            }
        }
    }

    Process {
        id: appLauncher
        function launch(desktopId) {
            command = ["bash", "-c", "gtk-launch " + desktopId + ".desktop &"]
            running = false; running = true
        }
    }

    Process {
        id: pinnedReader
        command: ["bash", "-c",
            "for f in \"$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc\"; do " +
            "grep '^launchers=' \"$f\" 2>/dev/null && break; " +
            "done | head -1 | sed 's/^launchers=//' | tr ',' '\\n' | " +
            "sed 's/^applications://' | sed 's/\\.desktop$//'"
        ]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var id = line.trim()
                if (id !== "") {
                    kdeLoaded = true
                    var list = taskRoot.pinnedApps.slice()
                    if (list.indexOf(id) === -1) { list.push(id); taskRoot.pinnedApps = list }
                }
            }
        }
        onRunningChanged: {
            if (!running && !kdeLoaded) taskRoot.pinnedApps = taskRoot.defaultPinned
        }
    }

    Repeater {
        model: taskRoot.pinnedApps

        delegate: Item {
            id: del
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.preferredWidth: idx.implicitWidth + (del.hovered ? nm.implicitWidth + 6 : 0)
            clip: true

            property bool hovered: false
            property int wc: taskRoot.winCounts[modelData] || 0

            Text {
                id: idx
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var o = wc === 0 ? "[" : wc === 1 ? "{" : "("
                    var c = wc === 0 ? "]" : wc === 1 ? "}" : ")"
                    return o + (index + 1) + c
                }
                font.family: Theme.fontMono; font.pixelSize: 11
                color: wc === 0 ? Theme.fgMuted : wc === 1 ? Theme.accentGreen : Theme.accentBlue
            }

            Text {
                id: nm
                anchors.verticalCenter: parent.verticalCenter
                x: idx.implicitWidth + 6
                text: modelData.split(".").pop()
                font.family: Theme.fontMono; font.pixelSize: 11
                color: Theme.fgNormal
                opacity: del.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: del.hovered = true
                onExited: del.hovered = false
                onClicked: appLauncher.launch(modelData)
            }
        }
    }

    Repeater {
        model: taskRoot.toplevelList

        delegate: Text {
            visible: {
                var id = modelData ? (typeof modelData.appId === 'string' ? modelData.appId : "") : ""
                return id === "" || taskRoot.pinnedApps.indexOf(id) === -1
            }
            Layout.alignment: Qt.AlignVCenter
            text: {
                var label = modelData ? (typeof modelData.appId === 'string' ? modelData.appId : (typeof modelData.title === 'string' ? modelData.title : "WIN")) : "WIN"
                return "[" + label.split(".").pop() + "]"
            }
            font.family: Theme.fontMono; font.pixelSize: 11
            color: modelData && modelData.activated ? Theme.accentBlue : Theme.fgMuted
        }
    }
}
