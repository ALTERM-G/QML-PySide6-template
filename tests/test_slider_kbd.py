
import pytest
from PySide6.QtCore import Qt, QUrl
from PySide6.QtQuick import QQuickItem
from PySide6.QtTest import QTest

import run

HARNESS = """
import QtQuick
import QtQuick.Window
import components

Window {
    width: 600
    height: 260
    visible: true

    Column {
        anchors.centerIn: parent
        spacing: 24

        Slider {
            id: scaleSlider
            objectName: "scaleSlider"
            from: 0
            to: 200
            value: 50
            onMoved: scaleSpin.value = Math.round(value)
        }

        SpinBox {
            id: scaleSpin
            objectName: "scaleSpin"
            from: 0
            to: 200
            value: 50
        }

        Slider {
            id: radiusSlider
            objectName: "radiusSlider"
            discrete: true
            step: 2
            from: 0
            to: 100
            value: 20
        }
    }
}
"""


def _window(slider_window):
    return slider_window[1]


def _find(window, name):
    return window.findChild(QQuickItem, name)


@pytest.fixture
def slider_window(qapp, tmp_path):
    engine = run.build_engine()
    harness = tmp_path / "slider_host.qml"
    harness.write_text(HARNESS)
    engine.load(QUrl.fromLocalFile(str(harness)))
    window = engine.rootObjects()[0]
    window.show()
    return engine, window


def test_continuous_slider_steps(slider_window):
    scale = _find(_window(slider_window), "scaleSlider")
    scale.forceActiveFocus()

    QTest.keyClick(_window(slider_window), Qt.Key.Key_Right)
    assert scale.property("value") == 54

    QTest.keyClick(_window(slider_window), Qt.Key.Key_Left)
    assert scale.property("value") == 50


def test_slider_moved_syncs_spinbox(slider_window):
    scale = _find(_window(slider_window), "scaleSlider")
    spin = _find(_window(slider_window), "scaleSpin")
    scale.forceActiveFocus()

    QTest.keyClick(_window(slider_window), Qt.Key.Key_Right)
    assert spin.property("value") == 54


def test_discrete_slider_steps(slider_window):
    radius = _find(_window(slider_window), "radiusSlider")
    radius.forceActiveFocus()

    QTest.keyClick(_window(slider_window), Qt.Key.Key_Left)
    assert radius.property("value") == 18

    QTest.keyClick(_window(slider_window), Qt.Key.Key_Right)
    assert radius.property("value") == 20