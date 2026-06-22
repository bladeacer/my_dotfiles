pragma Singleton
import QtQuick

QtObject {
    readonly property string fontMono: "Departure Mono Nerd Font Mono"

    readonly property color bgNormal:    Qt.rgba(22/255, 24/255, 33/255, 1.0)
    readonly property color bgHeader:    Qt.rgba(30/255, 33/255, 50/255, 1.0)
    readonly property color bgAlt:       Qt.rgba(46/255, 50/255, 68/255, 1.0)
    readonly property color fgNormal:    Qt.rgba(198/255, 200/255, 209/255, 1.0)
    readonly property color fgMuted:     Qt.rgba(107/255, 112/255, 137/255, 1.0)
    readonly property color accentBlue:  Qt.rgba(132/255, 160/255, 198/255, 1.0)
    readonly property color accentGreen: Qt.rgba(180/255, 190/255, 130/255, 1.0)
    readonly property color accentRed:   Qt.rgba(226/255, 120/255, 120/255, 1.0)
    readonly property color accentOrange:Qt.rgba(226/255, 164/255, 120/255, 1.0)
    readonly property color accentPurple:Qt.rgba(119/255, 89/255, 180/255, 1.0)
    readonly property color accentPink:  Qt.rgba(190/255, 130/255, 160/255, 1.0)
    readonly property color selectionBg: Qt.rgba(69/255, 75/255, 104/255, 1.0)
    readonly property color widgetBg:    Qt.rgba(30/255, 33/255, 50/255, 0.92)
    readonly property color borderMain:  Qt.rgba(132/255, 160/255, 198/255, 0.18)

    readonly property int borderThin: 1
    readonly property int barHeight: 28
    readonly property int padding: 12
    readonly property int textSm: 11
    readonly property int textMd: 11
    readonly property int textLg: 11
    readonly property int animDur: 140

    function blockMeter(val) {
        if (val > 75) return "\u2582\u2584\u2586\u2588"
        if (val > 50) return "\u2582\u2584\u2586\u2591"
        if (val > 25) return "\u2582\u2584\u2591\u2591"
        if (val > 0)  return "\u2582\u2591\u2591\u2591"
        return "\u2591\u2591\u2591\u2591"
    }

    function frameHeader(label, width) {
        var inner = "\u2500\u2500 [ " + label + " ]"
        width = width || 42
        var pad = width - inner.length
        if (pad < 0) pad = 0
        return "\u250c" + inner + "\u2500".repeat(pad) + "\u2510"
    }

    function frameFooter(width) {
        width = width || 42
        return "\u2514" + "\u2500".repeat(width) + "\u2518"
    }
}
