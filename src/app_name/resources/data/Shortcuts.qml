import QtQuick


QtObject {
    id: root
    property bool capturing: false

    readonly property var definitions: [
        { id: "openSettings",  def: ["Ctrl+,"],            label: "Open settings",  scope: "app" },
        { id: "toggleSidebar", def: ["Ctrl+B"],            label: "Toggle sidebar", scope: "app" },
        { id: "zoomIn",        def: ["Ctrl+=", "Ctrl++"],  label: "Zoom in",        scope: "app" },
        { id: "zoomOut",       def: ["Ctrl+-"],            label: "Zoom out",       scope: "app" },
        { id: "nextTab", def: ["Ctrl+Tab"], label: "Next tab", scope: "settings" },
        { id: "prevTab", def: ["Ctrl+Shift+Tab"], label: "Previous tab", scope: "settings" },
        { id: "applyChanges",  def: ["Return"],            label: "Apply changes",  scope: "settings", editable: false },
        { id: "closeSidebar",  def: ["Escape"],            label: "Close sidebar",  scope: "panel",     editable: false }
    ]

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

    readonly property var list: {
        var out = []
        for (var i = 0; i < definitions.length; i++) {
            var d = definitions[i]
            if (d.editable === false) continue
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
