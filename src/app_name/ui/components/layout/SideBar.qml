import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Rectangle {
    id: sidebar

    property bool collapsed: false
    property bool expanded: false
    property int currentIndex: -1
    property real customWidth: LayoutMetrics.size.sideBarWidth

    signal navigationClicked(int index)

    function toggle() {
        expanded = !expanded
    }

    function onEscapePressed(event) {
        expanded = false
        event.accepted = true
    }

    function getIconUrl(iconName) {
        switch(iconName) {
            case "home": return SVGLibrary.home
            case "settings": return SVGLibrary.settings
            case "info": return SVGLibrary.info
            default: return ""
        }
    }

    width: !expanded ? 0 : (collapsed ? LayoutMetrics.spacing.xxl * 2.5 : customWidth)
    height: parent.height
    color: Theme.backgroundColor
    clip: true
    focus: true

    Keys.onEscapePressed: (event) => onEscapePressed(event)

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

    Rectangle {
        id: resizeHandle
        width: LayoutMetrics.spacing.md
        height: parent.height
        color: "transparent"
        anchors.right: parent.right
        anchors.top: parent.top

        MouseArea {
            id: resizeArea
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            property real startX: 0
            property real startWidth: 0

            onPressed: {
                startX = mouseX
                startWidth = sidebar.customWidth
            }

            onMouseXChanged: {
                if (pressed) {
                    var delta = mouseX - startX
                    var newWidth = startWidth + delta
                    var minWidth = LayoutMetrics.size.sideBarWidth * 0.5
                    var maxWidth = (sidebar.parent ? sidebar.parent.width : LayoutMetrics.size.sideBarWidth) * 0.4
                    var clampedWidth = Math.max(minWidth, Math.min(maxWidth, newWidth))
                    sidebar.customWidth = clampedWidth
                    sidebar.width = clampedWidth
                }
            }
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
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
}
