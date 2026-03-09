import QtQuick
import QtQuick.Controls
import components

SpinBox {
    id: spinBox
    width: LayoutMetrics.size.spinBoxWidth
    height: LayoutMetrics.size.controlHeightHuge
    stepSize: 10

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
        height: spinBox.height / 4
        width: LayoutMetrics.size.iconS
        color: Theme.backgroundColor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: LayoutMetrics.spacing.sm
        anchors.rightMargin: LayoutMetrics.spacing.sm

        SVGObject {
            path: SVGLibrary.chevronUp
            anchors.centerIn: parent
            color: upMouseArea.containsMouse ? Theme.themeColor : Theme.textColor
            width: LayoutMetrics.size.iconS
            height: LayoutMetrics.size.iconS
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
        width: LayoutMetrics.size.iconS
        height: spinBox.height / 4
        color: Theme.backgroundColor
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: LayoutMetrics.spacing.sm
        anchors.rightMargin: LayoutMetrics.spacing.sm

        SVGObject {
            path: SVGLibrary.chevronDown
            anchors.centerIn: parent
            color: downMouseArea.containsMouse ? Theme.themeColor : Theme.textColor
            width: LayoutMetrics.size.iconS
            height: LayoutMetrics.size.iconS
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
