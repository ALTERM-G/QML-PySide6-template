import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Rectangle {
    id: sidebar

    property bool collapsed: false
    property bool expanded: false
    property int currentIndex: -1

    signal navigationClicked(int index)

    function toggle() {
        expanded = !expanded
    }

    function getIconUrl(iconName) {
        switch(iconName) {
            case "home": return SVGLibrary.home
            case "settings": return SVGLibrary.settings
            case "info": return SVGLibrary.info
            default: return ""
        }
    }

    width: !expanded ? 0 : (collapsed ? LayoutMetrics.spacing.xxl * 2.5 : LayoutMetrics.size.sideBarWidth)
    height: parent.height
    color: Theme.backgroundColor
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        width: LayoutMetrics.border.m
        height: parent.height
        color: Theme.dividerColor
        anchors.right: parent.right
    }

    Rectangle {
        height: LayoutMetrics.border.m
        width: parent.width
        color: Theme.dividerColor
        anchors.bottom: parent.bottom
    }

    Rectangle {
        width: LayoutMetrics.border.m
        height: parent.height
        color: Theme.dividerColor
        anchors.left: parent.left
    }

    Column {
        anchors.fill: parent
        spacing: 0

        Item {
            width: parent.width
            height: LayoutMetrics.spacing.md
        }
    }

    SideBarToggle {
        id: toggleButton
        anchors.right: parent.right
        anchors.rightMargin: LayoutMetrics.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        collapsed: sidebar.collapsed
        onToggled: sidebar.collapsed = !sidebar.collapsed
    }
}
