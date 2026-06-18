import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: control
    // Forces the component container block to expand to wrap its children's dimensions natively
    implicitWidth: mainRow.implicitWidth
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignRight

    signal btClicked()
    signal wifiCtrlClicked()
    signal sysClicked()

    Row {
        id: mainRow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 12

        // ── BLUETOOTH HUB NODE ──
        MouseArea {
            height: parent.height
            width: btText.implicitWidth
            Text {
                id: btText
                anchors.verticalCenter: parent.verticalCenter
                text: root.bluetoothTelemetry
                font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
            }
            onClicked: control.btClicked()
        }

        Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
        Text { text: root.batteryTelemetry; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
        Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

        // ── DEDICATED INTERACTIVE WIFI_CTRL NODE ──
        MouseArea {
            height: parent.height
            width: wifiText.implicitWidth
            Text {
                id: wifiText
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
                text: {
                    let rssi = root.wifiSignalStrength;
                    let bars = "░░░░"; // Disconnected baseline
                    if (rssi > 75)      bars = "▂▄▆█";
                    else if (rssi > 50) bars = "▂▄▆░";
                    else if (rssi > 25) bars = "▂▄░░";
                    else if (rssi > 0)  bars = "▂░░░";
                    
                    let ssid = root.activeWifiSSID;
                    let cleanSsid = (ssid === "DISCONNECTED" || ssid === "") ? "NONE" : ssid;
                    return `WIFI_CTRL // ${cleanSsid} [${bars}]`;
                }
            }
            onClicked: control.wifiCtrlClicked()
        }

        Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }

        // ── SYSTEM CONTROL HARDWARE HUB ──
        MouseArea {
            height: parent.height
            width: sysText.implicitWidth
            Text {
                id: sysText
                anchors.verticalCenter: parent.verticalCenter
                text: "SYS_CTRL"
                font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal
            }
            onClicked: control.sysClicked()
        }

        Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgMuted }
        Text { text: root.currentTimestamp; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 10; color: Theme.fgNormal }
    }
}
