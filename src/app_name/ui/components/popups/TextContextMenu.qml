import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

Menu {
    id: menu

    required property Item editor

    popupType: Qt.platform.pluginName !== "wayland" ? Popup.Window : Popup.Item
    padding: LayoutMetrics.spacing.xxs

    background: Rectangle {
        color: Theme.backgroundColor
        border.color: Theme.borderColor
        border.width: LayoutMetrics.border.l
        radius: LayoutMetrics.radius.m
    }

    delegate: MenuItem {
        id: menuItem

        implicitHeight: LayoutMetrics.spacing.xl
        padding: 0
        icon.width: 16
        icon.height: 16
        font.family: Typography.fontRegular
        font.pixelSize: Typography.body

        contentItem: IconLabel {
            leftPadding: LayoutMetrics.spacing.md
            rightPadding: LayoutMetrics.spacing.md
            spacing: LayoutMetrics.spacing.sm
            mirrored: menuItem.mirrored
            display: menuItem.display
            alignment: Qt.AlignLeft
            icon: menuItem.icon
            text: menuItem.text
            font: menuItem.font
            color: menuItem.enabled
                   ? (menuItem.highlighted || menuItem.down ? Theme.hoverTextColor : Theme.textColor)
                   : Theme.dividerColor
        }

        background: Rectangle {
            radius: LayoutMetrics.radius.s
            color: menuItem.enabled && (menuItem.highlighted || menuItem.down)
                   ? Theme.hoverBackgroundColor
                   : "transparent"
        }
    }

    UndoAction {
        editor: menu.editor
    }
    RedoAction {
        editor: menu.editor
    }

    MenuSeparator {
        padding: LayoutMetrics.spacing.xs
        verticalPadding: LayoutMetrics.border.m
        contentItem: Rectangle {
            implicitHeight: 1
            color: Theme.dividerColor
        }
    }

    CutAction {
        editor: menu.editor
    }
    CopyAction {
        editor: menu.editor
    }
    PasteAction {
        editor: menu.editor
    }
    DeleteAction {
        editor: menu.editor
    }

    MenuSeparator {
        padding: LayoutMetrics.spacing.xs
        verticalPadding: LayoutMetrics.border.m
        contentItem: Rectangle {
            implicitHeight: 1
            color: Theme.dividerColor
        }
    }

    SelectAllAction {
        editor: menu.editor
    }
}
