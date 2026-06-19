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
            running = false
            running = true
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
                    if (list.indexOf(id) === -1) {
                        list.push(id)
                        taskRoot.pinnedApps = list
                    }
                }
            }
        }
        onRunningChanged: {
            if (!running && !kdeLoaded) taskRoot.pinnedApps = taskRoot.defaultPinned
        }
    }

    Repeater {
        model: taskRoot.pinnedApps

        delegate: Rectangle {
            height: 20
            implicitWidth: pinLabel.implicitWidth + 8
            Layout.alignment: Qt.AlignVCenter
            color: "transparent"
            border.color: Theme.fgMuted
            border.width: 1

            Text {
                id: pinLabel
                anchors.centerIn: parent
                text: modelData.split(".").pop().toUpperCase()
                font.family: Theme.fontMono
                font.pixelSize: 8
                color: Theme.fgMuted
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: appLauncher.launch(modelData)
            }
        }
    }

    Text {
        text: taskRoot.pinnedApps.length > 0 ? "\u2502" : ""
        font.family: Theme.fontMono
        font.pixelSize: 9
        color: Theme.fgMuted
        Layout.alignment: Qt.AlignVCenter
    }

    Repeater {
        model: Quickshell.windows && Quickshell.windows.length > 0 ? Quickshell.windows : []

        delegate: Rectangle {
            height: 20
            implicitWidth: taskLabel.implicitWidth + 8
            Layout.alignment: Qt.AlignVCenter
            color: modelData.active ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            border.width: 1
            border.color: modelData.active ? Theme.accentBlue : Qt.rgba(1, 1, 1, 0.15)

            Text {
                id: taskLabel
                anchors.centerIn: parent
                text: {
                    var label = modelData.appId || modelData.title || "WIN"
                    return label.split(".").pop().toUpperCase().substring(0, 8)
                }
                font.family: Theme.fontMono
                font.pixelSize: 8
                color: modelData.active ? Theme.accentBlue : Theme.fgMuted
            }
        }
    }
}
