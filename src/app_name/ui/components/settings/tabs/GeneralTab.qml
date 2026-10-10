import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components

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