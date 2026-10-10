import QtQuick
import components

// Themed chord field: shows the current shortcut and captures a new one when
// clicked. Styling mirrors Button.qml / ComboBox.qml so it sits naturally in
// the settings panel.
Rectangle {
    id: root

    property string actionId: ""
    property bool recording: false
    property bool rejected: false

    readonly property var chords: actionId !== "" ? Shortcuts.chords(actionId) : []
    readonly property string chordText: chords.length > 0 ? chords.join(" / ") : "-"
    readonly property bool hovered: mouseArea.containsMouse

    width: LayoutMetrics.size.shortcutControlWidth
    height: LayoutMetrics.size.controlHeight * 1.15
    radius: LayoutMetrics.radius.m
    border.width: LayoutMetrics.border.l
    border.color: (recording || rejected) ? Theme.themeColor : Theme.borderColor
    color: (recording || hovered) ? Theme.hoverBackgroundColor : Theme.backgroundColor

    activeFocusOnTab: true

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }
    }

    Timer {
        id: rejectTimer
        interval: 1500
        onTriggered: root.rejected = false
    }

    function startRecording() {
        rejected = false
        recording = true
        Shortcuts.capturing = true
        forceActiveFocus()
    }

    function stopRecording() {
        recording = false
        Shortcuts.capturing = false
    }

    // Losing focus (e.g. clicking elsewhere) abandons the capture.
    onActiveFocusChanged: {
        if (!activeFocus && recording)
            stopRecording()
    }

    // Never leave the app in "capturing" state if this editor goes away.
    Component.onDestruction: {
        if (recording)
            Shortcuts.capturing = false
    }

    Text {
        anchors.centerIn: parent
        width: parent.width - LayoutMetrics.spacing.sm * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        text: root.rejected ? Lang.labels.shortcutInUse
                           : (root.recording ? Lang.labels.pressShortcut : root.chordText)
        font.pixelSize: Typography.h6
        font.family: Typography.fontBold
        font.weight: Font.Bold
        color: (root.hovered && !root.rejected) ? Theme.hoverTextColor : Theme.textColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.recording ? root.stopRecording() : root.startRecording()
    }

    Keys.onPressed: function (event) {
        if (!root.recording)
            return
        // Consume everything so app-wide shortcuts and the popup's own
        // Escape handling do not react while we are recording a chord.
        event.accepted = true

        if (event.key === Qt.Key_Escape) {
            root.stopRecording()
            return
        }

        var sequence = root.sequenceFromEvent(event)
        if (sequence === "")
            return // modifier-only or unknown key: keep recording

        root.stopRecording()

        var owner = Shortcuts.ownerOf(sequence, root.actionId)
        if (owner !== "") {
            root.rejected = true
            rejectTimer.restart()
            return
        }

        Shortcuts.setPrimary(root.actionId, sequence)
    }

    Keys.onReleased: function (event) {
        if (root.recording)
            event.accepted = true
    }

    // Builds a portable chord string ("Ctrl+Shift+K") from a key event.
    // Returns "" for modifier-only presses so they don't end the capture.
    function sequenceFromEvent(event) {
        var parts = []
        if (event.modifiers & Qt.ControlModifier) parts.push("Ctrl")
        if (event.modifiers & Qt.AltModifier) parts.push("Alt")
        if (event.modifiers & Qt.ShiftModifier) parts.push("Shift")
        if (event.modifiers & Qt.MetaModifier) parts.push("Meta")

        var name = keyName(event)
        if (name === "")
            return ""

        parts.push(name)
        return parts.join("+")
    }

    function keyName(event) {
        var k = event.key

        // Printable ASCII: letters, digits and punctuation. Deriving the name
        // from the key code (rather than event.text) is what lets modifier
        // combos like Ctrl+S be captured - QML leaves text empty there.
        if (k >= 0x21 && k <= 0x7e)
            return String.fromCharCode(k)

        switch (k) {
        case Qt.Key_Space: return "Space"
        case Qt.Key_Tab: return "Tab"
        case Qt.Key_Backtab: return "Backtab"
        case Qt.Key_Return: return "Return"
        case Qt.Key_Enter: return "Enter"
        case Qt.Key_Backspace: return "Backspace"
        case Qt.Key_Delete: return "Delete"
        case Qt.Key_Up: return "Up"
        case Qt.Key_Down: return "Down"
        case Qt.Key_Left: return "Left"
        case Qt.Key_Right: return "Right"
        case Qt.Key_Home: return "Home"
        case Qt.Key_End: return "End"
        case Qt.Key_PageUp: return "PgUp"
        case Qt.Key_PageDown: return "PgDown"
        case Qt.Key_Insert: return "Ins"
        case Qt.Key_F1: return "F1"
        case Qt.Key_F2: return "F2"
        case Qt.Key_F3: return "F3"
        case Qt.Key_F4: return "F4"
        case Qt.Key_F5: return "F5"
        case Qt.Key_F6: return "F6"
        case Qt.Key_F7: return "F7"
        case Qt.Key_F8: return "F8"
        case Qt.Key_F9: return "F9"
        case Qt.Key_F10: return "F10"
        case Qt.Key_F11: return "F11"
        case Qt.Key_F12: return "F12"
        }

        // Layout-dependent keys (e.g. accented characters) still arrive as text
        // when no modifier is held.
        var text = event.text
        if (text && text.length === 1 && text.charCodeAt(0) > 0x20)
            return text.toUpperCase()

        return ""
    }
}
