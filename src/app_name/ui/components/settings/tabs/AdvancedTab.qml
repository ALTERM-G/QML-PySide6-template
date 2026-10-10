import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Column {
    id: advancedColumn
    visible: tabBar.currentIndex === 2

    width: parent.width
    spacing: LayoutMetrics.spacing.md

    Label {
        width: parent.width
        text: Lang.labels.keyboard
        style_2: true
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: Shortcuts.list

        delegate: Item {
            id: shortcutRow
            required property var modelData

            width: advancedColumn.width
            height: rowContent.implicitHeight

            Row {
                id: rowContent
                spacing: LayoutMetrics.spacing.sm

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Lang.shortcuts[shortcutRow.modelData.id]
                          || shortcutRow.modelData.label
                    width: LayoutMetrics.size.shortcutLabelWidth
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                }

                ShortcutButton {
                    anchors.verticalCenter: parent.verticalCenter
                    actionId: shortcutRow.modelData.id
                }

                IconButton {
                    id: resetButton

                    anchors.verticalCenter: parent.verticalCenter
                    opacity: shortcutRow.modelData.custom ? 1 : 0
                    enabled: shortcutRow.modelData.custom
                    iconPath: SVGLibrary.reset
                    buttonWidth: LayoutMetrics.size.iconM
                    buttonHeight: LayoutMetrics.size.iconM

                    onPressed: Shortcuts.reset(shortcutRow.modelData.id)

                    ToolTip {
                        text: Lang.labels.resetShortcut
                        visible: resetButton.hovered
                                 && shortcutRow.modelData.custom
                        delay: 600
                    }
                }
            }
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        buttonText: Lang.labels.resetAllShortcuts
        primary: true
        heightMultiplier: 1.3
        width: LayoutMetrics.size.buttonWidth * 1.4

        onPressed: Shortcuts.resetAll()
    }
}