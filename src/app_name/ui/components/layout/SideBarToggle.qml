import QtQuick
import components

Rectangle {
    id: root

    property bool collapsed: false

    signal toggled()

    width: LayoutMetrics.size.iconButton
    height: LayoutMetrics.size.iconButton
    radius: LayoutMetrics.radius.m
    color: mouseArea.containsMouse ? Theme.hoverBackgroundColor : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    SVGObject {
        anchors.centerIn: parent
        width: LayoutMetrics.size.iconS
        height: LayoutMetrics.size.iconS
        path: root.collapsed ? SVGLibrary.chevronRight : SVGLibrary.chevronLeft
        color: Theme.textColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
