import QtQuick
import QtQuick.Controls

Popup {
    id: settingsPopup
    parent: Overlay.overlay
    modal: true
    focus: true
    clip: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Item.Center

    enter: LayoutMetrics.animationsEnabled ? popupFadeEnter : popupInstantEnter
    exit: LayoutMetrics.animationsEnabled ? popupFadeExit : popupInstantExit

    Transition {
        id: popupInstantEnter
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 0
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 0
            }
        }
    }

    Transition {
        id: popupInstantExit
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 0
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.85
                duration: 0
            }
        }
    }

    Transition {
        id: popupFadeEnter
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 200
                easing.type: Easing.OutBack
            }
        }
    }

    Transition {
        id: popupFadeExit
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.85
                duration: 200
                easing.type: Easing.InQuad
            }
        }
    }
}