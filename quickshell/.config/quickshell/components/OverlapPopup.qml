import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: popupWindow
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool active: false
    property int targetX: 0
    property int targetY: 32
    default property alias content: container.children

    FocusScope {
        anchors.fill: parent
        focus: popupWindow.active

        Keys.onEscapePressed: popupWindow.active = false
        MouseArea { anchors.fill: parent; onClicked: popupWindow.active = false }

        Item {
            id: container
            x: popupWindow.targetX
            y: popupWindow.targetY
            width: children.length > 0 ? children[0].width : 0
            height: children.length > 0 ? children[0].height : 0
            MouseArea { anchors.fill: parent; propagateComposedEvents: false }
        }
    }
}
