pragma Singleton
import QtQuick

QtObject {
    // Fonts
    readonly property string fontRegular: "JetBrainsMonoNLApp"
    readonly property string fontBold: "JetBrainsMonoApp"

    // Font sizes
    readonly property int iconFontSize: 24
    readonly property int titleFontSize: 24
    readonly property int hugeFontSize: 18
    readonly property int bigFontSize: 16
    readonly property int normalFontSize: 14
    readonly property int smallFontSize: 11

    property var windowRef
    property real unit: windowRef ? Math.min(windowRef.width, windowRef.height) / 100 : 7.2

    // Modular font sizes
    property real baseSize: unit * 1.9
    property int h1: Math.round(baseSize * 1.7)
    property int h2: Math.round(baseSize * 1.5)
    property int h3: Math.round(baseSize * 1.35)
    property int h4: Math.round(baseSize * 1.2)
    property int h5: Math.round(baseSize * 1.1)
    property int h6: Math.round(baseSize * 1.0)

    function setWindow(win) {
        windowRef = win
    }
}
