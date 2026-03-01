import QtQuick
import components

Rectangle {
    id: root

    // ---------------- Properties ----------------
    property string buttonText
    property string iconPath: ""
    property bool run: false

    signal pressed()

    // ---------------- Geometry & Style ----------------
    width: LayoutMetrics.size.buttonWidth
    height: LayoutMetrics.size.controlHeight
    radius: LayoutMetrics.radius.m
    border.color: Theme.borderColor
    border.width: LayoutMetrics.border.l
    color: mouseArea.containsMouse ? Theme.hoverBackgroundColor : Theme.backgroundColor

    // ---------------- Behavior ----------------
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

    // ---------------- Content ----------------
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
            color: mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.buttonText
            font.pixelSize: Typography.h4
            font.family: Typography.fontBold
            color: mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    // ---------------- Interactions ----------------
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.doPress()
    }
}
