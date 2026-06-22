pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: fws

    readonly property var _w: typeof ToplevelManager !== 'undefined' ? ToplevelManager.activeToplevel : null

    // Set externally by shell.qml telemetry handler (KDE fallback)
    property string _kdeTitle: ""
    property string _kdeAppId: ""

    readonly property string title: _w && typeof _w.title === 'string' && _w.title !== "" ? _w.title : _kdeTitle
    readonly property string appId: _w && typeof _w.appId === 'string' && _w.appId !== "" ? _w.appId : _kdeAppId
    readonly property string wmClass: _w && typeof _w.wmClass === 'string' && _w.wmClass !== "" ? _w.wmClass : _kdeAppId
}
