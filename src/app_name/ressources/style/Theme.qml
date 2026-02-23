pragma Singleton
import QtQuick
import QtQuick.Controls

QtObject {
    id: theme
    property string currentTheme: "System"
    property SystemPalette sysPalette: SystemPalette {
        colorGroup: SystemPalette.Active
    }
    property var baseConfig: ({})
    property var themeColors: ({})
    Component.onCompleted: loadThemes()

    function loadThemes() {
        if (controller) {
            baseConfig = controller.get_base_config()
            themeColors = controller.get_theme_colors()
        }
    }

    readonly property string fontRegular: baseConfig.fonts ? baseConfig.fonts.regular : "JetBrainsMonoNLApp"
    readonly property string fontBold: baseConfig.fonts ? baseConfig.fonts.bold : "JetBrainsMonoApp"

    readonly property int iconFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.icon : 24
    readonly property int titleFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.title : 24
    readonly property int hugeFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.huge : 18
    readonly property int bigFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.big : 16
    readonly property int normalFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.normal : 14
    readonly property int smallFontSize: baseConfig.fontSizes ? baseConfig.fontSizes.small : 11

    property var windowRef
    property real unit: windowRef ? Math.min(windowRef.width, windowRef.height) / 100 : 7.2

    function round(value) {
        return Math.round(value * baseSize)
    }

    property real baseSize: unit * 1.9
    property int h1: round(1.7)
    property int h2: round(1.5)
    property int h3: round(1.35)
    property int h4: round(1.2)
    property int h5: round(1.1)
    property int h6: round(1.0)

    function setWindow(win) {
        windowRef = win
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
