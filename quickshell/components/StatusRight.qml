import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: control
    spacing: 12
    Layout.alignment: Qt.AlignRight

    signal wifiClicked()
    signal sysClicked()

    Text { text: root.bluetoothTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

    Text { text: root.batteryTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

    MouseArea {
        Layout.fillHeight: true
        width: wifiLayout.implicitWidth
        RowLayout {
            id: wifiLayout; anchors.fill: parent; spacing: 4
            Text { text: root.wifiTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue }
        }
        onClicked: control.wifiClicked()
    }

    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

    MouseArea {
        Layout.fillHeight: true; width: sysLabel.implicitWidth
        Text { id: sysLabel; anchors.verticalCenter: parent.verticalCenter; text: "SYS_CTRL"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
        onClicked: control.sysClicked()
    }

    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
    Text { text: root.currentTimestamp; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
}
