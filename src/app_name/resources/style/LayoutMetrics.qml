pragma Singleton
import QtQuick

QtObject {
    id: lm
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
    property bool isContinuous: true
    property real unit: ((isContinuous ? Math.min(w, h) : 720) / 100) * scaleFactor
    property real sideBarWidthOverride: -1

    function setScaleFactor(factor) {
        scaleFactor = factor
    }

    function setIsContinuous(value) {
        isContinuous = value
    }

    property real cornerRadiusFactor: 1.0

    function setCornerRadiusFactor(factor) {
        cornerRadiusFactor = factor
    }

    property bool animationsEnabled: true

    function setAnimationsEnabled(value) {
        animationsEnabled = value
    }

    onWChanged: sideBarWidthOverride = -1
    onHChanged: sideBarWidthOverride = -1
    onScaleFactorChanged: sideBarWidthOverride = -1
    onIsContinuousChanged: sideBarWidthOverride = -1
    onAnimationsEnabledChanged: sideBarWidthOverride = -1

    //--- Spacing ---
    property QtObject spacing: QtObject {
        property real xxs: lm.unit * 0.25
        property real xs: lm.unit * 0.5
        property real sm: lm.unit
        property real md: lm.unit * 1.5
        property real lg: lm.unit * 2
        property real xl: lm.unit * 3
        property real xxl: lm.unit * 4
    }

    //--- Sizes ---
    property QtObject size: QtObject {
        property real topBarHeight: lm.unit * 7
        property real sideBarWidth: sideBarWidthOverride > 0 ? sideBarWidthOverride : lm.unit * 50
        property real controlHeightHuge: lm.unit * 4.5
        property real controlHeight: lm.unit * 2.5
        property real controlHeightCompact: lm.unit * 2
        property real buttonWidth: lm.unit * 15
        property real comboBoxWidth: lm.unit * 40
        property real sliderWidth: lm.unit * 25
        property real spinBoxWidth: lm.unit * 10
        property real tabBarWidth: lm.unit * 50
        property real shortcutLabelWidth: lm.unit * 24
        property real shortcutControlWidth: lm.unit * 18

        property real iconS: lm.unit * 2
        property real iconM: lm.unit * 3
        property real iconL: lm.unit * 4
        property real iconXl: lm.unit * 5
    }

    //--- Radius ---
    property QtObject radius: QtObject {
        property real s: lm.unit * 0.5 * cornerRadiusFactor
        property real m: lm.unit * cornerRadiusFactor
        property real xl: lm.unit * 2 * cornerRadiusFactor
    }

    //--- Borders ---
    property QtObject border: QtObject {
        property real s: lm.unit * 0.125
        property real m: lm.unit * 0.25
        property real l: lm.unit * 0.375
    }
}
