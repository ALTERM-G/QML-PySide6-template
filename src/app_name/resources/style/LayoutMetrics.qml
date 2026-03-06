pragma Singleton
import QtQuick

QtObject {
    property var window
    property real w: window ? window.width : 1280
    property real h: window ? window.height : 720

    function bindToWindow(win) {
        window = win
    }

    function initialize(factor) {
        scaleFactor = factor
    }

    property real scaleFactor: 1.0
    property real unit: (Math.min(w, h) / 100) * scaleFactor
    property real sideBarWidthOverride: -1

    function setScaleFactor(factor) {
        scaleFactor = factor
    }

    onWChanged: sideBarWidthOverride = -1
    onHChanged: sideBarWidthOverride = -1
    onScaleFactorChanged: sideBarWidthOverride = -1

    //--- Spacing ---
    property QtObject spacing: QtObject {
        property real xxs: unit * 0.25
        property real xs: unit * 0.5
        property real sm: unit
        property real md: unit * 1.5
        property real lg: unit * 2
        property real xl: unit * 3
        property real xxl: unit * 4
    }

    //--- Sizes ---
    property QtObject size: QtObject {
        property real topBarHeight: unit * 7
        property real sideBarWidth: sideBarWidthOverride > 0 ? sideBarWidthOverride : unit * 50
        property real controlHeight: unit * 2.5
        property real controlHeightCompact: unit * 2
        property real buttonWidth: unit * 15
        property real comboBoxWidth: unit * 40
        property real sliderWidth: unit * 25
        property real spinBoxWidth: unit * 10

        property real iconS: unit * 2
        property real iconM: unit * 3
        property real iconL: unit * 4
    }

    //--- Radius ---
    property QtObject radius: QtObject {
        property real s: unit * 0.5
        property real m: unit
        property real xl: unit * 2
    }

    //--- Borders ---
    property QtObject border: QtObject {
        property real s: unit * 0.125
        property real m: unit * 0.25
        property real l: unit * 0.375
    }
}
