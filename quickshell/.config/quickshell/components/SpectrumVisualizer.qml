import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
  id: root
  implicitHeight: 14

  property var barData: []
  property bool cavaActive: false

  function barHeight(ch) {
    if (ch >= '\u2581' && ch <= '\u2588') return ch.charCodeAt(0) - 0x2580;
    return 0;
  }

  Process {
    id: cavaProc
    command: ["bash", "-c",
      "which cava 2>/dev/null || exit 1; " +
      "cava -p \"$HOME/my_dotfiles/quickshell/.config/quickshell/cava_config\" 2>/dev/null"
    ]
    running: false
    stdout: SplitParser {
      onRead: (line) => {
        var data = [];
        for (var i = 0; i < line.length; i++) {
          data.push(root.barHeight(line[i]));
        }
        root.barData = data;
        canvas.requestPaint();
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
      var ctx = getContext("2d");
      if (!ctx) return;
      ctx.clearRect(0, 0, width, height);

      var data = root.barData;
      if (data.length < 2) return;

      var hPad = width * 0.02;
      var drawW = width - 2 * hPad;
      var barW = drawW / (data.length - 1);

      var grad = ctx.createLinearGradient(0, 0, width, 0);
      grad.addColorStop(0.0, Qt.rgba(1, 1, 1, 0.03));
      grad.addColorStop(0.3, Qt.rgba(1, 1, 1, 0.08));
      grad.addColorStop(0.5, Qt.rgba(1, 1, 1, 0.10));
      grad.addColorStop(0.7, Qt.rgba(1, 1, 1, 0.08));
      grad.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.03));

      ctx.beginPath();
      ctx.fillStyle = grad;

      var baseline = height;
      function barTop(i) { return baseline - (data[i] / 8) * baseline * 0.85; }
      function xOf(i) { return hPad + i * barW; }

      ctx.moveTo(xOf(0), baseline);
      ctx.lineTo(xOf(0), barTop(0));
      for (var i = 0; i < data.length - 1; i++) {
        var xC = xOf(i), yC = barTop(i);
        var xN = xOf(i + 1), yN = barTop(i + 1);
        ctx.quadraticCurveTo(xC, yC, (xC + xN) / 2, (yC + yN) / 2);
      }
      var last = data.length - 1;
      ctx.lineTo(xOf(last), barTop(last));
      ctx.lineTo(xOf(last), baseline);
      ctx.closePath();
      ctx.fill();
    }
  }
}
