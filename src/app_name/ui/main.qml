import QtQuick
import QtQuick.Window
import components

Window {
    id: window
    visible: true
    color: Theme.backgroundColor
    width: 1280
    height: 720
    Component.onCompleted: {
        LayoutMetrics.bindToWindow(window)
        Typography.setWindow(window)
    }
    title: Lang.titles.appName + " - " + Lang.titles.settings

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        onSidebarToggleClicked: sidebar.toggle()

        Settings {
            id: settings
            anchors.right: parent.right
            anchors.rightMargin: Metrics.spacing.xl
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    SideBar {
        id: sidebar
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        z: 100
    }

    MouseArea {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        enabled: sidebar.expanded && sidebar.autoCollapse
        propagateComposedEvents: true
        onPressed: function (mouse) {
            sidebar.expanded = false
            mouse.accepted = false
        }
    }

    Rectangle {
        id: contentArea
        color: Theme.backgroundColor
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Surface {
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.8

            Title {
                id: title
                text: Lang.greeting
                anchors.centerIn: parent
            }
        }
    }
}
