import QtQuick
import components

Rectangle {
    id: root
    color: Theme.backgroundColor
    implicitHeight: LayoutMetrics.size.controlHeightHuge
    implicitWidth: LayoutMetrics.size.tabBarWidth
    border.color: Theme.borderColor
    border.width: LayoutMetrics.border.m
    radius: LayoutMetrics.radius.m
    property var tabData: []
    property alias currentIndex: listView.currentIndex

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 0
        anchors.margins: LayoutMetrics.spacing.xs
        currentIndex: 0
        interactive: false
        orientation: Qt.Horizontal
        highlightFollowsCurrentItem: false
        model: tabData.length

        delegate: Item {
            id: listDelegate
            width: listView.width / tabData.length
            height: listView.height

            Row {
                spacing: LayoutMetrics.spacing.sm
                anchors.centerIn: parent

                Label {
                    id: tabText
                    text: typeof tabData[index] === "string" ? tabData[index] : (tabData[index] && tabData[index].name !== undefined ? tabData[index].name : "")
                    color: listView.currentIndex === index ? Theme.borderColor : Theme.textColor
                    pointSize: Typography.body
                    font.bold: listView.currentIndex === index

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: listView.currentIndex = index
                cursorShape: Qt.PointingHandCursor
            }
        }

        highlight: Item {
            width: listView.currentItem.width
            height: listView.currentItem.height
            x: listView.currentItem.x

            Behavior on x {
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 0
                color: Theme.themeColor
                radius: LayoutMetrics.radius.m
            }
        }
    }
}
