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

            ScrollView {
                anchors.fill: parent
                contentHeight: scrollContent.height
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Item {
                    id: scrollContent
                    width: parent.width
                    height: contentColumn.implicitHeight + title.height + LayoutMetrics.spacing.xl * 3

                    IconButton {
                        anchors.top: parent.top
                        anchors.topMargin: LayoutMetrics.spacing.xl
                        anchors.left: parent.left
                        anchors.leftMargin: LayoutMetrics.spacing.xl
                        iconPath: SVGLibrary.back
                        onPressed: { settingsPopup.close() }
                    }

                    Title {
                        id: title
                        text: "Settings"
                        anchors.top: parent.top
                        anchors.topMargin: LayoutMetrics.spacing.xl
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Column {
                        id: contentColumn
                        anchors.top: title.bottom
                        anchors.topMargin: LayoutMetrics.spacing.xl
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: LayoutMetrics.spacing.md

                        Column {
                            id: theme
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.xxs

                            Label {
                                text: "Theme"
                                style_2: true
                            }

                            ComboBox {
                                id: themeComboBox
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: LayoutMetrics.spacing.xxl
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

                        Column {
                            id: font
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.xxs

                            Label {
                                text: "Font"
                                style_2: true
                            }

                            ComboBox {
                                model: ["JetBrains Mono", "Roboto", "Times New Roman"]
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: LayoutMetrics.spacing.xxl
                            }
                        }

                        Column {
                            id: scale
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.xxs

                            Label {
                                text: "Scale"
                                style_2: true
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: LayoutMetrics.spacing.md

                                Slider {
                                    id: scaleSlider
                                    from: 0
                                    to: 200

                                    onValueChanged: {
                                        if (initialized) {
                                            var factor = 0.5 + (value / 200)
                                            LayoutMetrics.scaleFactor = factor
                                            Typography.scaleFactor = factor
                                            Metrics.scaleFactor = factor
                                            controller.save_scale_factor(factor)
                                        }
                                    }

                                    property bool initialized: false

                                    Connections {
                                        target: settingsPopup
                                        function onOpened() {
                                            var savedFactor = controller.get_scale_factor()
                                            scaleSlider.initialized = false
                                            scaleSlider.value = (savedFactor - 0.5) * 100
                                            scaleSlider.initialized = true
                                        }
                                    }
                                }

                                SpinBox {
                                    id: spinBox
                                    from: 0
                                    to: 200
                                    onValueChanged: {
                                        if (initialized) {
                                            var factor = 0.5 + (value / 200)
                                            LayoutMetrics.scaleFactor = factor
                                            Typography.scaleFactor = factor
                                            Metrics.scaleFactor = factor
                                            controller.save_scale_factor(factor)
                                        }
                                    }
                                    property bool initialized: false

                                    Connections {
                                        target: settingsPopup
                                        function onOpened() {
                                            var savedFactor = controller.get_scale_factor()
                                            spinBox.initialized = false
                                            spinBox.value = (savedFactor - 0.5) * 100
                                            spinBox.initialized = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
