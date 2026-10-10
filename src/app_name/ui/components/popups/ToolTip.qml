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
        font.weight: Font.Bold
        font.pointSize: Typography.h6
        padding: LayoutMetrics.spacing.xs
    }

    enter: LayoutMetrics.animationsEnabled ? toolTipFadeEnter : toolTipInstantEnter
    exit: LayoutMetrics.animationsEnabled ? toolTipFadeExit : toolTipInstantExit

    Transition {
        id: toolTipInstantEnter
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 0
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 0
            }
        }
    }

    Transition {
        id: toolTipInstantExit
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 0
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.85
                duration: 0
            }
        }
    }

    Transition {
        id: toolTipFadeEnter
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

    Transition {
        id: toolTipFadeExit
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