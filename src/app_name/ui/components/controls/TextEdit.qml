import QtQuick
import QtQuick.Controls
import components

Item {
    id: control
    width: LayoutMetrics.size.textEditWidth
    height: LayoutMetrics.size.textEditHeight

    property alias placeholderText: area.placeholderText
    property alias text: area.text

    ScrollView {
        id: view
        anchors.fill: parent

        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ScrollBar.vertical: ScrollBar {
            id: vbar
            readonly property real inset: LayoutMetrics.radius.m
            readonly property real gap: LayoutMetrics.border.m * 2

            parent: view
            x: view.mirrored ? gap : view.width - width - gap
            y: view.topPadding + inset
            height: view.availableHeight - inset * 2
            policy: ScrollBar.AsNeeded
            visible: vbar.size < 1.0
            padding: 0

            contentItem: Rectangle {
                implicitWidth: LayoutMetrics.spacing.sm
                implicitHeight: LayoutMetrics.spacing.sm
                radius: width / 2
                color: vbar.pressed ? Theme.themeColor
                     : vbar.hovered ? Theme.borderColor
                     : Theme.dividerColor
                opacity: (vbar.active || vbar.hovered) ? 1.0 : 0.55

                Behavior on color {
                    enabled: LayoutMetrics.animationsEnabled
                    ColorAnimation { duration: 120 }
                }

                Behavior on opacity {
                    enabled: LayoutMetrics.animationsEnabled
                    NumberAnimation { duration: 120 }
                }
            }
        }

        background: Rectangle {
            color: Theme.inputBackgroundColor
            border.color: area.activeFocus ? Theme.themeColor : Theme.borderColor
            border.width: LayoutMetrics.border.m
            radius: LayoutMetrics.radius.m

            Behavior on border.color {
                enabled: LayoutMetrics.animationsEnabled
                ColorAnimation {
                    duration: 150
                }
            }
        }

        TextArea {
            id: area
            width: view.availableWidth

            font.pixelSize: Typography.h4
            font.family: Typography.fontRegular
            color: Theme.textColor
            selectionColor: Theme.themeColor
            selectedTextColor: Theme.hoverTextColor
            selectByMouse: true
            wrapMode: Text.Wrap

            cursorDelegate: Item {}

            ContextMenu.menu: TextContextMenu {
                editor: area
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Insert) {
                    area.overwriteMode = !area.overwriteMode
                    event.accepted = true
                }
            }

            placeholderTextColor: Theme.dividerColor

            background: null

            TextCursor {
                cursorRect: area.cursorRectangle
                overwrite: area.overwriteMode
                font: area.font
                visible: area.activeFocus && area.cursorVisible && area.selectionStart === area.selectionEnd
                z: 5
            }
        }
    }

    FocusRing {
        focusItem: area
    }
}
