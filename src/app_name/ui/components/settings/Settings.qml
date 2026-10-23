import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import "tabs"

    Item {
        id: settingsMenu
        property bool isPopupOpen: settingsPopup.opened


    property string appearancePendingTheme: Theme.currentTheme
    property string appearanceCommittedTheme: Theme.currentTheme
    property int appearanceCommittedScale: Math.round((controller.get_scale_factor() - 0.5) * 200)
    property int appearancePendingScale: Math.round((controller.get_scale_factor() - 0.5) * 200)
    property bool appearancePendingResponsive: controller.get_is_continuous()
    property bool appearanceCommittedResponsive: controller.get_is_continuous()
    property int appearanceCommittedRadius: Math.round(controller.get_corner_radius() * 50)
    property int appearancePendingRadius: appearanceCommittedRadius
    property bool appearanceCommittedAnimations: controller.get_animations_enabled()
    property bool appearancePendingAnimations: controller.get_animations_enabled()
    property string appearancePendingFont: Typography.fontFamily
    property string appearanceCommittedFont: Typography.fontFamily
    property int prevTabIndex: 0

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

    function applyFont(family) {
        if (family === Typography.fontFamily)
            return
        var crossfade = LayoutMetrics.window ? LayoutMetrics.window.crossfade : null
        var commit = function () {
            Typography.fontFamily = family
            controller.save_font_family(family)
        }
        if (crossfade && LayoutMetrics.animationsEnabled)
            crossfade.run(commit)
        else
            commit()
    }

    function slideToTab(newIndex) {
        var dir = newIndex > prevTabIndex ? 1 : -1
        prevTabIndex = newIndex
        if (!LayoutMetrics.animationsEnabled) {
            tabStage.x = 0
            tabStage.opacity = 1
            return
        }
        tabStage.x = dir * tabStage.width
        tabStage.opacity = 0
        tabSlideX.from = dir * tabStage.width
        tabSlideX.to = 0
        tabSlideOpacity.from = 0
        tabSlideOpacity.to = 1
        tabSlide.start()
    }

    function nudgeScale(direction) {
        var base = settingsPopup.opened ? appearancePendingScale : appearanceCommittedScale
        var next = Math.max(scaleMin, Math.min(scaleMax, base + direction * scaleStep))
        if (next === appearancePendingScale && next === appearanceCommittedScale)
            return
        appearancePendingScale = next
        appearanceCommittedScale = next
        applyScale(next)
        if (settingsPopup.opened)
            appearanceTab.setScaleValue(next)
    }

    function applyAppearanceChanges() {
        Theme.setTheme(appearancePendingTheme)
        applyScale(appearancePendingScale)
        LayoutMetrics.isContinuous = appearancePendingResponsive
        Typography.isContinuous = appearancePendingResponsive
        controller.save_is_continuous(appearancePendingResponsive)
        applyFont(appearancePendingFont)
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
        appearancePendingRadius = appearanceCommittedRadius
        appearanceTab.resetControls()
        applyRadius(appearanceCommittedRadius)
        Theme.setTheme(appearanceCommittedTheme)
        applyScale(appearanceCommittedScale)
        LayoutMetrics.isContinuous = appearanceCommittedResponsive
        Typography.isContinuous = appearanceCommittedResponsive
        applyFont(appearanceCommittedFont)
    }

    function toggleSettings() {
        if (settingsPopup.opened) {
            cancelAppearanceChanges()
            settingsPopup.close()
        } else {
            settingsPopup.open()
        }
    }

    ParallelAnimation {
        id: tabSlide
        NumberAnimation {
            id: tabSlideX
            target: tabStage
            property: "x"
            duration: 220
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: tabSlideOpacity
            target: tabStage
            property: "opacity"
            duration: 220
            easing.type: Easing.OutQuad
        }
    }

    Connections {
        target: tabBar
        function onCurrentIndexChanged() {
            settingsMenu.slideToTab(tabBar.currentIndex)
        }
    }

    Connections {
        target: settingsPopup
        function onOpened() {
            settingsMenu.loadAppearance()
            appearanceTab.resetControls()
            generalTab.resetControls()
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

        Shortcut {
            sequence: Shortcuts.primary("prevTab")
            enabled: settingsPopup.opened && !Shortcuts.capturing
            onActivated: tabBar.currentIndex = (tabBar.currentIndex - 1 + tabBar.tabData.length) % tabBar.tabData.length
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

                Binding {
                    target: scrollView.contentItem
                    property: "boundsBehavior"
                    value: LayoutMetrics.animationsEnabled
                           ? Flickable.DragAndOvershootBounds
                           : Flickable.StopAtBounds
                    when: scrollView.contentItem !== null
                    restoreMode: Binding.RestoreNone
                }

                Item {
                    id: scrollContent
                    width: scrollView.width
                           - (scrollView.ScrollBar.vertical.visible
                              ? scrollView.ScrollBar.vertical.width : 0)
                    height: LayoutMetrics.spacing.xxl
                            + tabStage.height
                            + LayoutMetrics.spacing.xl * 3

                    Item {
                        id: tabStage
                        anchors.top: parent.top
                        x: 0
                        width: parent.width
                        height: contentColumn.height

                        Column {
                            id: contentColumn
                            x: 0
                            width: tabStage.width
                            anchors.top: parent.top
                            anchors.topMargin: LayoutMetrics.spacing.xxl
                            spacing: LayoutMetrics.spacing.lg

                            GeneralTab {
                                id: generalTab
                                settingsMenu: settingsMenu
                                settingsPopup: settingsPopup
                                settingsTabBar: tabBar
                            }
                            AppearanceTab {
                                id: appearanceTab
                                settingsMenu: settingsMenu
                                settingsPopup: settingsPopup
                                settingsTabBar: tabBar
                            }
                            AdvancedTab {
                                id: advancedTab
                                settingsTabBar: tabBar
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
