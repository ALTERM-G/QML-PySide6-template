import QtQuick
import components

Rectangle {
    id: root
    color: Theme.backgroundColor
    border.color: Theme.borderColor
    border.width: LayoutMetrics.border.m
    radius: LayoutMetrics.radius.m

    property var tabData: []
    property alias currentIndex: listView.currentIndex

    // True for a short window while the bar is being resized (e.g. the user is
    // changing the scale). The highlight snaps instead of sliding during this
    // window, so it never lags behind and spills out of the bar.
    property bool resizing: false

    readonly property real tabPadding: LayoutMetrics.spacing.xl
    readonly property real listMargin: LayoutMetrics.spacing.xs
    readonly property real widestLabel: {
        var widest = 0
        for (var i = 0; i < measureRow.children.length; i++) {
            var w = measureRow.children[i].implicitWidth
            if (w > widest)
                widest = w
        }
        return widest
    }
    readonly property real tabWidth: tabData.length > 0 ? widestLabel + tabPadding : 0
    readonly property real totalWidth: tabWidth * tabData.length + listMargin * 2

    width: totalWidth
    height: LayoutMetrics.size.controlHeightHuge
    implicitWidth: totalWidth
    implicitHeight: height

    onWidthChanged: {
        resizing = true
        resizeSettle.restart()
    }

    Timer {
        id: resizeSettle
        interval: 180
        onTriggered: root.resizing = false
    }

    function tabLabel(item) {
        return typeof item === "string" ? item : (item && item.name !== undefined ? item.name : "")
    }

    Row {
        id: measureRow
        visible: false
        spacing: 0

        Repeater {
            model: root.tabData

            Label {
                required property var modelData
                text: root.tabLabel(modelData)
                pointSize: Typography.body
                font.bold: true
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: root.listMargin
        spacing: 0
        currentIndex: 0
        interactive: false
        orientation: Qt.Horizontal
        highlightFollowsCurrentItem: false
        clip: true
        model: root.tabData.length

        delegate: Item {
            id: listDelegate
            width: root.tabWidth
            height: listView.height

            Row {
                spacing: LayoutMetrics.spacing.sm
                anchors.centerIn: parent

                Label {
                    id: tabText
                    text: root.tabLabel(root.tabData[index])
                    color: listView.currentIndex === index ? Theme.borderColor : Theme.textColor
                    pointSize: Typography.body
                    font.bold: true

                    Behavior on color {
                        enabled: LayoutMetrics.animationsEnabled
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
            width: listView.currentItem ? listView.currentItem.width : 0
            height: listView.currentItem ? listView.currentItem.height : 0
            x: listView.currentItem ? listView.currentItem.x : 0

            Behavior on x {
                enabled: !root.resizing && LayoutMetrics.animationsEnabled
                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.themeColor
                radius: LayoutMetrics.radius.m
            }
        }
    }
}
