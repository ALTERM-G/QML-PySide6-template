pragma Singleton
import QtQuick

// Single source of truth for keyboard shortcuts.
//
// To add a shortcut, append ONE entry to `definitions`. Consumers resolve the
// chord with `Shortcuts.primary("id")` (or `Shortcuts.chords("id")` for the
// full list), so nothing else needs touching. The `label` is an English
// fallback used until a translation provides `Lang.shortcuts[id]`.
//
// Users may rebind existing shortcuts (see ShortcutButton) but cannot add new
// ones - the set of actions is fixed here at development time.
QtObject {
    id: root

    property bool capturing: false

    readonly property var definitions: [
        { id: "openSettings",  def: ["Ctrl+,"],            label: "Open settings",  scope: "app" },
        { id: "toggleSidebar", def: ["Ctrl+B"],            label: "Toggle sidebar", scope: "app" },
        { id: "zoomIn",        def: ["Ctrl+=", "Ctrl++"],  label: "Zoom in",        scope: "app" },
        { id: "zoomOut",       def: ["Ctrl+-"],            label: "Zoom out",       scope: "app" },
        { id: "nextTab",       def: ["Ctrl+Tab"],          label: "Next tab",       scope: "settings" },
        { id: "applyChanges",  def: ["Return"],            label: "Apply changes",  scope: "settings" },
        { id: "closeSidebar",  def: ["Escape"],            label: "Close sidebar",  scope: "panel" }
    ]

    // Persisted user edits: id -> [chords]. Reassigned wholesale so every
    // binding that read it (all the Shortcut.sequence bindings) refreshes.
    property var overrides: ({})

    function load(payload) {
        overrides = payload ? payload : ({})
    }

    function defaultFor(id) {
        for (var i = 0; i < definitions.length; i++)
            if (definitions[i].id === id) return definitions[i].def
        return []
    }

    function chords(id) {
        return overrides[id] !== undefined ? overrides[id] : defaultFor(id)
    }

    function primary(id) {
        var c = chords(id)
        return c.length > 0 ? c[0] : ""
    }

    function isCustom(id) {
        return overrides[id] !== undefined
    }

    // Rebinding replaces the chord set with exactly what the user chose, so the
    // result is always predictable. Reset restores the developer defaults.
    function setPrimary(id, sequence) {
        var o = Object.assign({}, overrides)
        o[id] = [sequence]
        overrides = o
        _persist()
    }

    function reset(id) {
        if (!isCustom(id)) return
        var o = Object.assign({}, overrides)
        delete o[id]
        overrides = o
        _persist()
    }

    function resetAll() {
        overrides = ({})
        _persist()
    }

    // id of the (other) action already using `sequence`, or "" if free.
    function ownerOf(sequence, exceptId) {
        for (var i = 0; i < definitions.length; i++) {
            var d = definitions[i]
            if (d.id === exceptId) continue
            var c = chords(d.id)
            for (var j = 0; j < c.length; j++)
                if (c[j] === sequence) return d.id
        }
        return ""
    }

    function _persist() {
        if (typeof controller !== "undefined")
            controller.save_shortcuts(overrides)
    }

    // Model for the keyboard editor: one row per action.
    readonly property var list: {
        var out = []
        for (var i = 0; i < definitions.length; i++) {
            var d = definitions[i]
            out.push({
                id: d.id,
                label: d.label,
                scope: d.scope,
                chords: chords(d.id).slice(),
                custom: isCustom(d.id)
            })
        }
        return out
    }
}
