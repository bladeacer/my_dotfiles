import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: mediaCard
    color: "transparent"

    signal closeRequested()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true }
    }

    Process { id: cmdPrev; command: ["playerctl", "previous"] }
    Process { id: cmdToggle; command: ["playerctl", "play-pause"] }
    Process { id: cmdNext; command: ["playerctl", "next"] }
    Process { id: cmdScrub; command: ["playerctl", "position", "0"] }
    Process { id: pollStatus; command: ["playerctl", "status", "--format", "{{ status }}"]; stdout: SplitParser { onRead: (line) => { root.mediaStatus = line.trim().toLowerCase() } } }

    function scrubTo(percent) {
        var targetSec = Math.round(root.mediaLength * percent)
        if (isNaN(targetSec) || targetSec < 0) targetSec = 0
        if (targetSec > root.mediaLength) targetSec = root.mediaLength
        cmdScrub.command = ["playerctl", "position", targetSec.toFixed(0)]
        cmdScrub.running = false; cmdScrub.running = true
        root.mediaPosition = targetSec
    }

    function fmtTime(seconds) {
        if (!seconds || seconds <= 0) return "--:--"
        var m = Math.floor(seconds / 60)
        var s = Math.round(seconds % 60)
        return m + ":" + s.toString().padStart(2, "0")
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 8; spacing: 4

        RowLayout {
            Layout.fillWidth: true; spacing: 0
            Text {
                text: "\u250c\u2500\u2500 [ LAYER_AUDIO // CORE_STATE ]"
                font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.accentBlue
                Layout.alignment: Qt.AlignVCenter
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 1
                color: Theme.accentBlue; Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: "\u2500\u2500\u2510"; font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.accentBlue
                Layout.alignment: Qt.AlignVCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 6

            Rectangle {
                Layout.leftMargin: 8
                width: 50; height: 50
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Theme.fgMuted; border.width: 1
                Image {
                    anchors.fill: parent; fillMode: Image.PreserveAspectCrop; cache: false
                    source: root.mediaArtUrl !== "" ? "file://" + root.mediaArtUrl : ""
                    visible: root.mediaArtUrl !== ""
                }
                Text {
                    anchors.centerIn: parent; text: "NO_ART"
                    font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted
                    visible: root.mediaArtUrl === ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true; spacing: 3

                Text {
                    text: root.mediaMetadata; elide: Text.ElideRight
                    font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgNormal
                    Layout.fillWidth: true
                }

                RowLayout {
                    visible: root.mediaAlbum !== "" || root.mediaComposer !== ""
                    Layout.fillWidth: true; spacing: 4
                    Text {
                        text: root.mediaAlbum !== "" ? root.mediaAlbum : root.mediaComposer
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted
                        elide: Text.ElideRight; Layout.fillWidth: true
                    }
                    Text {
                        text: root.mediaComposer !== "" && root.mediaAlbum !== "" ? "// " + root.mediaComposer : ""
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 4; Layout.rightMargin: 4
                    Text { text: fmtTime(root.mediaPosition); font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted }
                    Rectangle {
                        Layout.fillWidth: true; height: 4; color: Theme.borderMain
                        Rectangle {
                            height: parent.height; color: Theme.accentBlue
                            width: parent.width * Math.min(1.0, Math.max(0.0, root.mediaPosition / Math.max(1, root.mediaLength)))
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: function(m) { mediaCard.scrubTo(m.x / width) } }
                    }
                    Text { text: fmtTime(root.mediaLength); font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted }
                }

                RowLayout {
                    spacing: 8
                    Text {
                        text: "<< PREV"; font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgNormal
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdPrev.running = false; cmdPrev.running = true } }
                    }
                    Text {
                        text: root.mediaStatus === "playing" ? "\u258c\u258c PAUSE" : "\u25b6 PLAY"
                        font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.accentBlue
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggle.running = false; cmdToggle.running = true; pollStatus.running = false; pollStatus.running = true } }
                    }
                    Text {
                        text: "NEXT >>"; font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgNormal
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdNext.running = false; cmdNext.running = true } }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 0
            Text { text: "\u2514\u2500\u2500"; font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 1
                color: Theme.fgMuted; Layout.alignment: Qt.AlignVCenter
            }
            Text { text: "\u2500\u2500\u2518"; font.family: Theme.fontMono; font.pixelSize: Theme.textSm; color: Theme.fgMuted }
        }
    }
}
