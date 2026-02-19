import QtQuick
import QtQuick.Controls

TextField {
    id: control
    width: LayoutMetrics.size.buttonWidth
    height: LayoutMetrics.size.controlHeight
    
    font.pixelSize: Typography.h4
    font.family: Typography.fontRegular
    color: Theme.textColor
    selectionColor: Theme.themeColor
    selectedTextColor: Theme.hoverTextColor
    selectByMouse: true
    verticalAlignment: Text.AlignVCenter
    
    placeholderTextColor: Theme.dividerColor

    background: Rectangle {
        implicitWidth: control.width
        implicitHeight: control.height
        color: control.activeFocus ? Theme.backgroundColor : Theme.backgroundColor
        border.color: control.activeFocus ? Theme.themeColor : Theme.borderColor
        border.width: LayoutMetrics.border.m
        radius: LayoutMetrics.radius.m

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
