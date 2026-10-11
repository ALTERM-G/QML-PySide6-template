import QtQuick
import components

Rectangle {
    id: ring

    property real cornerRadius: LayoutMetrics.radius.m
    property real offset: Math.max(1.5, LayoutMetrics.border.m * 1.5)
    property color ringColor: Theme.themeColor

    x: -offset
    y: -offset
    width: parent ? parent.width + offset * 2 : 0
    height: parent ? parent.height + offset * 2 : 0
    radius: cornerRadius
    color: "transparent"
    border.width: offset
    border.color: ringColor
    visible: parent ? (parent.activeFocus && InputState.keyboard) : false
    z: 999
    enabled: false
}
