import QtQuick
import QtQuick.Controls
import components

Slider {
    id: control

    implicitWidth: LayoutMetrics.size.sliderWidth
    implicitHeight: LayoutMetrics.size.controlHeight

    property color _trackColor: Theme.borderColor
    property color _progressColor: Theme.themeColor
    property color _handleColor: Theme.textColor
    property color _handleHoverColor: Theme.themeColor

    background: Rectangle {
        x: LayoutMetrics.spacing.xs
        y: parent.height / 2 - height / 2
        width: parent.width - LayoutMetrics.spacing.xs * 2
        height: LayoutMetrics.border.m * 2
        radius: height / 2
        color: control.enabled ? _trackColor : Theme.textColor

        Rectangle {
            height: parent.height
            width: control.position * parent.width
            radius: parent.radius
            color: control.enabled ? _progressColor : Theme.textColor
            opacity: control.enabled ? 1.0 : 0.3
        }
    }

    handle: Rectangle {
        x: LayoutMetrics.spacing.xs + control.position * (parent.width - LayoutMetrics.spacing.xs * 2) - width / 2
        y: parent.height / 2 - height / 2
        width: control.hovered ? LayoutMetrics.size.iconS : LayoutMetrics.size.iconS - 4
        height: control.hovered ? LayoutMetrics.size.iconS : LayoutMetrics.size.iconS - 4
        radius: width / 2
        color: control.hovered ? _handleHoverColor : _handleColor
        opacity: control.enabled ? 1.0 : 0.3

        Behavior on width { NumberAnimation { duration: 50 } }
        Behavior on height { NumberAnimation { duration: 50 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }

    Keys.onUpPressed: increment()
    Keys.onDownPressed: decrement()
    Keys.onLeftPressed: decrement()
    Keys.onRightPressed: increment()
}
