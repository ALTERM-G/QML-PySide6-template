import QtQuick
import QtQuick.Controls

QtObject {
    id: theme
    property bool animationsEnabled: true
    property string currentTheme: "Carbon Amber"
    property SystemPalette sysPalette: SystemPalette {
        colorGroup: SystemPalette.Active
    }
    property var themeColors: ({})
    Component.onCompleted: loadThemes()

    function loadThemes() {
        if (controller) {
            themeColors = controller.get_theme_colors()
        }
    }

    function colorForTheme(name, key) {
        if (name === "System") {
            switch(key) {
                case "themeColor": return sysPalette.highlight
                case "appBackgroundColor": return sysPalette.window
                case "topBarColor": return sysPalette.window
                case "backgroundColor": return sysPalette.base
                case "hoverBackgroundColor": return sysPalette.highlight
                case "borderColor": return sysPalette.mid
                case "textColor": return sysPalette.text
                case "hoverTextColor": return sysPalette.highlightedText
                case "dividerColor": return sysPalette.mid
            }
            return sysPalette.text
        }
        var colors = themeColors[name]
        return colors && colors[key] ? colors[key] : sysPalette.text
    }

    function getColor(key) {
        return colorForTheme(currentTheme, key)
    }

    property bool paletteReady: false

    property color themeColor: getColor("themeColor")
    property color appBackgroundColor: getColor("appBackgroundColor")
    property color topBarColor: getColor("topBarColor")
    property color backgroundColor: getColor("backgroundColor")
    property color hoverBackgroundColor: getColor("hoverBackgroundColor")
    property color borderColor: getColor("borderColor")
    property color textColor: getColor("textColor")
    property color hoverTextColor: getColor("hoverTextColor")
    property color dividerColor: getColor("dividerColor")

    Behavior on themeColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on appBackgroundColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on topBarColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on backgroundColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on hoverBackgroundColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on borderColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on textColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on hoverTextColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }
    Behavior on dividerColor { enabled: theme.paletteReady && theme.animationsEnabled; ColorAnimation { duration: 320; easing.type: Easing.InOutQuad } }

    property var themeNames: Object.keys(themeColors).concat(["System"])

    function setTheme(name) {
        if (themeColors[name] !== undefined || name === "System") {
            currentTheme = name
            if (controller) {
                controller.save_theme(name)
            }
        } else {
            console.warn("Theme not found: " + name)
        }
    }

    function initializeTheme() {
        if (controller) {
            var loadedTheme = controller.get_current_theme()
            if (themeColors[loadedTheme] !== undefined || loadedTheme === "System") {
                currentTheme = loadedTheme
            }
        }
        paletteReady = true
    }
}
