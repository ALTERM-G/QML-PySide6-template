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
        width: LayoutMetrics.unit * 80
        height: LayoutMetrics.unit * 60
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2

        background: Surface {
            anchors.fill: parent

            IconButton {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacing.xl
                anchors.left: parent.left
                anchors.leftMargin: LayoutMetrics.spacing.xl
                iconPath: SVGLibrary.back
                buttonWidth: Metrics.size.iconS * 1.5
                buttonHeight: Metrics.size.iconS * 1.5
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
