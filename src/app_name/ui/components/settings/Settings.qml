import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: settingsMenu
    property bool isPopupOpen: settingsPopup.opened

    property string appearancePendingTheme: Theme.currentTheme
    property string appearanceCommittedTheme: Theme.currentTheme
    property int appearancePendingScale: 100
    property int appearanceCommittedScale: 100
    property bool appearancePendingResponsive: true
    property bool appearanceCommittedResponsive: true
    property int languageCommittedIndex: 0

    function applyAppearanceChanges() {
        Theme.setTheme(appearancePendingTheme)
        var factor = 0.5 + appearancePendingScale / 200
        LayoutMetrics.scaleFactor = factor
        Typography.scaleFactor = factor
        Metrics.scaleFactor = factor
        controller.save_scale_factor(factor)
        LayoutMetrics.isContinuous = appearancePendingResponsive
        Typography.isContinuous = appearancePendingResponsive
        controller.save_is_continuous(appearancePendingResponsive)
        appearanceCommittedTheme = appearancePendingTheme
        appearanceCommittedScale = appearancePendingScale
        appearanceCommittedResponsive = appearancePendingResponsive
    }

    function loadAppearance() {
        appearanceCommittedTheme = Theme.currentTheme
        appearancePendingTheme = appearanceCommittedTheme
        var savedFactor = controller.get_scale_factor()
        appearanceCommittedScale = Math.round((savedFactor - 0.5) * 200)
        appearancePendingScale = appearanceCommittedScale
        appearanceCommittedResponsive = controller.get_is_continuous()
        appearancePendingResponsive = appearanceCommittedResponsive
        languageCommittedIndex = controller.get_language()
    }

    IconButton {
        id: settingsButton
        anchors.centerIn: parent
        iconPath: SVGLibrary.settings

        ToolTip {
            text: Lang.titles.settings
            visible: settingsButton.hovered
            delay: 600
        }

        onPressed: {
            if (settingsPopup.opened) {
                cancelAppearanceChanges()
                settingsPopup.close()
            } else {
                settingsPopup.open()
            }
        }
    }

    Popup {
        id: settingsPopup
        width: LayoutMetrics.window.width * 0.8
        height: (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight) * 0.8
        x: (LayoutMetrics.window.width - width) / 2
        y: LayoutMetrics.size.topBarHeight + (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight - height) / 2

        Shortcut {
            sequence: "Ctrl+Tab"
            enabled: settingsPopup.opened
            onActivated: tabBar.currentIndex = (tabBar.currentIndex + 1) % tabBar.tabData.length
        }

        background: Surface {
            anchors.fill: parent

            IconButton {
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacing.xl
                anchors.left: parent.left
                anchors.leftMargin: LayoutMetrics.spacing.xl
                iconPath: SVGLibrary.back
                onPressed: {
                    cancelAppearanceChanges()
                    settingsPopup.close()
                }
            }

            Title {
                id: title
                text: Lang.titles.settings
                anchors.top: parent.top
                anchors.topMargin: LayoutMetrics.spacing.xl
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TabBar {
                id: tabBar
                anchors.top: title.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: LayoutMetrics.spacing.xxl * 1.5
                tabData: [Lang.tabs.general, Lang.tabs.appearance, Lang.tabs.advanced]
            }

            Rectangle {
                anchors.top: tabBar.bottom
                anchors.topMargin: LayoutMetrics.spacing.md
                anchors.left: parent.left
                anchors.right: parent.right
                height: LayoutMetrics.spacing.xxs
                color: Theme.dividerColor
            }

            ScrollView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: tabBar.bottom
                anchors.topMargin: LayoutMetrics.spacing.md + LayoutMetrics.spacing.xxs
                anchors.bottom: parent.bottom
                contentHeight: scrollContent.height
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Item {
                    id: scrollContent
                    width: parent.width
                    height: LayoutMetrics.spacing.xxl + contentColumn.implicitHeight + LayoutMetrics.spacing.xl * 3

                    Column {
                        id: contentColumn
                        anchors.top: parent.top
                        anchors.topMargin: LayoutMetrics.spacing.xxl
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: LayoutMetrics.spacing.lg

                        // ---- General Tab ----
                        Column {
                            visible: tabBar.currentIndex === 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.md

                            Label { text: Lang.labels.language; style_2: true }

                            ComboBox {
                                id: languageCombo
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: ["English", "Français", "Deutsch", "Español", "Italiano"]

                                property bool initialized: false

                                onCurrentIndexChanged: {
                                    if (initialized) {
                                        controller.save_language(currentIndex)
                                    }
                                }

                                Connections {
                                    target: settingsPopup
                                    function onOpened() {
                                        languageCombo.initialized = false
                                        languageCombo.currentIndex = controller.get_language()
                                        languageCombo.initialized = true
                                    }
                                }
                            }
                        }

                        // ---- Appearance Tab ----
                        Column {
                            visible: tabBar.currentIndex === 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.md

                            Column {
                                id: theme
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: LayoutMetrics.spacing.xxs

                                Label {
                                    text: Lang.labels.theme
                                    style_2: true
                                }

                                ComboBox {
                                    id: themeComboBox
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.topMargin: LayoutMetrics.spacing.xxl

                                    model: Theme.themeNames
                                    property bool initialized: false

                                    onCurrentTextChanged: {
                                        if (initialized) {
                                            settingsMenu.appearancePendingTheme = currentText
                                        }
                                    }

                                    Connections {
                                        target: settingsPopup
                                        function onOpened() {
                                            loadAppearance()
                                            themeComboBox.initialized = false
                                            var idx = themeComboBox.model.indexOf(appearanceCommittedTheme)
                                            if (idx !== -1) themeComboBox.currentIndex = idx
                                            themeComboBox.initialized = true
                                        }
                                    }
                                }
                            }

                            Column {
                                id: font
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: LayoutMetrics.spacing.xxs

                                Label {
                                    text: Lang.labels.font
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
                                    text: Lang.labels.scale
                                    style_2: true
                                }

                                Row {
                                    id: scaleRow
                                    spacing: LayoutMetrics.spacing.md
                                    property int scaleValue: 100
                                    property bool initialized: false

                                    Connections {
                                        target: settingsPopup
                                        function onOpened() {
                                            loadAppearance()
                                            scaleRow.initialized = false
                                            scaleRow.scaleValue = appearanceCommittedScale
                                            slider.value = scaleRow.scaleValue
                                            spin.value = scaleRow.scaleValue
                                            scaleRow.initialized = true
                                        }
                                    }

                                    Slider {
                                        id: slider
                                        from: 0
                                        to: 200
                                        value: scaleRow.scaleValue

                                        onMoved: {
                                            var newValue = Math.round(value)
                                            if (scaleRow.scaleValue !== newValue) {
                                                scaleRow.scaleValue = newValue
                                                spin.value = newValue
                                                if (scaleRow.initialized)
                                                    settingsMenu.appearancePendingScale = newValue
                                            }
                                        }
                                    }

                                    SpinBox {
                                        id: spin
                                        from: 0
                                        to: 200
                                        value: scaleRow.scaleValue

                                        onValueChanged: {
                                            if (scaleRow.scaleValue !== value) {
                                                scaleRow.scaleValue = value
                                                slider.value = value
                                                if (scaleRow.initialized)
                                                    settingsMenu.appearancePendingScale = value
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                id: switches
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: LayoutMetrics.spacing.xxs

                                Row {
                                    spacing: LayoutMetrics.spacing.md

                                    Label {
                                        text: "Responsive scaling"
                                        style_2: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Switch {
                                        id: responsiveSwitch
                                        property bool initialized: false

                                        onCheckedChanged: {
                                            if (initialized) {
                                                settingsMenu.appearancePendingResponsive = checked
                                            }
                                        }

                                        Connections {
                                            target: settingsPopup
                                            function onOpened() {
                                                loadAppearance()
                                                responsiveSwitch.initialized = false
                                                responsiveSwitch.checked = settingsMenu.appearanceCommittedResponsive
                                                responsiveSwitch.initialized = true
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: LayoutMetrics.spacing.xl
                                spacing: LayoutMetrics.spacing.md

                                Shortcut {
                                    sequence: "Return"
                                    enabled: tabBar.currentIndex === 1
                                    onActivated: applyAppearanceChanges()
                                }

                                Button {
                                    buttonText: "Apply"
                                    primary: true
                                    heightMultiplier: 1.3
                                    width: LayoutMetrics.size.buttonWidth * 1.4
                                    onPressed: applyAppearanceChanges()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
