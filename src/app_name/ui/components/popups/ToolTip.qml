import QtQuick
import QtQuick.Controls

ToolTip {
    id: customToolTip

    background: Rectangle {
        radius: LayoutMetrics.radius.m
        color: Theme.backgroundColor
        border.color: Theme.borderColor
        border.width: LayoutMetrics.border.s
    }

    contentItem: Text {
        text: customToolTip.text
        color: Theme.textColor
        font.family: Typography.fontBold
        font.pointSize: 10
        padding: LayoutMetrics.spacing.xs
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.85
                duration: 200
                easing.type: Easing.InQuad
            }
        }
    }
}
