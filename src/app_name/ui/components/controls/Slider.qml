import QtQuick
import QtQuick.Controls
import components

Slider {
    id: control

    implicitWidth: LayoutMetrics.size.sliderWidth
    implicitHeight: LayoutMetrics.size.controlHeight
    focusPolicy: Qt.TabFocus

    property bool discrete: false
    property real step: 1
    stepSize: discrete ? step : 0
    snapMode: Slider.SnapAlways

    readonly property real keyStep: (discrete && step > 0) ? step : Math.max(1, (to - from) / 50)

    function stepBy(direction) {
        var amount = (discrete && step > 0) ? step : keyStep
        var next = Math.max(from, Math.min(to, value + direction * amount))
        if (next !== value) {
            value = next
            moved()
        }
    }

    property color _trackColor: Theme.borderColor
    property color _progressColor: Theme.themeColor
    property color _handleColor: Theme.textColor
    property color _handleHoverColor: Theme.themeColor

    onValueChanged: {
        if (discrete && step > 0) {
            var snapped = Math.round((value - from) / step) * step + from;
            if (snapped !== value) value = snapped;
        }
    }

    background: Rectangle {
        x: LayoutMetrics.spacing.xs
        y: parent.height / 2 - height / 2
        width: parent.width - LayoutMetrics.spacing.xs * 2
        height: LayoutMetrics.border.m * 2
        radius: Math.min(height / 2, LayoutMetrics.radius.m)
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
        width: (control.hovered || control.pressed) ? LayoutMetrics.size.iconS : LayoutMetrics.size.iconS - 4
        height: (control.hovered || control.pressed) ? LayoutMetrics.size.iconS : LayoutMetrics.size.iconS - 4
        radius: Math.min(width / 2, LayoutMetrics.radius.m)
        color: (control.hovered || control.pressed) ? _handleHoverColor : _handleColor
        opacity: control.enabled ? 1.0 : 0.3

        Behavior on width { enabled: LayoutMetrics.animationsEnabled; NumberAnimation { duration: 50 } }
        Behavior on height { enabled: LayoutMetrics.animationsEnabled; NumberAnimation { duration: 50 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }

    Keys.onUpPressed: stepBy(1)
    Keys.onDownPressed: stepBy(-1)
    Keys.onLeftPressed: stepBy(-1)
    Keys.onRightPressed: stepBy(1)

    FocusRing {}
}
