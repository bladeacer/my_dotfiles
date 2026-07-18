import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: launcher
    color: Theme.widgetBg
    border.color: Theme.accentBlue
    border.width: Theme.borderThin

    property var allApps: []
    property var filteredApps: []
    property string searchText: ""
    property int selectedIndex: 0

    signal closeRequested()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { closeRequested(); event.accepted = true }
    }

    property bool loading: true

    Component.onCompleted: {
        Qt.callLater(function() { searchField.forceActiveFocus() })
        forceActiveFocus()
        var appsObj = DesktopEntries.applications
        if (appsObj && appsObj.values) {
            allApps = appsObj.values.filter(function(a) { return a && a.name })
            filteredApps = allApps.slice()
            loading = false
        }
    }

    Timer { interval: 1000; running: true; onTriggered: { if (allApps.length === 0) { var appsObj = DesktopEntries.applications; if (appsObj && appsObj.values) { allApps = appsObj.values.filter(function(a) { return a && a.name }); filteredApps = allApps.slice(); loading = false } } } }
    Timer { interval: 3000; running: true; onTriggered: { loading = false; var appsObj = DesktopEntries.applications; if (appsObj && appsObj.values) { allApps = appsObj.values.filter(function(a) { return a && a.name }); filteredApps = allApps.slice() } var sf = searchField; if (sf) launcher.filterApps(sf.text) } }

    function filterApps(text) {
        searchText = text.toUpperCase()
        if (searchText === "") {
            filteredApps = allApps.slice()
        } else {
            filteredApps = allApps.filter(function(app) {
                return app.name.toUpperCase().indexOf(searchText) !== -1
                    || (app.categories && app.categories.some(function(c) { return c.toUpperCase().indexOf(searchText) !== -1 }))
            })
        }
        selectedIndex = 0
    }

    function launchSelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var app = filteredApps[selectedIndex]
            if (app && typeof app.execute === "function") app.execute()
        }
        closeRequested()
    }

    function moveNext() {
        selectedIndex = Math.min(selectedIndex + 1, filteredApps.length - 1)
    }

    function movePrev() {
        selectedIndex = Math.max(selectedIndex - 1, 0)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        Text {
            text: Theme.frameHeader("SYSTEM_EXEC // RUN_PROMPT")
            color: Theme.accentBlue
            font.family: Theme.fontMono
            font.pixelSize: Theme.textMd
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: Theme.fgNormal
            font.family: Theme.fontMono
            font.pixelSize: Theme.textMd
            placeholderText: "FILTER // ..."
            placeholderTextColor: Theme.fgMuted
            background: Rectangle {
                color: Theme.bgNormal
                border.color: Theme.accentBlue
                border.width: 1
            }
            onTextChanged: launcher.filterApps(text)
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    launcher.launchSelected()
                    event.accepted = true
                } else if (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier)) {
                    launcher.moveNext()
                    event.accepted = true
                } else if (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier)) {
                    launcher.movePrev()
                    event.accepted = true
                } else if (event.key === Qt.Key_J && !(event.modifiers & Qt.ControlModifier)) {
                    launcher.moveNext()
                    event.accepted = true
                } else if (event.key === Qt.Key_K && !(event.modifiers & Qt.ControlModifier)) {
                    launcher.movePrev()
                    event.accepted = true
                }
            }
        }

        Text {
            text: "CTRL+N/J DN | CTRL+P/K UP | ENTER LAUNCH | ESC CLOSE"
            color: Theme.fgMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.textSm
        }

        Text {
            text: "SCANNING // ..."
            font.family: Theme.fontMono; font.pixelSize: Theme.textMd; color: Theme.fgMuted
            visible: launcher.loading
            Layout.alignment: Qt.AlignCenter
        }

        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 1
            model: launcher.filteredApps
            currentIndex: launcher.selectedIndex
            highlightMoveDuration: 0

            delegate: Rectangle {
                width: appList.width
                height: 30
                color: index === launcher.selectedIndex ? Theme.accentBlueDim : "transparent"
                border.color: index === launcher.selectedIndex ? Theme.accentBlue : "transparent"
                border.width: index === launcher.selectedIndex ? 1 : 0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Text {
                        text: index === launcher.selectedIndex ? "\u00bb" : " "
                        color: Theme.accentBlue
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.textMd
                    }

                    Text {
                        text: (modelData.name || "UNKNOWN").toUpperCase()
                        color: index === launcher.selectedIndex ? Theme.fgNormal : Theme.fgMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.textMd
                        Layout.preferredWidth: 200
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "\u2502"
                        color: Theme.borderSubdued
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.textMd
                    }

                    Text {
                        text: {
                            if (!modelData.categories || modelData.categories.length === 0) return "SYS"
                            var clean = modelData.categories.filter(function(c) { return c !== "Application" && c !== "Qt" && c !== "GTK" })
                            return (clean[0] || "SYS").toUpperCase()
                        }
                        color: index === launcher.selectedIndex ? Theme.accentBlue : Theme.fgMuted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.textSm
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: launcher.selectedIndex = index
                    onClicked: { launcher.selectedIndex = index; launcher.launchSelected() }
                }
            }
        }

        Text {
            text: Theme.frameFooter()
            color: Theme.fgMuted
            font.family: Theme.fontMono
            font.pixelSize: Theme.textMd
        }
    }
}
