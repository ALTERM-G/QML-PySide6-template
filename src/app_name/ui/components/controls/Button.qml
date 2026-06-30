import QtQuick
import components

Rectangle {
    id: root

    property string buttonText
    property string iconPath: ""
    property bool run: false
    property bool primary: false
    property real heightMultiplier: 1.0

    signal pressed()

    width: LayoutMetrics.size.buttonWidth
    height: LayoutMetrics.size.controlHeight * heightMultiplier
    radius: LayoutMetrics.radius.m
    border.color: primary ? Theme.themeColor : Theme.borderColor
    border.width: LayoutMetrics.border.l
    color: primary ? Theme.themeColor : (mouseArea.containsMouse ? Theme.hoverBackgroundColor : Theme.backgroundColor)

    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: root.buttonText
    Accessible.onPressAction: root.doPress()

    Keys.onReturnPressed: root.doPress()
    Keys.onEnterPressed: root.doPress()

    function doPress() {
        root.pressed()
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: LayoutMetrics.spacing.sm

        SVGObject {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            width: LayoutMetrics.size.iconS
            height: LayoutMetrics.size.iconS
            visible: root.iconPath !== ""
            path: root.iconPath
            color: primary ? Theme.hoverTextColor : (mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor)
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.buttonText
            font.pixelSize: Typography.h4
            font.family: Typography.fontBold
            font.weight: Font.Bold
            color: primary ? Theme.hoverTextColor : (mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.doPress()
    }
}
