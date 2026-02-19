import QtQuick
import QtQuick.Controls

ComboBox {
    id: control
    width: LayoutMetrics.size.comboBoxWidth
    height: LayoutMetrics.size.controlHeight * 2
    hoverEnabled: true
    property int optionHeight: LayoutMetrics.size.controlHeight
    property int popupPadding: 6

    contentItem: Text {
        text: control.displayText !== "" ? control.displayText : "Select"
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Typography.h4
        font.family: Typography.fontBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: mouseArea.containsMouse
               ? Theme.hoverTextColor
               : Theme.textColor

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    indicator: Text {
        id: arrow
        text: "▾"
        color: contentItem.color
        font.pixelSize: Typography.h1
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        rotation: control.popup.opened ? 180 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: LayoutMetrics.radius.m
        border.color: Theme.borderColor
        border.width: LayoutMetrics.border.l
        color: mouseArea.containsMouse
               ? Theme.hoverBackgroundColor
               : Theme.backgroundColor
        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: control.open()
        }
    }

    popup: Popup {
        id: dropdownPopup
        property int horizontalMargin: 8
        width: control.width - horizontalMargin * 2
        implicitHeight: control.count * control.optionHeight + control.popupPadding * 2

        x: horizontalMargin
        y: control.height - LayoutMetrics.border.m
        clip: true

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "height"; from: 0; to: dropdownPopup.implicitHeight; duration: 150; easing.type: Easing.OutQuad }
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "height"; from: dropdownPopup.implicitHeight; to: 0; duration: 150; easing.type: Easing.InQuad }
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
            }
        }
        padding: 0
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0

        background: Rectangle {
            anchors.fill: parent
            bottomLeftRadius: LayoutMetrics.radius.m
            bottomRightRadius: LayoutMetrics.radius.m
            topLeftRadius: 0
            topRightRadius: 0

            color: Theme.backgroundColor
            border.color: Theme.borderColor
            border.width: LayoutMetrics.border.l
        }

        Column {
            anchors.fill: parent
            anchors.margins: control.popupPadding
            spacing: 0

            Repeater {
                model: control.model

                delegate: Rectangle {
                    width: parent.width
                    height: control.optionHeight
                    radius: LayoutMetrics.radius.m
                    color: hovered
                           ? Theme.hoverBackgroundColor
                           : "transparent"

                    property bool hovered: false

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onClicked: {
                            control.currentIndex = index
                            control.popup.close()
                        }
                    }

                    Text {
                        anchors.fill: parent
                        text: control.textRole ? model[control.textRole] : modelData
                        font.pixelSize: Typography.h4
                        font.family: Typography.fontBold
                        color: hovered ? Theme.hoverTextColor : Theme.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
