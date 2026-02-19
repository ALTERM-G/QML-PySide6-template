import QtQuick
import QtQuick.Controls

Switch {
    id: control

    indicator: Rectangle {
        implicitWidth: LayoutMetrics.size.controlHeight
        implicitHeight: LayoutMetrics.size.controlHeight / 2
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: control.checked ? Theme.themeColor : Theme.borderColor
        border.color: Theme.borderColor
        border.width: control.checked ? 0 : 1

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: parent.height
            height: parent.height
            radius: width / 2
            color: control.down ? Theme.hoverTextColor : Theme.textColor
            border.color: Theme.borderColor
            border.width: control.checked ? (control.down ? 1 : 0) : 1
            
            Behavior on x {
                NumberAnimation { duration: 100 }
            }
        }
        
        Behavior on color {
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
}
