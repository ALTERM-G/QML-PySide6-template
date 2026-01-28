pragma Singleton
import QtQuick

QtObject {

    property real w: 1280
    property real h: 720

    function bind(win) {
        w = win.width
        h = win.height
    }

    // Base scaling unit
    readonly property real unit: Math.min(w, h) / 100

    // ----------------
    // Spacing (semantic)
    // ----------------

    readonly property real xs: unit * 0.5
    readonly property real sm: unit
    readonly property real md: unit * 1.5
    readonly property real lg: unit * 2
    readonly property real xl: unit * 3

    // ----------------
    // Controls
    // ----------------

    readonly property real controlHeight: unit * 4
    readonly property real controlHeightCompact: unit * 3.5
    readonly property real buttonWidth: unit * 15
    readonly property real comboBoxWidth: unit * 24
    readonly property real spinBoxWidth: unit * 10

    readonly property real iconButtonSize: unit * 4
    readonly property real iconSizeS: unit * 1.6
    readonly property real iconSizeM: unit * 2.2
    readonly property real iconSizeL: unit * 3

    // ----------------
    // Radius & borders
    // ----------------

    readonly property real radiusS: unit * 0.5
    readonly property real radiusM: unit
    readonly property real radiusXL: unit * 2

    readonly property real borderSmall: 1
    readonly property real borderNormal: 2
    readonly property real borderThick: 3

    // ----------------
    // Panels
    // ----------------

    readonly property real sidebarWidth: Math.max(220, w * 0.18)
}
