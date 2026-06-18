import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
  id: root
  implicitHeight: 42

  property var barValues: []
  property bool cavaActive: false

  // Subtle dark backdrop bar
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.2)
    visible: root.cavaActive
  }

  Process {
    id: cavaProc
    command: ["bash", "-c",
      "cava -p \"$HOME/my_dotfiles/quickshell/.config/quickshell/cava_config\" 2>/dev/null"
    ]
    running: false
    stdout: SplitParser {
      onRead: (line) => {
        // cava noncurses outputs space-separated integers per frame
        var parts = line.trim().split(/\s+/);
        var vals = [];
        for (var i = 0; i < parts.length; i++) {
          var n = parseFloat(parts[i]);
          if (!isNaN(n)) vals.push(n);
        }
        if (vals.length > 0) {
          root.barValues = vals;
          canvas.requestPaint();
        }
      }
    }
    onStarted: root.cavaActive = true
  }

  Timer {
    interval: 2000; running: true; repeat: false; triggeredOnStart: true
    onTriggered: { cavaProc.running = true; }
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    visible: root.cavaActive

    onPaint: {
      var ctx = canvas.getContext("2d");
      if (!ctx) return;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      var vals = root.barValues;
      if (vals.length < 2) return;

      var w = canvas.width;
      var h = canvas.height;
      var pad = w * 0.02;
      var drawW = w - 2 * pad;
      var barW = drawW / (vals.length - 1);

      // Normalize values to 0-1 range (cava outputs 0-100 or 0-1)
      var maxVal = 1.0;
      for (var i = 0; i < vals.length; i++) {
        if (vals[i] > maxVal) maxVal = vals[i];
      }
      if (maxVal > 100) maxVal = 100;
      if (maxVal < 0.01) maxVal = 0.01;

      var grad = ctx.createLinearGradient(0, 0, w, 0);
      grad.addColorStop(0.0, "rgba(100, 180, 255, 0.15)");
      grad.addColorStop(0.3, "rgba(100, 180, 255, 0.30)");
      grad.addColorStop(0.5, "rgba(100, 180, 255, 0.45)");
      grad.addColorStop(0.7, "rgba(100, 180, 255, 0.30)");
      grad.addColorStop(1.0, "rgba(100, 180, 255, 0.15)");

      ctx.beginPath();
      ctx.fillStyle = grad;

      var baseline = h;
      function barTop(i) {
        var nv = vals[i] / maxVal;
        return baseline - nv * h * 0.75;
      }
      function xOf(i) { return pad + i * barW; }

      ctx.moveTo(xOf(0), baseline);
      ctx.lineTo(xOf(0), barTop(0));
      for (var i = 0; i < vals.length - 1; i++) {
        var xC = xOf(i), yC = barTop(i);
        var xN = xOf(i + 1), yN = barTop(i + 1);
        ctx.quadraticCurveTo(xC, yC, (xC + xN) / 2, (yC + yN) / 2);
      }
      var last = vals.length - 1;
      ctx.lineTo(xOf(last), barTop(last));
      ctx.lineTo(xOf(last), baseline);
      ctx.closePath();
      ctx.fill();
    }
  }
}
