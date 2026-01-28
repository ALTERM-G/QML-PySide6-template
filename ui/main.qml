import QtQuick
import QtQuick.Window
import Components

Window {
    id: window
    visible: true
    color: Theme.backgroundColor
    width: AppConfig.windowWidth
    height: AppConfig.windowHeight
    title: "QML-PySide6 Template"

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Rectangle {
        id: contentArea
        color: Theme.backgroundColor
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Title {
            text: "Hope you nice coding session"
            anchors.centerIn: parent
        }
    }
}
