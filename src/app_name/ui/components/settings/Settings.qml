import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: settingsMenu
    property bool isPopupOpen: settingsPopup.opened

    IconButton {
        id: settingsButton
        anchors.centerIn: parent
        iconPath: SVGLibrary.settings

        ToolTip {
            text: UiData.titles.settings
            visible: settingsButton.hovered
            delay: 600
        }

        onPressed: {
            settingsPopup.opened ? settingsPopup.close() : settingsPopup.open()
        }
    }

    Popup {
        id: settingsPopup
        width: LayoutMetrics.window.width * 0.8
        height: (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight) * 0.8
        x: (LayoutMetrics.window.width - width) / 2
        y: LayoutMetrics.size.topBarHeight + (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight - height) / 2

        background: Surface {
            anchors.fill: parent

            IconButton {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacing.xl
                anchors.left: parent.left
                anchors.leftMargin: LayoutMetrics.spacing.xl
                iconPath: SVGLibrary.back
                onPressed: {settingsPopup.close()}
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacing.lg
                anchors.horizontalCenter: parent.horizontalCenter

                Title {
                    text: "Settings"
                    Layout.alignment: Qt.AlignHCenter
                }

                ComboBox {
                    id: themeComboBox
                    Layout.topMargin: LayoutMetrics.spacing.xl
                    height: LayoutMetrics.size.controlHeight * 1.2
                    implicitHeight: height
                    Layout.preferredWidth: LayoutMetrics.size.comboBoxWidth
                    model: Theme.themeNames
                    onCurrentTextChanged: {
                        if (initialized) {
                            Theme.setTheme(currentText)
                        }
                    }

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
