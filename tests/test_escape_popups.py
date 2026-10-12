from pathlib import Path

import pytest
from PySide6.QtCore import QMetaObject, QObject, Qt, QUrl
from PySide6.QtTest import QTest

import run

ROOT = Path(__file__).resolve().parent.parent
MAIN_QML = ROOT / "src" / "app_name" / "ui" / "main.qml"


def _walk(obj: QObject) -> list[QObject]:
    out = [obj]
    for child in obj.children():
        out.extend(_walk(child))
    return out


def _invoke(obj: QObject, method: str) -> None:
    QMetaObject.invokeMethod(obj, method, Qt.DirectConnection)


@pytest.fixture
def main_window(qapp):
    engine = run.build_engine()
    engine.load(QUrl.fromLocalFile(str(MAIN_QML)))
    window = engine.rootObjects()[0]
    window.show()
    QTest.qWait(300)
    return engine, window


def test_escape_closes_dropdown_not_settings(main_window):
    _, window = main_window
    objects = _walk(window)
    popups = [
        o for o in objects if "Popup_QMLTYPE" in o.metaObject().className()
    ]
    settings_popup = next(p for p in popups if p.property("modal"))
    combo_popup = next(p for p in popups if not p.property("modal"))

    _invoke(settings_popup, "open")
    _invoke(combo_popup, "open")
    QTest.qWait(250)
    assert settings_popup.property("opened")
    assert combo_popup.property("opened")

    QTest.keyClick(window, Qt.Key.Key_Escape)
    QTest.qWait(300)
    assert not combo_popup.property("opened"), "Escape should close the dropdown"
    assert settings_popup.property("opened"), "Escape should not close the settings popup"

    QTest.keyClick(window, Qt.Key.Key_Escape)
    QTest.qWait(300)
    assert not settings_popup.property("opened"), "Escape should close the settings popup"
