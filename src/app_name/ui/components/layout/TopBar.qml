import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Rectangle {
    id: topBar
    implicitHeight: LayoutMetrics.size.topBarHeight
    Layout.fillWidth: true
    color: Theme.topBarColor

    Rectangle {
        id: divider
        height: 2
        color: Theme.dividerColor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    IconButton {
        id: leftSidebarButton
        iconPath: SVGLibrary.leftSidebar
        anchors.left: parent.left
        anchors.leftMargin: LayoutMetrics.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        onPressed: topBar.sidebarToggleClicked()
    }

    signal sidebarToggleClicked()

    Text {
        id: app_title
        color: Theme.themeColor
        anchors.left: leftSidebarButton.left
        anchors.leftMargin: LayoutMetrics.spacing.xxl * 1.5
        anchors.verticalCenter: parent.verticalCenter
        text: UiData.titles.appName
        font.pointSize: Typography.h3
        font.family: Typography.fontBold
        verticalAlignment: Text.AlignVCenter
    }
}
