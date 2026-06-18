import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

RowLayout {
    spacing: 8

    Repeater {
        // Safe access evaluation syntax for the compositor tracking vector
        model: Quickshell.windows ? Quickshell.windows : 0

        delegate: Rectangle {
            height: 18
            implicitWidth: taskLabel.implicitWidth + 12
            color: "transparent"
            border.color: modelData.active ? Theme.accentBlue : Qt.rgba(Theme.borderMain.r, Theme.borderMain.g, Theme.borderMain.b, 0.2)
            border.width: 1

            Text {
                id: taskLabel
                anchors.centerIn: parent
                // Pulls structural shell classifications cleanly with standard Departure Mono formatting
                text: {
                    let winName = "NODE_WINDOW";
                    if (modelData.title && modelData.title.trim() !== "") {
                        winName = modelData.title.split(" - ").pop().toUpperCase();
                    } else if (modelData.appId && modelData.appId.trim() !== "") {
                        winName = modelData.appId.toUpperCase();
                    }
                    return `[0x${index + 1}] ${winName}`;
                }
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: modelData.active ? Theme.fgNormal : Theme.fgMuted
            }
        }
    }
}
