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
    property int appearanceCommittedRadius: Math.round(controller.get_corner_radius() * 50)
    property int appearancePendingRadius: appearanceCommittedRadius
    property bool appearanceCommittedAnimations: true
    property bool appearancePendingAnimations: true
    property string appearancePendingFont: Typography.fontFamily
    property string appearanceCommittedFont: Typography.fontFamily
    property int languageCommittedIndex: 0

    readonly property int scaleMin: 0
    readonly property int scaleMax: 200
    readonly property int scaleStep: 10

    readonly property int radiusMin: 0
    readonly property int radiusMax: 100

    function applyRadius(radius) {
        var factor = radius / 50
        LayoutMetrics.setCornerRadiusFactor(factor)
        controller.save_corner_radius(factor)
    }

    function applyScale(scale) {
        var factor = 0.5 + scale / 200
        LayoutMetrics.scaleFactor = factor
        Typography.scaleFactor = factor
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
        applyRadius(appearancePendingRadius)
        LayoutMetrics.setAnimationsEnabled(appearancePendingAnimations)
        controller.save_animations_enabled(appearancePendingAnimations)
        appearanceCommittedTheme = appearancePendingTheme
        appearanceCommittedScale = appearancePendingScale
        appearanceCommittedResponsive = appearancePendingResponsive
        appearanceCommittedFont = appearancePendingFont
        appearanceCommittedRadius = appearancePendingRadius
        appearanceCommittedAnimations = appearancePendingAnimations
    }

    function cancelAppearanceChanges() {
        appearancePendingTheme = appearanceCommittedTheme
        appearancePendingScale = appearanceCommittedScale
        appearancePendingResponsive = appearanceCommittedResponsive
        appearancePendingAnimations = appearanceCommittedAnimations
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
        cornerRadiusRow.initialized = false
        cornerRadiusRow.radiusValue = appearanceCommittedRadius
        radiusSlider.value = cornerRadiusRow.radiusValue
        radiusSpin.value = cornerRadiusRow.radiusValue
        cornerRadiusRow.initialized = true
        applyRadius(appearanceCommittedRadius)
        responsiveSwitch.initialized = false
        responsiveSwitch.checked = appearanceCommittedResponsive
        responsiveSwitch.initialized = true
        animationsSwitch.initialized = false
        animationsSwitch.checked = appearanceCommittedAnimations
        animationsSwitch.initialized = true
        fontComboBox.initialized = false
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
        appearanceCommittedAnimations = controller.get_animations_enabled()
        appearancePendingAnimations = appearanceCommittedAnimations
        appearanceCommittedFont = Typography.fontFamily
        appearancePendingFont = appearanceCommittedFont
        appearanceCommittedRadius = Math.round(controller.get_corner_radius() * 50)
        appearancePendingRadius = appearanceCommittedRadius
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
        onClosed: Shortcuts.capturing = false

        enter: LayoutMetrics.animationsEnabled ? settingsPopupFadeEnter : settingsPopupInstantEnter
        exit: LayoutMetrics.animationsEnabled ? settingsPopupFadeExit : settingsPopupInstantExit

        Transition {
            id: settingsPopupInstantEnter
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 0 }
                NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 0 }
            }
        }

        Transition {
            id: settingsPopupInstantExit
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 0 }
                NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 0 }
            }
        }

        Transition {
            id: settingsPopupFadeEnter
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.95
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        Transition {
            id: settingsPopupFadeExit
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1
                    to: 0.95
                    duration: 200
                    easing.type: Easing.InQuad
                }
            }
        }

        Shortcut {
            sequence: Shortcuts.primary("nextTab")
            enabled: settingsPopup.opened && !Shortcuts.capturing
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
                id: scrollView
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
                    width: scrollView.width
                           - (scrollView.ScrollBar.vertical.visible
                              ? scrollView.ScrollBar.vertical.width : 0)
                    height: LayoutMetrics.spacing.xxl
                            + contentColumn.height
                            + LayoutMetrics.spacing.xl * 3

                    Column {
                        id: contentColumn
                        x: 0
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: LayoutMetrics.spacing.xxl
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

                                Row {
                                    spacing: LayoutMetrics.spacing.md

                                    Label {
                                        text: Lang.labels.responsiveScaling
                                        style_2: true
                                        width: LayoutMetrics.size.switchLabelWidth
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
                                        text: Lang.labels.animations
                                        style_2: true
                                        width: LayoutMetrics.size.switchLabelWidth
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

                        // ---- Advanced Tab ----
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
                    }
                }
            }
        }
    }

    Shortcut {
        sequences: Shortcuts.chords("zoomIn")
        context: Qt.ApplicationShortcut
        enabled: !Shortcuts.capturing
        onActivated: settingsMenu.nudgeScale(1)
    }
    Shortcut {
        sequence: Shortcuts.primary("zoomOut")
        context: Qt.ApplicationShortcut
        enabled: !Shortcuts.capturing
        onActivated: settingsMenu.nudgeScale(-1)
    }
    Shortcut {
        sequence: Shortcuts.primary("openSettings")
        context: Qt.ApplicationShortcut
        enabled: !Shortcuts.capturing
        onActivated: settingsMenu.toggleSettings()
    }
}
