import QtQuick
import components

Rectangle {
    id: root
    color: Theme.backgroundColor
    implicitHeight: LayoutMetrics.size.controlHeightCompact
    implicitWidth: LayoutMetrics.size.comboBoxWidth
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

                SVGObject {
                    id: tabIcon
                    path: tabData[index].icon
                    color: listView.currentIndex === index ? Theme.borderColor : Theme.textColor
                    width: LayoutMetrics.size.iconS
                    height: LayoutMetrics.size.iconS

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
                }

                Label {
                    id: tabText
                    text: tabData[index].name
                    color: listView.currentIndex === index ? Theme.borderColor : Theme.textColor
                    font.underline: false
                    pointSize: Typography.h6
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
