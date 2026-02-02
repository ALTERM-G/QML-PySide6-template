pragma Singleton
import QtQuick

QtObject {
    property var window
    readonly property real w: window ? window.width : 1280
    readonly property real h: window ? window.height : 720

    function bindToWindow(win) {
        window = win
    }

    readonly property real unit: Math.min(w, h) / 100

    //--- Spacing ---
    readonly property QtObject spacing: QtObject {
        readonly property real xxs: unit * 0.25
        readonly property real xs: unit * 0.5
        readonly property real sm: unit
        readonly property real md: unit * 1.5
        readonly property real lg: unit * 2
        readonly property real xl: unit * 3
        readonly property real xxl: unit * 4
    }

    //--- Sizes ---
    readonly property QtObject size: QtObject {
        readonly property real controlHeight: unit * 4
        readonly property real controlHeightCompact: unit * 3.5
        readonly property real buttonWidth: unit * 15
        readonly property real comboBoxWidth: unit * 40
        readonly property real spinBoxWidth: unit * 10

        readonly property real iconButton: unit * 4
        readonly property real iconS: unit * 2
        readonly property real iconM: unit * 3
        readonly property real iconL: unit * 4

        readonly property real sidebarWidth: Math.max(220, w * 0.18)
    }

    //--- Radius ---
    readonly property QtObject radius: QtObject {
        readonly property real s: unit * 0.5
        readonly property real m: unit
        readonly property real xl: unit * 2
    }

    //--- Borders ---
    readonly property QtObject border: QtObject {
        readonly property real s: 1
        readonly property real m: 2
        readonly property real l: 3
    }
}
