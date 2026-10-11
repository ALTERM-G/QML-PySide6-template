import QtQuick
import QtQuick.Controls

QtObject {
    id: theme
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

    function getColor(name) {
        if (currentTheme === "System") {
            switch(name) {
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
        var colors = themeColors[currentTheme]
        return colors && colors[name] ? colors[name] : sysPalette.text
    }

    readonly property color themeColor: getColor("themeColor")
    readonly property color appBackgroundColor: getColor("appBackgroundColor")
    readonly property color topBarColor: getColor("topBarColor")
    readonly property color backgroundColor: getColor("backgroundColor")
    readonly property color hoverBackgroundColor: getColor("hoverBackgroundColor")
    readonly property color borderColor: getColor("borderColor")
    readonly property color textColor: getColor("textColor")
    readonly property color hoverTextColor: getColor("hoverTextColor")
    readonly property color dividerColor: getColor("dividerColor")

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
    }
}
