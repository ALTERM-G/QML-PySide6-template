import QtQuick
import QtQuick.Window
import components

Window {
    id: window
    visible: true
    color: Theme.backgroundColor
    width: 1280
    height: 720
    Component.onCompleted: LayoutMetrics.bindToWindow(window)
    title: "QML-PySide6 Template"

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Settings {
            id: settings
            anchors.right: parent.right
            anchors.rightMargin: Metrics.spacing.xl
            anchors.verticalCenter: parent.verticalCenter
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
            id: showcase
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.8

            Title {
                text: "Have Fun !"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Metrics.spacing.sm
            }

            Grid {
                rows: 3
                columns: 2
                spacing: Metrics.spacing.sm
                anchors.centerIn: parent

                Button {}

                ComboBox {}

                SpinBox {}

                TabBar {}
            }
        }
    }
}
