import QtQuick
import QtQuick.Controls

Text {
    id: text
    property int pointSize: Typography.titleFontSize
    property color textColor: Theme.themeColor
    font.pointSize: pointSize
    font.family: Typography.fontBold
    color: textColor
}
