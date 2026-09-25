import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Item {
    id: settingsMenu
    property bool isPopupOpen: settingsPopup.opened

    property string appearancePendingTheme: Theme.currentTheme
    property string appearanceCommittedTheme: Theme.currentTheme
    property int appearanceCommittedScale: Math.round((controller.get_scale_factor() - 0.5) * 200)
    property int appearancePendingScale: Math.round((controller.get_scale_factor() - 0.5) * 200)
    property bool appearancePendingResponsive: true
    property bool appearanceCommittedResponsive: true
    property string appearancePendingFont: Typography.fontFamily
    property string appearanceCommittedFont: Typography.fontFamily
    property int languageCommittedIndex: 0

    readonly property int scaleMin: 0
    readonly property int scaleMax: 200
    readonly property int scaleStep: 10

    function applyScale(scale) {
        var factor = 0.5 + scale / 200
        LayoutMetrics.scaleFactor = factor
        Typography.scaleFactor = factor
        Metrics.scaleFactor = factor
        controller.save_scale_factor(factor)
    }

    function nudgeScale(direction) {
        var base = settingsPopup.opened ? appearancePendingScale : appearanceCommittedScale
        var next = Math.max(scaleMin, Math.min(scaleMax, base + direction * scaleStep))
        if (next === appearancePendingScale && next === appearanceCommittedScale)
            return
        appearancePendingScale = next
        appearanceCommittedScale = next
        applyScale(next)
        if (settingsPopup.opened) {
            scaleRow.initialized = false
            scaleRow.scaleValue = next
            slider.value = next
            spin.value = next
            scaleRow.initialized = true
        }
    }

    function applyAppearanceChanges() {
        Theme.setTheme(appearancePendingTheme)
        applyScale(appearancePendingScale)
        LayoutMetrics.isContinuous = appearancePendingResponsive
        Typography.isContinuous = appearancePendingResponsive
        controller.save_is_continuous(appearancePendingResponsive)
        Typography.fontFamily = appearancePendingFont
        controller.save_font_family(appearancePendingFont)
        appearanceCommittedTheme = appearancePendingTheme
        appearanceCommittedScale = appearancePendingScale
        appearanceCommittedResponsive = appearancePendingResponsive
        appearanceCommittedFont = appearancePendingFont
    }

    function cancelAppearanceChanges() {
        appearancePendingTheme = appearanceCommittedTheme
        appearancePendingScale = appearanceCommittedScale
        appearancePendingResponsive = appearanceCommittedResponsive
        appearancePendingFont = appearanceCommittedFont
        themeComboBox.initialized = false
        var idx = themeComboBox.model.indexOf(appearanceCommittedTheme)
        if (idx !== -1) themeComboBox.currentIndex = idx
        themeComboBox.initialized = true
        scaleRow.initialized = false
        scaleRow.scaleValue = appearanceCommittedScale
        slider.value = scaleRow.scaleValue
        spin.value = scaleRow.scaleValue
        scaleRow.initialized = true
        responsiveSwitch.initialized = false
        responsiveSwitch.checked = appearanceCommittedResponsive
        responsiveSwitch.initialized = true
        fontComboBox.initialized = false
        var fontIdx = fontComboBox.model.indexOf(appearanceCommittedFont)
        if (fontIdx !== -1) fontComboBox.currentIndex = fontIdx
        fontComboBox.initialized = true
        languageCombo.initialized = false
        languageCombo.currentIndex = languageCommittedIndex
        controller.save_language(languageCommittedIndex)
        languageCombo.initialized = true
        Theme.setTheme(appearanceCommittedTheme)
        applyScale(appearanceCommittedScale)
        LayoutMetrics.isContinuous = appearanceCommittedResponsive
        Typography.isContinuous = appearanceCommittedResponsive
        Typography.fontFamily = appearanceCommittedFont
    }

    function toggleSettings() {
        if (settingsPopup.opened) {
            cancelAppearanceChanges()
            settingsPopup.close()
        } else {
            settingsPopup.open()
        }
    }

    function loadAppearance() {
        appearanceCommittedTheme = Theme.currentTheme
        appearancePendingTheme = appearanceCommittedTheme
        var savedFactor = controller.get_scale_factor()
        appearanceCommittedScale = Math.round((savedFactor - 0.5) * 200)
        appearancePendingScale = appearanceCommittedScale
        appearanceCommittedResponsive = controller.get_is_continuous()
        appearancePendingResponsive = appearanceCommittedResponsive
        appearanceCommittedFont = Typography.fontFamily
        appearancePendingFont = appearanceCommittedFont
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

        onPressed: settingsMenu.toggleSettings()
    }

    Popup {
        id: settingsPopup
        width: LayoutMetrics.window.width * 0.8
        height: (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight) * 0.8
        x: (LayoutMetrics.window.width - width) / 2
        y: LayoutMetrics.size.topBarHeight + (LayoutMetrics.window.height - LayoutMetrics.size.topBarHeight - height) / 2
        padding: 0
        background: Item {}

        Shortcut {
            sequence: Shortcuts.nextTab
            enabled: settingsPopup.opened
            onActivated: tabBar.currentIndex = (tabBar.currentIndex + 1) % tabBar.tabData.length
        }

        Surface {
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
                anchors.top: title.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: LayoutMetrics.spacing.lg
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
                                id: switches
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: LayoutMetrics.spacing.xxs

                                Row {
                                    spacing: LayoutMetrics.spacing.md

                                    Label {
                                        text: Lang.labels.responsiveScaling
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
                                    sequence: Shortcuts.apply
                                    enabled: tabBar.currentIndex === 1
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

                        // ---- Advanced Tab ----
                        Column {
                            visible: tabBar.currentIndex === 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: LayoutMetrics.spacing.md

                            Label {
                                text: Lang.labels.keyboard
                                style_2: true
                            }

                            Repeater {
                                model: Shortcuts.list

                                delegate: Row {
                                    id: shortcutRow
                                    required property var modelData
                                    spacing: LayoutMetrics.spacing.lg

                                    Label {
                                        text: Lang.shortcuts[shortcutRow.modelData.action]
                                        width: LayoutMetrics.size.shortcutLabelWidth
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        text: shortcutRow.modelData.sequence
                                        style_2: true
                                        font.family: Typography.fontRegular
                                        font.weight: Font.Normal
                                    }
                                }
                            }

                            Label {
                                text: Lang.labels.advancedPlaceholder
                                style_2: true
                                topPadding: LayoutMetrics.spacing.md
                            }
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: Shortcuts.zoomIn
        context: Qt.ApplicationShortcut
        onActivated: settingsMenu.nudgeScale(1)
    }
    Shortcut {
        sequence: Shortcuts.zoomInShifted
        context: Qt.ApplicationShortcut
        onActivated: settingsMenu.nudgeScale(1)
    }
    Shortcut {
        sequence: Shortcuts.zoomOut
        context: Qt.ApplicationShortcut
        onActivated: settingsMenu.nudgeScale(-1)
    }
    Shortcut {
        sequence: Shortcuts.openSettings
        context: Qt.ApplicationShortcut
        onActivated: settingsMenu.toggleSettings()
    }
}
