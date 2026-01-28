import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../popups"
import "../indicators"
import "../controls"


Item {
    id: settingsMenu
    width: LayoutMetrics.iconButtonSize
    height: LayoutMetrics.iconButtonSize
    property bool isPopupOpen: settingsPopup.opened

    IconButton {
        id: settingsButton
        anchors.centerIn: parent
        iconPath: SVGLibrary.settings
        buttonWidth: LayoutMetrics.iconButtonSize
        buttonHeight: LayoutMetrics.iconButtonSize

        ToolTip {
            text: "Settings"
            visible: settingsButton.hovered
            delay: 600
        }

        onPressed: {
            settingsPopup.opened ? settingsPopup.close() : settingsPopup.open()
        }
    }

    Popup {
        id: settingsPopup
        width: AppConfig.appRectWidth
        height: AppConfig.appRectHeight
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        background: Rectangle {
            anchors.fill: parent

            IconButton {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacingL
                anchors.left: parent.left
                anchors.leftMargin: LayoutMetrics.spacingL
                iconPath: SVGLibrary.back
                onPressed: {settingsPopup.close()}
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacingL
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    text: "Settings"
                    Layout.alignment: Qt.AlignHCenter
                }

                ComboBox {
                    id: themeComboBox
                    Layout.topMargin: LayoutMetrics.marginXS
                    Layout.preferredHeight: LayoutMetrics.controlHeight
                    model: ["Carbon Amber", "Catppuccin Mocha", "Dracula", "Everforest", "Monokai","Github Dark", "Gruvbox", "Vanilla Light"]
                    onCurrentTextChanged: {
                        if (initialized) {
                            Theme.setTheme(currentText)
                        }
                    }
                    Layout.fillWidth: true

                    property bool initialized: false

                    Connections {
                        target: settingsPopup
                        function onOpened() {
                            var currentThemeIndex = themeComboBox.model.indexOf(Theme.currentTheme)
                            if (currentThemeIndex !== -1) {
                                themeComboBox.initialized = false
                                themeComboBox.currentIndex = currentThemeIndex
                                themeComboBox.initialized = true
                            }
                        }
                    }
                }
            }
        }
    }
}
