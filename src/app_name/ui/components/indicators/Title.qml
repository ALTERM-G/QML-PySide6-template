import QtQuick
import QtQuick.Controls

Text {
    id: text
    property int pointSize: Typography.h1
    property color textColor: Theme.themeColor
    font.pointSize: pointSize
    font.family: Typography.fontBold
    color: textColor
}
