import QtQuick
import QtQuick.Controls

Text {
    id: text
    property bool style_2: false
    property int pointSize: style_2 ? Typography.caption : Typography.h6
    property color textColor: style_2 ? Theme.borderColor : Theme.textColor
    font.pointSize: pointSize
    font.family: Typography.fontBold
    color: textColor
}
