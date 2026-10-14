import QtQuick
import QtQuick.Controls
import components

TextField {
    id: control
    width: LayoutMetrics.size.lineEditWidth
    height: LayoutMetrics.size.lineEditHeight

    cursorDelegate: Item {}

    padding: 6
    leftPadding: padding + 4

    ContextMenu.menu: TextContextMenu {
        editor: control
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Insert) {
            control.overwriteMode = !control.overwriteMode
            event.accepted = true
        }
    }

    font.pixelSize: Typography.h4
    font.family: Typography.fontRegular
    color: Theme.textColor
    selectionColor: Theme.themeColor
    selectedTextColor: Theme.hoverTextColor
    selectByMouse: true
    verticalAlignment: Text.AlignVCenter

    placeholderTextColor: Theme.dividerColor

    background: Rectangle {
        implicitWidth: control.width
        implicitHeight: control.height
        color: Theme.inputBackgroundColor
        border.color: control.activeFocus ? Theme.themeColor : Theme.borderColor
        border.width: LayoutMetrics.border.m
        radius: LayoutMetrics.radius.m

        Behavior on border.color {
            enabled: LayoutMetrics.animationsEnabled
            ColorAnimation {
                duration: 150
            }
        }
    }

    TextCursor {
        cursorRect: control.cursorRectangle
        overwrite: control.overwriteMode
        font: control.font
        visible: control.activeFocus && control.cursorVisible && control.selectionStart === control.selectionEnd
        z: 5
    }

    FocusRing {}
}
