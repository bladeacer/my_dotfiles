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

    // Set to true only once the native Wayland ToplevelManager
    // actually reports windows (Sway/Hyprland/niri). KWin does
    // not implement the zwlr-foreign-toplevel-management-v1
    // protocol, so on KDE Plasma this stays false and the
    // kdotool + KWin D-Bus path is used instead.
    property bool nativeToplevels: false

    readonly property var defaultPinned: [
        "org.kde.konsole", "firefox", "dolphin",
        "org.kde.kate", "org.kde.discover", "code"
    ]

    property var winCounts: ({})
    property var toplevelList: []

    // Normalise an app identifier so Wayland app_ids ("org.kde.konsole"),
    // WM_CLASS values ("konsole") and KWin desktopFile paths
    // ("/usr/share/applications/org.kde.konsole.desktop") all compare
    // equal against the pinned list.
    function normAppId(id) {
        if (typeof id !== 'string') return ""
        var s = id.toLowerCase()
        var slash = s.lastIndexOf("/")
        if (slash !== -1) s = s.substring(slash + 1)
        if (s.endsWith(".desktop")) s = s.substring(0, s.length - 8)
        return s
    }

    function isPinned(appId) {
        var n = taskRoot.normAppId(appId)
        if (n === "") return false
        for (var i = 0; i < taskRoot.pinnedApps.length; i++) {
            if (taskRoot.normAppId(taskRoot.pinnedApps[i]) === n) return true
        }
        return false
    }

    // ── ToplevelManager-based tracking (Wayland native) ──
    // Only takes over once the compositor actually reports
    // toplevels. On KWin this always yields nothing because the
    // foreign-toplevel-management protocol is not implemented,
    // so the kdotool path below drives the taskbar instead.
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (typeof ToplevelManager === 'undefined') return
            var counts = {}
            var list = []
            function addWin(w) {
                if (!w) return
                if (list.indexOf(w) !== -1) return
                list.push(w)
                var id = taskRoot.normAppId(w.appId)
                if (id !== "") counts[id] = (counts[id] || 0) + 1
            }
            var tl = ToplevelManager.toplevels
            if (tl) {
                if (tl.values) {
                    for (var i = 0; i < tl.values.length; i++) addWin(tl.values[i])
                } else if (typeof tl.count === 'number') {
                    for (var i = 0; i < tl.count; i++) addWin(tl.get(i))
                }
            }
            if (list.length > 0) {
                taskRoot.nativeToplevels = true
                taskRoot.winCounts = counts
                taskRoot.toplevelList = list
            } else if (taskRoot.nativeToplevels) {
                taskRoot.winCounts = ({})
                taskRoot.toplevelList = []
            }
        }
    }

    // ── KDE fallback: enumerate windows via kdotool + KWin D-Bus ──
    // Runs whenever the native ToplevelManager is not
    // reporting windows (always the case on KWin).
    Timer {
        interval: 3000
        running: !taskRoot.nativeToplevels
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
                        var norm = taskRoot.normAppId(appId)
                        if (norm !== "" && norm.indexOf("plasmashell") === -1) {
                            counts[norm] = (counts[norm] || 0) + 1
                            if (!taskRoot.isPinned(norm)) {
                                list.push({ appId: norm, title: title, activated: true })
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
            property int wc: taskRoot.winCounts[taskRoot.normAppId(modelData)] || 0

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
                return id === "" || !taskRoot.isPinned(id)
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
