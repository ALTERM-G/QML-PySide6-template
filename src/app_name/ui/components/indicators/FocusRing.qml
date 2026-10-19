import QtQuick
import components

Rectangle {
    id: ring

    property real cornerRadius: LayoutMetrics.radius.m
    property real offset: Math.max(1.5, LayoutMetrics.border.m * 1.5)
    property color ringColor: Theme.themeColor
    property Item focusItem: parent
    property bool ringVisible: focusItem ? (focusItem.activeFocus && InputState.navigating) : false

    x: -offset
    y: -offset
    width: parent ? parent.width + offset * 2 : 0
    height: parent ? parent.height + offset * 2 : 0
    radius: cornerRadius
    color: "transparent"
    border.width: offset
    border.color: ringColor
    visible: ringVisible
    z: 999
    enabled: false
}
