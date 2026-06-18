import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
  id: control
  spacing: 8
  Layout.fillHeight: true
  Layout.alignment: Qt.AlignRight

  // ── EXTERNAL CONTROL INTERFACES ──
  signal btClicked()
  signal wifiCtrlClicked()
  signal sysClicked()

  // Bluetooth Module
  MouseArea {
    Layout.fillHeight: true
    width: btText.implicitWidth
    cursorShape: Qt.PointingHandCursor
    onClicked: control.btClicked()

    Text {
      id: btText
      anchors.verticalCenter: parent.verticalCenter
      text: root.bluetoothTelemetry
      font.family: Theme.fontMono
      font.pixelSize: 9
      color: Theme.fgNormal
    }
  }

  Text {
    text: "│"
    Layout.alignment: Qt.AlignVCenter
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgMuted
  }

  // Battery Status Component
  RowLayout {
    spacing: 3
    Layout.fillHeight: true

    Text {
      Layout.alignment: Qt.AlignVCenter
      text: {
        var c = root.batteryCapacity;
        if (c >= 90) return "\uf0b9";
        if (c >= 60) return "\uf0be";
        if (c >= 30) return "\uf0bd";
        if (c >= 10) return "\uf0bb";
        return "\uf0ba";
      }
      font.family: Theme.fontMono
      font.pixelSize: 9
      color: Theme.accentBlue
    }

    Rectangle {
      Layout.alignment: Qt.AlignVCenter
      width: 20
      height: 5
      color: Theme.borderMain

      Rectangle {
        width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
        height: parent.height
        color: root.batteryCapacity <= 15 ? "#FF5555" : Theme.accentBlue
      }
    }

    Text {
      Layout.alignment: Qt.AlignVCenter
      text: root.batteryCapacity + "%"
      font.family: Theme.fontMono
      font.pixelSize: 9
      color: root.batteryCapacity <= 15 ? "#FF5555" : Theme.fgNormal
    }
  }

  Text {
    text: "│"
    Layout.alignment: Qt.AlignVCenter
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgMuted
  }

  // WiFi Module
  MouseArea {
    Layout.fillHeight: true
    width: Math.min(wifiText.implicitWidth, 140)
    cursorShape: Qt.PointingHandCursor
    onClicked: control.wifiCtrlClicked()

    Text {
      id: wifiText
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width
      elide: Text.ElideRight
      font.family: Theme.fontMono
      font.pixelSize: 9
      color: Theme.fgNormal
      text: {
        var rssi = root.wifiSignalStrength;
        var bars = "\u2591\u2591\u2591\u2591";
        if (rssi > 75)      bars = "\u2582\u2584\u2586\u2588";
        else if (rssi > 50) bars = "\u2582\u2584\u2586\u2591";
        else if (rssi > 25) bars = "\u2582\u2584\u2591\u2591";
        else if (rssi > 0)  bars = "\u2582\u2591\u2591\u2591";
        var ssid = root.activeWifiSSID;
        var clean = (ssid === "DISCONNECTED" || ssid === "") ? "NONE" : ssid;
        return "WIFI // " + clean + " [" + bars + "]";
      }
    }
  }

  Text {
    text: "│"
    Layout.alignment: Qt.AlignVCenter
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgMuted
  }

  // System Dashboard Toggle
  MouseArea {
    Layout.fillHeight: true
    width: sysText.implicitWidth
    cursorShape: Qt.PointingHandCursor
    onClicked: control.sysClicked()

    Text {
      id: sysText
      anchors.verticalCenter: parent.verticalCenter
      text: "SYS"
      font.family: Theme.fontMono
      font.pixelSize: 9
      color: Theme.fgNormal
    }
  }

  Text {
    text: "│"
    Layout.alignment: Qt.AlignVCenter
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgMuted
  }

  // Live Clock Telemetry
  Text {
    text: root.currentTimestamp
    Layout.alignment: Qt.AlignVCenter
    font.family: Theme.fontMono
    font.pixelSize: 9
    color: Theme.fgNormal
  }
}
