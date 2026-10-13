import QtQuick
import QtQuick.Controls

Item {
    id: root
    anchors.fill: parent
    visible: false
    opacity: 0
    z: (Overlay.overlay ? Overlay.overlay.z : 1000000) + 1

    property var pendingAction: null
    property var grabResult: null
    property int grabToken: 0

    function run(action) {
        if (!LayoutMetrics.animationsEnabled || !action) {
            if (action)
                action()
            return
        }
        pendingAction = action
        grabToken++
        var token = grabToken
        var sourceItem = LayoutMetrics.window ? LayoutMetrics.window.contentItem : null
        if (!sourceItem) {
            commit()
            return
        }
        grabResult = sourceItem.grabToImage(function (result) {
            if (token !== grabToken || !pendingAction)
                return
            grabResult = result
            snapshot.source = result.url
            root.opacity = 1
            root.visible = true
            root.commit()
        }, Qt.size(sourceItem.width, sourceItem.height))
        fallback.restart()
    }

    function commit() {
        if (!pendingAction)
            return
        fallback.stop()
        var action = pendingAction
        pendingAction = null
        action()
        fadeOut.start()
    }

    Image {
        id: snapshot
        anchors.fill: parent
        fillMode: Image.Stretch
        smooth: true
        cache: false
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        from: 1
        to: 0
        duration: 300
        easing.type: Easing.InOutQuad
        onFinished: {
            root.visible = false
            root.grabResult = null
            snapshot.source = ""
        }
    }

    Timer {
        id: fallback
        interval: 120
        onTriggered: root.commit()
    }
}
