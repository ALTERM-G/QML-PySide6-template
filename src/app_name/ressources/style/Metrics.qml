pragma Singleton
import QtQuick

QtObject {
    id: metrics

    //--- Sizes ---
    readonly property QtObject size: QtObject {
        readonly property real iconButton: 50
        readonly property real iconS: 20
        readonly property real iconM: 30
        readonly property real iconL: 40
    }

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
}
