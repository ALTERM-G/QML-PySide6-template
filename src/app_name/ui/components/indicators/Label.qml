import QtQuick
import QtQuick.Controls

Text {
    id: text
    property int pointSize: Typography.h6
    property color textColor: Theme.textColor
    font.pointSize: pointSize
    font.family: Typography.fontBold
    color: textColor
}
