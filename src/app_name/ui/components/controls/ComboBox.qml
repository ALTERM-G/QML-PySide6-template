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
        text: "▾"
        color: contentItem.color
        font.pixelSize: Typography.h1
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
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
        width: control.width
        implicitHeight: control.count * control.optionHeight + control.popupPadding * 2

        y: control.height
        opacity: 0.0
        height: 0

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        onOpened: {
            if (control.count === 0) {
                control.popup.close()
                return
            }
            height = implicitHeight
            opacity = 1
        }

        onClosed: {
            height = 0
            opacity = 0
        }
        padding: 0
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0

        background: Rectangle {
            radius: LayoutMetrics.radius.m
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
