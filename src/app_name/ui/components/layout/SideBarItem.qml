import QtQuick
import components

Rectangle {
    id: root

    property string itemText: ""
    property url itemIcon
    property bool isActive: false
    property bool collapsed: false
    property bool showFocusRing: false
    property bool hovered: false

    signal clicked()

    width: parent.width
    height: LayoutMetrics.size.sideBarItemHeight
    color: "transparent"
    visible: !collapsed

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.isActive ? Theme.themeColor : Theme.inputBackgroundColor
        opacity: root.isActive || root.hovered ? 1.0 : 0.0

        Behavior on color {
            enabled: LayoutMetrics.animationsEnabled
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on opacity {
            enabled: LayoutMetrics.animationsEnabled
            NumberAnimation {
                duration: 150
            }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: LayoutMetrics.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        spacing: LayoutMetrics.spacing.sm

        SVGObject {
            id: itemIcon
            anchors.verticalCenter: parent.verticalCenter
            width: LayoutMetrics.size.iconM
            height: LayoutMetrics.size.iconM
            path: root.itemIcon
            color: root.isActive ? Theme.hoverTextColor : Theme.textColor

            Behavior on color {
                enabled: LayoutMetrics.animationsEnabled
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.itemText
            font.pixelSize: Typography.h4
            font.family: Typography.fontBold
            font.weight: Font.Bold
            color: root.isActive ? Theme.hoverTextColor : Theme.textColor
            elide: Text.ElideRight
            width: root.width - (itemIcon.width + parent.spacing + LayoutMetrics.spacing.md * 2)

            Behavior on color {
                enabled: LayoutMetrics.animationsEnabled
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.clicked()
    }

    FocusRing {
        cornerRadius: 0
        ringVisible: root.activeFocus && root.showFocusRing && InputState.keyboard
    }
}
