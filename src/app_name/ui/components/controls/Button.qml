import QtQuick
import components

Item {
    id: root

    property string buttonText
    property string iconPath: ""
    property bool run: false
    property bool primary: false
    property real heightMultiplier: 1.0
    property bool isometric: false
    property real horizontalPadding: LayoutMetrics.spacing.lg
    property color sideColor: Theme.borderColor

    signal pressed()

    readonly property real depth: isometric ? LayoutMetrics.spacing.xs : 0
    property real pressOffset: mouseArea.pressed ? depth : 0
    readonly property color faceColor: primary ? Theme.themeColor : (mouseArea.containsMouse ? Theme.hoverBackgroundColor : Theme.backgroundColor)

    width: LayoutMetrics.size.buttonWidth
    height: LayoutMetrics.size.controlHeight * heightMultiplier + depth
    implicitWidth: Math.max(LayoutMetrics.size.buttonWidth, contentRow.implicitWidth + horizontalPadding * 2)

    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: root.buttonText
    Accessible.onPressAction: root.doPress()

    Keys.onReturnPressed: root.doPress()
    Keys.onEnterPressed: root.doPress()

    function doPress() {
        root.pressed()
    }

    Behavior on pressOffset {
        enabled: LayoutMetrics.animationsEnabled
        NumberAnimation {
            duration: 70
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        id: face
        width: root.width - root.depth
        height: root.height - root.depth
        x: root.pressOffset
        y: root.pressOffset
        radius: LayoutMetrics.radius.m
        border.color: root.primary ? Theme.themeColor : Theme.borderColor
        border.width: LayoutMetrics.border.l
        color: mouseArea.pressed ? Qt.darker(root.faceColor, 1.15) : root.faceColor

        Behavior on color {
            enabled: LayoutMetrics.animationsEnabled
            ColorAnimation { duration: 150 }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: LayoutMetrics.spacing.sm

            SVGObject {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                width: LayoutMetrics.size.iconS
                height: LayoutMetrics.size.iconS
                visible: root.iconPath !== ""
                path: root.iconPath
                color: root.primary ? Theme.hoverTextColor : (mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor)
            }

            Text {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: root.buttonText
                font.pixelSize: Typography.h4
                font.family: Typography.fontBold
                font.weight: Font.Bold
                color: root.primary ? Theme.hoverTextColor : (mouseArea.containsMouse ? Theme.hoverTextColor : Theme.textColor)

                Behavior on color {
                    enabled: LayoutMetrics.animationsEnabled
                    ColorAnimation { duration: 150 }
                }
            }
        }
    }

    Rectangle {
        id: side
        visible: root.isometric
        width: face.width
        height: face.height
        x: root.depth
        y: root.depth
        radius: face.radius
        color: root.sideColor
        border.color: root.sideColor
        border.width: LayoutMetrics.border.l
        z: -1
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.doPress()
    }

    FocusRing {}
}
