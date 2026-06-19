import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

RowLayout {
    id: taskRoot
    spacing: 4
    Layout.fillHeight: true

    property var pinnedApps: []
    property bool kdeLoaded: false

    readonly property var defaultPinned: [
        "org.kde.konsole", "firefox", "dolphin",
        "org.kde.kate", "org.kde.discover", "code"
    ]

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

        delegate: Text {
            Layout.alignment: Qt.AlignVCenter
            text: "[" + (index + 1) + "]: " + modelData.split(".").pop()
            font.family: Theme.fontMono; font.pixelSize: 11
            color: Theme.fgMuted
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: appLauncher.launch(modelData)
                hoverEnabled: true
                onEntered: parent.color = Theme.accentBlue
                onExited: parent.color = Theme.fgMuted
            }
        }
    }

    Repeater {
        model: Quickshell.windows && Quickshell.windows.length > 0 ? Quickshell.windows : []

        delegate: Text {
            Layout.alignment: Qt.AlignVCenter
            text: {
                var idx = index + 1
                var label = modelData.appId || modelData.title || "WIN"
                return "[" + idx + "]: " + label.split(".").pop()
            }
            font.family: Theme.fontMono; font.pixelSize: 11
            color: modelData.active ? Theme.accentBlue : Theme.fgMuted
        }
    }
}
