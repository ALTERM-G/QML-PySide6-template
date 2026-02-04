pragma Singleton
import QtQuick

QtObject {
    id: metrics

    //--- Spacing ---
    readonly property QtObject spacing: QtObject {
        readonly property real xxs: 8
        readonly property real xs: 16
        readonly property real sm: 24
        readonly property real md: 32
        readonly property real lg: 40
        readonly property real xl: 48
        readonly property real xxl: 64
    }

    //--- Sizes ---
    readonly property QtObject size: QtObject {
        readonly property real controlHeight: 48
        readonly property real controlHeightCompact: 42
        readonly property real buttonWidth: 180
        readonly property real comboBoxWidth: 480
        readonly property real spinBoxWidth: 120

        readonly property real iconButton: 48
        readonly property real iconS: 24
        readonly property real iconM: 36
        readonly property real iconL: 48

        readonly property real sidebarWidth: 220
    }

    //--- Radius ---
    readonly property QtObject radius: QtObject {
        readonly property real s: 4
        readonly property real m: 8
        readonly property real xl: 16
    }

    //--- Borders ---
    readonly property QtObject border: QtObject {
        readonly property real s: 1
        readonly property real m: 2
        readonly property real l: 3
    }
}
