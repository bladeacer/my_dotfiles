import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
  id: control
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
    spacing: 8

    // Bluetooth
    MouseArea {
      height: parent.height
      width: btText.implicitWidth
      Text {
        id: btText
        anchors.verticalCenter: parent.verticalCenter
        text: root.bluetoothTelemetry
        font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal
      }
      onClicked: control.btClicked()
    }

    Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }

    // Battery with progress bar glyph
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 3
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
          var c = root.batteryCapacity;
          if (c >= 90) return "\uf0b9";
          if (c >= 60) return "\uf0be";
          if (c >= 30) return "\uf0bd";
          if (c >= 10) return "\uf0bb";
          return "\uf0ba";
        }
        font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.accentBlue
      }
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 24; height: 5
        color: Theme.borderMain
        Rectangle {
          width: parent.width * Math.min(1, Math.max(0, root.batteryCapacity / 100))
          height: parent.height
          color: root.batteryCapacity <= 15 ? "#FF5555" : Theme.accentBlue
        }
      }
    }

    Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }

    // WiFi
    MouseArea {
      height: parent.height
      width: wifiText.implicitWidth
      Text {
        id: wifiText
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal
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
      onClicked: control.wifiCtrlClicked()
    }

    Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }

    // System control
    MouseArea {
      height: parent.height
      width: sysText.implicitWidth
      Text {
        id: sysText
        anchors.verticalCenter: parent.verticalCenter
        text: "SYS"
        font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal
      }
      onClicked: control.sysClicked()
    }

    Text { text: "│"; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgMuted }
    Text { text: root.currentTimestamp; anchors.verticalCenter: parent.verticalCenter; font.family: Theme.fontMono; font.pixelSize: 9; color: Theme.fgNormal }
  }
}
