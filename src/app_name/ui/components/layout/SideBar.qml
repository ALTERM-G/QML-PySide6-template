import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Rectangle {
    id: sidebar

    property bool collapsed: false
    property bool expanded: false
    property bool resizing: false
    property bool autoCollapse: true
    property int currentIndex: -1
    property bool keyboardNavigated: false
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

    function focusItemAt(index) {
        if (!expanded || collapsed || navRepeater.count === 0)
            return

        var target = Math.max(0, Math.min(navRepeater.count - 1, index))
        var item = navRepeater.itemAt(target)
        if (item)
            item.forceActiveFocus()
    }

    function releaseItemFocus() {
        for (var i = 0; i < navRepeater.count; i++) {
            var item = navRepeater.itemAt(i)
            if (item && item.activeFocus)
                item.focus = false
        }
    }

    function updateItemFocus() {
        keyboardNavigated = false
        if (expanded && !collapsed)
            focusItemAt(currentIndex >= 0 ? currentIndex : 0)
        else
            releaseItemFocus()
    }

    onExpandedChanged: updateItemFocus()
    onCollapsedChanged: updateItemFocus()

    width: !expanded ? 0 : (collapsed ? LayoutMetrics.spacing.xxl * 2.5 : resizableWidth)
    height: parent.height
    color: Theme.backgroundColor
    clip: true

    Behavior on width {
        enabled: !sidebar.resizing && LayoutMetrics.animationsEnabled
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
        z: 1
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
                var minRatio = 0.55
                sidebar.resizeRatio = Math.max(minRatio, newWidth / LayoutMetrics.size.sideBarWidth)
            }
        }
    }



    Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width - LayoutMetrics.border.m
        spacing: 0

        Item {
            width: parent.width
            height: LayoutMetrics.spacing.md
        }

        Repeater {
            id: navRepeater
            model: [
                { label: "Workspace 1", icon: "home" },
                { label: "Workspace 2", icon: "settings" },
                { label: "Workspace 3", icon: "info" }
            ]

            delegate: SideBarItem {
                itemText: modelData.label
                itemIcon: sidebar.getIconUrl(modelData.icon)
                isActive: sidebar.currentIndex === index
                collapsed: sidebar.collapsed
                showFocusRing: sidebar.keyboardNavigated

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Down) {
                        sidebar.keyboardNavigated = true
                        sidebar.focusItemAt(index + 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        sidebar.keyboardNavigated = true
                        sidebar.focusItemAt(index - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Home) {
                        sidebar.keyboardNavigated = true
                        sidebar.focusItemAt(0)
                        event.accepted = true
                    } else if (event.key === Qt.Key_End) {
                        sidebar.keyboardNavigated = true
                        sidebar.focusItemAt(navRepeater.count - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return
                               || event.key === Qt.Key_Enter
                               || event.key === Qt.Key_Space) {
                        sidebar.keyboardNavigated = true
                        sidebar.currentIndex = index
                        sidebar.navigationClicked(index)
                        event.accepted = true
                    }
                }

                onClicked: {
                    sidebar.keyboardNavigated = false
                    sidebar.focusItemAt(index)
                    sidebar.currentIndex = index
                    sidebar.navigationClicked(index)
                }
            }
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
        sequence: Shortcuts.primary("closeSidebar")
        enabled: sidebar.expanded && !Shortcuts.capturing
        onActivated: sidebar.expanded = false
    }

    // App-wide so the sidebar can be toggled from anywhere, including
    // while the settings popup has focus.
    Shortcut {
        sequence: Shortcuts.primary("toggleSidebar")
        context: Qt.ApplicationShortcut
        enabled: !Shortcuts.capturing
        onActivated: sidebar.toggle()
    }
}
