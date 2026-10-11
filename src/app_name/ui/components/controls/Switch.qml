import QtQuick
import QtQuick.Controls
import components

Switch {
    id: control
    focusPolicy: Qt.TabFocus

    indicator: Rectangle {
        implicitWidth: LayoutMetrics.size.controlHeight * 1.9
        implicitHeight: LayoutMetrics.size.controlHeight * 1.1
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: Math.min(height / 2, LayoutMetrics.radius.m)
        color: control.checked ? Theme.themeColor : Theme.borderColor
        border.color: Theme.borderColor
        border.width: control.checked ? 0 : 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: parent.height
            height: parent.height
            radius: Math.min(width / 2, LayoutMetrics.radius.m)
            color: control.down ? Theme.hoverBackgroundColor : Theme.textColor
            border.color: Theme.borderColor
            border.width: control.checked ? (control.down ? 1 : 0) : 1

            Behavior on x {
                enabled: LayoutMetrics.animationsEnabled
                NumberAnimation { duration: 100 }
            }
        }

        Behavior on color {
            enabled: LayoutMetrics.animationsEnabled
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: Typography.h4
        font.family: Typography.fontRegular
        opacity: enabled ? 1.0 : 0.3
        color: Theme.textColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + LayoutMetrics.spacing.sm
    }

    FocusRing {
        x: control.leftPadding - offset
        width: control.indicator.width + offset * 2
        height: control.indicator.height + offset * 2
        y: control.indicator.y - offset
        cornerRadius: Math.min(control.indicator.height / 2, LayoutMetrics.radius.m)
    }
}
