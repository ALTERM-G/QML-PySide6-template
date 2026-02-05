import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

    Text {
        id: app_title
        color: Theme.themeColor
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: LayoutMetrics.spacing.md
        text: UiData.titles.appName
        font.pointSize: Typography.h3
        font.family: Typography.fontBold
        verticalAlignment: Text.AlignVCenter
    }
}
