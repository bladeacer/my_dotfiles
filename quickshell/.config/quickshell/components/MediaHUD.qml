import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: mediaCard
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    Process { id: cmdPrev; command: ["playerctl", "previous"] }
    Process { id: cmdToggle; command: ["playerctl", "play-pause"] }
    Process { id: cmdNext; command: ["playerctl", "next"] }
    Process { id: cmdScrub; command: ["playerctl", "position", "0"] }

    function scrubTo(percent) {
        var targetSec = Math.round(root.mediaLength * percent)
        if (isNaN(targetSec) || targetSec < 0) targetSec = 0
        if (targetSec > root.mediaLength) targetSec = root.mediaLength
        cmdScrub.command = ["playerctl", "position", targetSec.toFixed(0)]
        cmdScrub.running = false
        cmdScrub.running = true
        root.mediaPosition = targetSec
    }

    function fmtTime(seconds) {
        if (!seconds || seconds <= 0) return "--:--"
        var m = Math.floor(seconds / 60)
        var s = Math.round(seconds % 60)
        return m + ":" + s.toString().padStart(2, "0")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        Rectangle {
            id: artContainer
            width: 90
            height: 90
            color: Qt.rgba(1, 1, 1, 0.05)
            border.color: Theme.fgMuted
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: false
                source: root.mediaArtUrl !== "" ? "file://" + root.mediaArtUrl : ""
                visible: root.mediaArtUrl !== ""
            }
            Text {
                anchors.centerIn: parent
                text: "NO_ART"
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: Theme.fgMuted
                visible: root.mediaArtUrl === ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: Theme.frameHeader("LAYER_AUDIO // CORE_STATE")
                font.family: Theme.fontMono
                font.pixelSize: Theme.textMd
                color: Theme.accentBlue
            }

            Text {
                text: "  " + root.mediaMetadata
                font.family: Theme.fontMono
                font.pixelSize: Theme.textMd
                color: Theme.fgNormal
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                spacing: 6

                Text {
                    text: fmtTime(root.mediaPosition)
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    color: Theme.fgMuted
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: Theme.borderMain
                    Rectangle {
                        height: parent.height
                        color: Theme.accentBlue
                        width: parent.width * Math.min(1.0, Math.max(0.0, root.mediaPosition / Math.max(1, root.mediaLength)))
                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function(mouse) { mediaCard.scrubTo(mouse.x / width) }
                    }
                }

                Text {
                    text: fmtTime(root.mediaLength)
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    color: Theme.fgMuted
                }
            }

            RowLayout {
                spacing: 12
                Text {
                    text: "<< PREV"
                    font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    color: Theme.fgNormal
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdPrev.running = false; cmdPrev.running = true } }
                }
                Text {
                    text: root.mediaStatus === "playing" ? "\u23f8 PAUSE" : "\u25b6 PLAY"
                    font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    color: Theme.accentBlue
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdToggle.running = false; cmdToggle.running = true } }
                }
                Text {
                    text: "NEXT >>"
                    font.family: Theme.fontMono; font.pixelSize: Theme.textMd
                    color: Theme.fgNormal
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdNext.running = false; cmdNext.running = true } }
                }
            }

            Text {
                text: Theme.frameFooter()
                font.family: Theme.fontMono
                font.pixelSize: Theme.textMd
                color: Theme.fgMuted
            }
        }
    }
}
