import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

Column {
    id: generalTab

    required property QtObject settingsMenu
    required property QtObject settingsPopup
    required property QtObject settingsTabBar

    visible: settingsTabBar.currentIndex === 0
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: LayoutMetrics.spacing.md

    function resetControls() {
        languageCombo.initialized = false
        languageCombo.currentIndex = controller.get_language()
        languageCombo.initialized = true
    }

    Label {
        text: Lang.labels.language
        style_2: true
    }

    ComboBox {
        id: languageCombo
        anchors.horizontalCenter: parent.horizontalCenter
        model: controller.get_languages()

        property bool initialized: false

        onCurrentIndexChanged: {
            if (initialized) {
                controller.save_language(currentIndex)
            }
        }
    }
}
