pragma Singleton
import QtQuick

QtObject {
    id: metrics

    property real scaleFactor: 1.0
    readonly property real baseUnit: 8

    //--- Spacing ---
    readonly property QtObject spacing: QtObject {
        readonly property real xxs: baseUnit * 1 * scaleFactor
        readonly property real xs: baseUnit * 2 * scaleFactor
        readonly property real sm: baseUnit * 3 * scaleFactor
        readonly property real md: baseUnit * 4 * scaleFactor
        readonly property real lg: baseUnit * 5 * scaleFactor
        readonly property real xl: baseUnit * 6 * scaleFactor
        readonly property real xxl: baseUnit * 8 * scaleFactor
    }

    //--- Sizes ---
    readonly property QtObject size: QtObject {
        readonly property real controlHeight: baseUnit * 6 * scaleFactor
        readonly property real controlHeightCompact: baseUnit * 5.25 * scaleFactor
        readonly property real buttonWidth: baseUnit * 22.5 * scaleFactor
        readonly property real comboBoxWidth: baseUnit * 60 * scaleFactor
        readonly property real spinBoxWidth: baseUnit * 15 * scaleFactor

        readonly property real iconButton: baseUnit * 6 * scaleFactor
        readonly property real iconS: baseUnit * 3 * scaleFactor
        readonly property real iconM: baseUnit * 4.5 * scaleFactor
        readonly property real iconL: baseUnit * 6 * scaleFactor

        readonly property real sidebarWidth: Math.max(220, 220 * scaleFactor)
    }

    //--- Radius ---
    readonly property QtObject radius: QtObject {
        readonly property real s: baseUnit * 0.5 * scaleFactor
        readonly property real m: baseUnit * 1 * scaleFactor
        readonly property real xl: baseUnit * 2 * scaleFactor
    }

    //--- Borders ---
    readonly property QtObject border: QtObject {
        readonly property real s: baseUnit * 0.125 * scaleFactor
        readonly property real m: baseUnit * 0.25 * scaleFactor
        readonly property real l: baseUnit * 0.375 * scaleFactor
    }
}
