import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: control
    spacing: 12
    Layout.alignment: Qt.AlignRight

    signal btClicked()
    signal wifiClicked()
    signal sysClicked()

    // Interactive Bluetooth Module Node
    MouseArea {
        Layout.fillHeight: true; width: btLayout.implicitWidth
        RowLayout { id: btLayout; anchors.fill: parent; Text { text: root.bluetoothTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal } }
        onClicked: control.btClicked()
    }

    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
    Text { text: root.batteryTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

    // WLAN Telemetry Readout (Pure Data Stream, Not Clickable)
    Text { text: root.wifiTelemetry; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.accentBlue }

    Text { text: "│"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

    // Separate Wi-Fi Interaction Interface Button
    MouseArea {
        Layout.fillHeight: true; width: wifiLabel.implicitWidth
        Text { id: wifiLabel; anchors.verticalCenter: parent.verticalCenter; text: "WIFI_CTRL"; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
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
