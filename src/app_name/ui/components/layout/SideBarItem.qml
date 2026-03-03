import QtQuick
import components

Rectangle {
    id: root

    property string itemText: ""
    property url itemIcon
    property bool isActive: false
    property bool collapsed: false

    signal clicked()

    width: parent.width
    height: LayoutMetrics.size.controlHeight
    color: isActive ? Theme.themeColor : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: LayoutMetrics.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        spacing: LayoutMetrics.spacing.sm

        SVGObject {
            anchors.verticalCenter: parent.verticalCenter
            width: LayoutMetrics.size.iconS
            height: LayoutMetrics.size.iconS
            path: root.itemIcon
            color: isActive ? Theme.hoverTextColor : Theme.textColor
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.itemText
            font.pixelSize: Typography.h4
            font.family: Typography.fontBold
            color: isActive ? Theme.hoverTextColor : Theme.textColor

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    visible: !collapsed

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (!root.isActive) {
                root.color = Theme.hoverBackgroundColor
            }
        }
        onExited: {
            if (!root.isActive) {
                root.color = "transparent"
            }
        }
        onClicked: root.clicked()
    }
}
