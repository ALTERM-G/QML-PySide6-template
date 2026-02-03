import QtQuick
import QtQuick.Controls

SpinBox {
    id: spinBox
    width: LayoutMetrics.size.spinBoxWidth
    height: LayoutMetrics.size.controlHeight
    stepSize: 10
    from: 0
    to: 1000

    function setFrom(newFrom) { spinBox.from = newFrom }
    function setTo(newTo) { spinBox.to = newTo }
    function setValue(newValue) { spinBox.value = newValue }

    contentItem: TextInput {
        text: spinBox.value.toString()
        font.pixelSize: Typography.h4
        font.family: Typography.fontBold
        color: Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        selectionColor: Theme.themeColor
        selectByMouse: true
        selectedTextColor: Theme.hoverTextColor
        validator: IntValidator {
            bottom: spinBox.from
            top: spinBox.to
        }
        onTextChanged: {
            if (text !== "" && !isNaN(parseInt(text, 10))) {
                var newValue = Math.min(Math.max(parseInt(text, 10), spinBox.from), spinBox.to)
                spinBox.value = newValue
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.NoButton
            enabled: true
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: LayoutMetrics.radius.m
        color: Theme.backgroundColor
        border.color: Theme.borderColor
        border.width: LayoutMetrics.border.l
    }

    up.indicator: Rectangle {
        x: spinBox.width - width
        height: spinBox.height / 2
        width: LayoutMetrics.size.iconL
        color: Theme.backgroundColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: LayoutMetrics.spacing.sm
        anchors.rightMargin: LayoutMetrics.spacing.sm

        Text {
            text: "▴"
            anchors.centerIn: parent
            color: upMouseArea.containsMouse ? Theme.themeColor : Theme.textColor
            font.pixelSize: Typography.h5
        }

        MouseArea {
            id: upMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: spinBox.increase()
        }
    }

    down.indicator: Rectangle {
        width: LayoutMetrics.size.iconL
        height: spinBox.height / 2
        color: Theme.backgroundColor
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: LayoutMetrics.spacing.sm
        anchors.rightMargin: LayoutMetrics.spacing.sm

        Text {
            text: "▾"
            anchors.centerIn: parent
            color: downMouseArea.containsMouse ? Theme.themeColor : Theme.textColor
            font.pixelSize: Typography.h5
        }

        MouseArea {
            id: downMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: spinBox.decrease()
        }
    }
}
