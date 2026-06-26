import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Rectangle {
    id: sidebar

    property bool collapsed: false
    property bool expanded: false
    property bool resizing: false
    property int currentIndex: -1
    property real resizeRatio: 1.0
    property real resizableWidth: LayoutMetrics.size.sideBarWidth * resizeRatio

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

    width: !expanded ? 0 : (collapsed ? LayoutMetrics.spacing.xxl * 2.5 : resizableWidth)
    height: parent.height
    color: Theme.backgroundColor
    clip: true

    Behavior on width {
        enabled: !sidebar.resizing
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: borderRight
        width: LayoutMetrics.border.m
        height: parent.height
        color: Theme.dividerColor
        anchors.right: parent.right
    }

    MouseArea {
        id: resizeHandle
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6
        cursorShape: sidebar.expanded && !sidebar.collapsed ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: sidebar.expanded && !sidebar.collapsed
        preventStealing: true
        onPressed: { sidebar.resizing = true; resizeHandle.width = 20 }
        onReleased: { sidebar.resizing = false; resizeHandle.width = 6 }
        onPositionChanged: {
            if (pressed) {
                var newWidth = sidebar.width + mouseX - width / 2
                sidebar.resizeRatio = Math.max(0.4, newWidth / LayoutMetrics.size.sideBarWidth)
            }
        }
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

    Shortcut {
        sequence: "Escape"
        enabled: sidebar.expanded
        onActivated: sidebar.expanded = false
    }
}
