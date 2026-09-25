pragma Singleton
import QtQuick

// Single source of truth for keyboard shortcuts.
//
// Change a sequence here and every Shortcut bound to it follows on next
// launch. Only the key combinations live here; the display names come from
// Lang.shortcuts, and whether a shortcut is enabled and what it does stays
// with the component that owns it.
QtObject {
    // ---- App-wide ----
    property string openSettings: "Ctrl+,"
    property string toggleSidebar: "Ctrl+B"
    property string zoomIn: "Ctrl+="
    // Most layouts need Shift to type "+", so accept both forms.
    property string zoomInShifted: "Ctrl++"
    property string zoomOut: "Ctrl+-"

    // ---- Settings popup ----
    property string nextTab: "Ctrl+Tab"
    property string apply: "Return"

    // ---- Panels ----
    property string closePanel: "Escape"

    // Pairs each action with its chord for the Keyboard list in Settings.
    // Entries reference the properties above, so a chord is only ever written
    // once. Keys here are lookups into Lang.shortcuts.
    readonly property var list: [
        { action: "openSettings", sequence: openSettings },
        { action: "toggleSidebar", sequence: toggleSidebar },
        { action: "zoomIn", sequence: zoomIn },
        { action: "zoomOut", sequence: zoomOut },
        { action: "nextTab", sequence: nextTab },
        { action: "applyChanges", sequence: apply },
        { action: "closeSidebar", sequence: closePanel }
    ]
}
