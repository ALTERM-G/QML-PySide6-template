import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: topBar
    implicitHeight: AppConfig.topBarHeight
    Layout.fillWidth: true
    color: Theme.topBarColor

    Rectangle {
        id: divider
        height: AppConfig.dividerThickness
        color: Theme.dividerColor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Text {
        id: title_ASCII
        color: Theme.themeColor
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: LayoutMetrics.md

        text: ASCIIart.text
        font.pointSize: 4
        font.family: Typography.fontRegular
        wrapMode: Text.NoWrap
        verticalAlignment: Text.AlignVCenter
    }
}
