import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

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
            id: fontComboBox
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: LayoutMetrics.spacing.xxl

            model: typeof FontFamilies !== "undefined" ? FontFamilies : ["Roboto", "sans-serif"]
            property bool initialized: false

            onCurrentTextChanged: {
                if (initialized) {
                    settingsMenu.appearancePendingFont = currentText
                }
            }

            Connections {
                target: settingsPopup
                function onOpened() {
                    loadAppearance()
                    fontComboBox.initialized = false
                    var idx = fontComboBox.model.indexOf(appearanceCommittedFont)
                    if (idx !== -1) fontComboBox.currentIndex = idx
                    fontComboBox.initialized = true
                }
            }
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
        id: cornerRadius
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: LayoutMetrics.spacing.xxs

        Label {
            text: Lang.labels.cornerRadius
            style_2: true
        }

        Row {
            id: cornerRadiusRow
            spacing: LayoutMetrics.spacing.md
            property int radiusValue: 50
            property bool initialized: false

            Connections {
                target: settingsPopup
                function onOpened() {
                    loadAppearance()
                    cornerRadiusRow.initialized = false
                    cornerRadiusRow.radiusValue = appearanceCommittedRadius
                    radiusSlider.value = cornerRadiusRow.radiusValue
                    radiusSpin.value = cornerRadiusRow.radiusValue
                    cornerRadiusRow.initialized = true
                }
            }

            Slider {
                id: radiusSlider
                from: 0
                to: 100
                value: cornerRadiusRow.radiusValue

                onMoved: {
                    var newValue = Math.round(value)
                    if (cornerRadiusRow.radiusValue !== newValue) {
                        cornerRadiusRow.radiusValue = newValue
                        radiusSpin.value = newValue
                        if (cornerRadiusRow.initialized)
                            settingsMenu.appearancePendingRadius = newValue
                    }
                }
            }

            SpinBox {
                id: radiusSpin
                from: 0
                to: 100
                value: cornerRadiusRow.radiusValue

                onValueChanged: {
                    if (cornerRadiusRow.radiusValue !== value) {
                        cornerRadiusRow.radiusValue = value
                        radiusSlider.value = value
                        if (cornerRadiusRow.initialized)
                            settingsMenu.appearancePendingRadius = value
                    }
                }
            }
        }
    }

    Column {
        id: switches
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: LayoutMetrics.spacing.xxs
        readonly property real labelWidth: Math.max(responsiveLabel.implicitWidth, animationsLabel.implicitWidth)

        Row {
            spacing: LayoutMetrics.spacing.md

            Label {
                id: responsiveLabel
                text: Lang.labels.responsiveScaling
                style_2: true
                width: switches.labelWidth
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

        Row {
            spacing: LayoutMetrics.spacing.md

            Label {
                id: animationsLabel
                text: Lang.labels.animations
                style_2: true
                width: switches.labelWidth
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                id: animationsSwitch
                property bool initialized: false

                onCheckedChanged: {
                    if (initialized) {
                        settingsMenu.appearancePendingAnimations = checked
                    }
                }

                Connections {
                    target: settingsPopup
                    function onOpened() {
                        loadAppearance()
                        animationsSwitch.initialized = false
                        animationsSwitch.checked = settingsMenu.appearanceCommittedAnimations
                        animationsSwitch.initialized = true
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
            sequence: Shortcuts.primary("applyChanges")
            enabled: tabBar.currentIndex === 1 && !Shortcuts.capturing
            onActivated: applyAppearanceChanges()
        }

        Button {
            buttonText: Lang.labels.apply
            primary: true
            heightMultiplier: 1.3
            width: LayoutMetrics.size.buttonWidth * 1.4
            onPressed: applyAppearanceChanges()
        }
    }
}