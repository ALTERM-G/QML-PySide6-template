pragma Singleton
import QtQuick

QtObject {
    id: metrics

    property real scaleFactor: 1.0
    readonly property real baseUnit: 8

    function setScaleFactor(factor) {
        scaleFactor = factor
    }

    function initialize(factor) {
        scaleFactor = factor
    }

    //--- Spacing ---
    property QtObject spacing: QtObject {
        property real xxs: baseUnit * 1 * scaleFactor
        property real xs: baseUnit * 2 * scaleFactor
        property real sm: baseUnit * 3 * scaleFactor
        property real md: baseUnit * 4 * scaleFactor
        property real lg: baseUnit * 5 * scaleFactor
        property real xl: baseUnit * 6 * scaleFactor
        property real xxl: baseUnit * 8 * scaleFactor
    }

    //--- Sizes ---
    property QtObject size: QtObject {
        property real controlHeight: baseUnit * 6 * scaleFactor
        property real controlHeightCompact: baseUnit * 5.25 * scaleFactor
        property real buttonWidth: baseUnit * 22.5 * scaleFactor
        property real comboBoxWidth: baseUnit * 60 * scaleFactor
        property real spinBoxWidth: baseUnit * 15 * scaleFactor

        property real iconButton: baseUnit * 6 * scaleFactor
        property real iconS: baseUnit * 3 * scaleFactor
        property real iconM: baseUnit * 4.5 * scaleFactor
        property real iconL: baseUnit * 6 * scaleFactor

        property real sidebarWidth: Math.max(220, 220 * scaleFactor)
    }

    //--- Radius ---
    property QtObject radius: QtObject {
        property real s: baseUnit * 0.5 * scaleFactor
        property real m: baseUnit * 1 * scaleFactor
        property real xl: baseUnit * 2 * scaleFactor
    }

    //--- Borders ---
    property QtObject border: QtObject {
        property real s: baseUnit * 0.125 * scaleFactor
        property real m: baseUnit * 0.25 * scaleFactor
        property real l: baseUnit * 0.375 * scaleFactor
    }
}
