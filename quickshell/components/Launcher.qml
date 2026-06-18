import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: launcherCardRoot // Changed to match file type cleanly
    anchors.fill: parent
    
    radius: 0
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    // ── INTERFACE OUTBOUND SIGNALS ──
    signal closeRequested()

    // ── RE-INDEXED NATIVE PROPERTY BINDING ──
    readonly property var matchedApps: {
        let appsObj = DesktopEntries.applications;
        if (!appsObj || !appsObj.values) return [];
        
        let query = searchInput.text.toLowerCase().trim();
        return appsObj.values.filter(app => {
            if (!app || !app.name) return false;
            if (query === "") return true;
            
            let nameMatch = app.name.toLowerCase().includes(query);
            let catMatch = app.categories && app.categories.join(" ").toLowerCase().includes(query);
            return nameMatch || catMatch;
        });
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

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                spacing: 6

                Text {
                    text: "SYS_INP »"
                    color: Theme.accentBlue
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    focus: true
                    color: Theme.fgNormal
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    cursorVisible: true

                    onTextChanged: {
                        appList.currentIndex = 0;
                    }

                    // ── SECURE NAVIGATION MATRIX ROUTER ──
                    Keys.onPressed: function(event) {
                        let totalMatches = appList.count;
                        if (totalMatches === 0) {
                            if (event.key === Qt.Key_Escape) {
                                launcherCardRoot.closeRequested();
                                event.accepted = true;
                            }
                            return;
                        }

                        if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
                            appList.currentIndex = (appList.currentIndex + 1) % totalMatches;
                            event.accepted = true;
                        }
                        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
                            appList.currentIndex = (appList.currentIndex - 1 + totalMatches) % totalMatches;
                            event.accepted = true;
                        }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (appList.currentItem) {
                                appList.currentItem.launchApp();
                            }
                            event.accepted = true;
                        }
                        else if (event.key === Qt.Key_Escape) {
                            launcherCardRoot.closeRequested();
                            event.accepted = true;
                        }
                    }
                }
                
                Text {
                    text: `[ MATCHES: ${launcherCardRoot.matchedApps.length.toString().padStart(3, '0')} ]`
                    color: Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 10
                }
            }
        }

        // ── RESULTS MATRIX TRAY ──
        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            
            model: launcherCardRoot.matchedApps
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
                    searchInput.text = "";
                    launcherCardRoot.closeRequested();
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

    onVisibleChanged: {
        if (visible) {
            focusTimer.start();
        } else {
            searchInput.text = "";
        }
    }

    Component.onCompleted: {
        focusTimer.start();
    }

    Timer {
        id: focusTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            searchInput.forceActiveFocus();
        }
    }
}
