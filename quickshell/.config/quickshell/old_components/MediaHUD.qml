import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
  id: mediaCard
  width: 420; height: 135
  color: Theme.widgetBg; border.color: Theme.accentBlue; border.width: 1

  Process { id: cmdPrev; command: ["playerctl", "previous"] }
  Process { id: cmdToggle; command: ["playerctl", "play-pause"] }
  Process { id: cmdNext; command: ["playerctl", "next"] }

  Process {
    id: cmdScrub
    command: ["playerctl", "position", "0"]
  }

  function scrubTo(percent) {
    let targetSec = Math.round(root.mediaLength * percent);
    if (isNaN(targetSec) || targetSec < 0) targetSec = 0;
    if (targetSec > root.mediaLength) targetSec = root.mediaLength;
    cmdScrub.command = ["playerctl", "position", targetSec.toFixed(0)];
    cmdScrub.running = false;
    cmdScrub.running = true;
    root.mediaPosition = targetSec;
  }

  MouseArea { anchors.fill: parent; propagateComposedEvents: true }

  RowLayout {
    anchors.fill: parent; anchors.margins: 12; spacing: 14

    Rectangle {
      id: artContainer
      width: 90; height: 90; color: Qt.rgba(1,1,1,0.05); border.color: Theme.fgMuted; border.width: 1
      Layout.alignment: Qt.AlignVCenter
      Image {
        anchors.fill: parent; fillMode: Image.PreserveAspectCrop; cache: false
        source: root.mediaArtUrl !== "" ? "file://" + root.mediaArtUrl : ""
        visible: root.mediaArtUrl !== ""
      }
      Text {
        anchors.centerIn: parent; text: "NO_ART"; font.family: Theme.fontMono; font.pixelSize: 9
        color: Theme.fgMuted; visible: root.mediaArtUrl === ""
      }
    }

    ColumnLayout {
      Layout.preferredWidth: 260
      Layout.fillWidth: false
      spacing: 4

      Text { text: "┌── [ LAYER_AUDIO // CORE_STATE ]──────────┐"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue }
      Text { text: "  ${root.mediaMetadata}"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal; elide: Text.ElideRight; Layout.fillWidth: true }

      Item {
        Layout.fillWidth: true; height: 18; Layout.topMargin: 2; Layout.leftMargin: 8
        RowLayout {
          anchors.fill: parent; spacing: 6
          Text {
            text: { let m = Math.floor(root.mediaPosition / 60); let s = root.mediaPosition % 60; return m + ":" + s.toString().padStart(2, "0"); }
            font.family: Theme.fontMono; font.pixelSize: 8; color: Theme.fgMuted
          }
          Rectangle {
            Layout.fillWidth: true; height: 4; color: Theme.borderMain
            Rectangle {
              height: parent.height; color: Theme.accentBlue
              width: parent.width * Math.min(1.0, Math.max(0.0, root.mediaPosition / Math.max(1, root.mediaLength)))
            }
            MouseArea {
              anchors.fill: parent; cursorShape: Qt.PointingHandCursor
              onClicked: (mouse) => mediaCard.scrubTo(mouse.x / width)
            }
          }
          Text {
            text: { if (!root.mediaLength || root.mediaLength <= 1) return "--:--"; let m = Math.floor(root.mediaLength / 60); let s = Math.round(root.mediaLength % 60); return m + ":" + s.toString().padStart(2, "0"); }
            font.family: Theme.fontMono; font.pixelSize: 8; color: Theme.fgMuted
          }
        }
      }

      RowLayout { spacing: 12; Layout.topMargin: 2
        Text { text: "   << PREV"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdPrev.running = false; cmdPrev.running = true; } } }
        Text { id: playPauseBtn; property string localOverride: ""
          text: localOverride !== "" ? localOverride : (root.mediaStatus === "playing" ? "⏸ PAUSE" : "▶ PLAY")
          font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: { playPauseBtn.localOverride = (playPauseBtn.text === "▶ PLAY") ? "⏸ PAUSE" : "▶ PLAY"; cmdToggle.running = false; cmdToggle.running = true; } } }
        Text { text: "NEXT >>"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cmdNext.running = false; cmdNext.running = true; } } }
      }

      Text { text: "└──────────────────────────────────────────┘"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
    }
  }

  Connections {
    target: root
    function onMediaStatusChanged() { playPauseBtn.localOverride = ""; }
  }
}
