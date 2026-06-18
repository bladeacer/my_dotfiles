import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../theme"

Rectangle {
  id: launcherCard
  implicitWidth: 560
  implicitHeight: 400
  color: Theme.widgetBg
  border.color: Theme.accentBlue
  border.width: Theme.borderThin

  // ── INTERFACE OUTBOUND SIGNALS ──
  signal closeRequested()

  readonly property var matchedApps: {
    let appsObj = DesktopEntries.applications;
    if (!appsObj || !appsObj.values) return [];
    return appsObj.values.filter(app => app && app.name);
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4

      Text {
        text: "┌── [ SYSTEM_EXEC // RUN_PROMPT ] ────────────────────────────────┐"
        color: Theme.accentBlue
        font.family: Theme.fontMono
        font.pixelSize: 11
      }

      Text {
        Layout.topMargin: 8; Layout.leftMargin: 10
        text: "CLICK ANY APP TO LAUNCH  ||  ESC TO CLOSE"
        color: Theme.fgMuted
        font.family: Theme.fontMono; font.pixelSize: 10
      }
    }

    ListView {
      id: appList
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      spacing: 2

      model: launcherCard.matchedApps
      highlightFollowsCurrentItem: false
      highlight: null

      delegate: Rectangle {
        id: delegateRoot
        width: appList.width
        height: 34

        readonly property var appObject: modelData
        readonly property bool isCurrentItem: ListView.isCurrentItem

        color: isCurrentItem ? Qt.rgba(Theme.accentBlue.r, Theme.accentBlue.g, Theme.accentBlue.b, 0.08) : "transparent"
        border.color: isCurrentItem ? Theme.accentBlue : "transparent"
        border.width: isCurrentItem ? 1 : 0

        function launchApp() {
          if (appObject && typeof appObject.execute === "function") {
            appObject.execute();
          }
          launcherCard.closeRequested();
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 12

          Text {
            text: delegateRoot.isCurrentItem ? "»" : " "
            color: Theme.accentBlue
            font.family: Theme.fontMono
            font.pixelSize: 11
          }

          Text {
            text: (delegateRoot.appObject && delegateRoot.appObject.name ? delegateRoot.appObject.name : "UNKNOWN").toUpperCase()
            color: delegateRoot.isCurrentItem ? Theme.fgNormal : Theme.fgMuted
            font.family: Theme.fontMono
            font.pixelSize: 11
            Layout.preferredWidth: 200
            elide: Text.ElideRight
          }

          Text {
            text: "│"
            color: Qt.rgba(Theme.borderMain.r, Theme.borderMain.g, Theme.borderMain.b, 0.3)
            font.family: Theme.fontMono
            font.pixelSize: 11
          }

          Text {
            text: {
              if (!delegateRoot.appObject || !delegateRoot.appObject.categories || delegateRoot.appObject.categories.length === 0) return "SYSTEM";
              let cleanCats = delegateRoot.appObject.categories.filter(c => c !== "Application" && c !== "Qt" && c !== "GTK");
              return (cleanCats[0] ?? "SYSTEM").toUpperCase();
            }
            color: delegateRoot.isCurrentItem ? Theme.accentBlue : Qt.rgba(Theme.fgMuted.r, Theme.fgMuted.g, Theme.fgMuted.b, 0.5)
            font.family: Theme.fontMono
            font.pixelSize: 9
            Layout.fillWidth: true
            elide: Text.ElideRight
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          onPositionChanged: appList.currentIndex = index
          onClicked: delegateRoot.launchApp()
        }
      }
    }

    Text {
      text: "└────────────────────────────────────────────────────────────────┘"
      color: Theme.fgMuted
      font.family: Theme.fontMono
      font.pixelSize: 11
    }
  }
}
