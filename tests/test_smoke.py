from pathlib import Path

from PySide6.QtCore import QUrl

import run

ROOT = Path(__file__).resolve().parent.parent
MAIN_QML = ROOT / "src" / "app_name" / "ui" / "main.qml"


def test_controller_defaults():
    from app_name.backend.controller import Controller

    controller = Controller()
    assert controller.get_scale_factor() >= 0.5
    assert isinstance(controller.get_animations_enabled(), bool)
    assert isinstance(controller.get_shortcuts(), dict)


def test_app_boots(qapp):
    engine = run.build_engine()
    engine.load(QUrl.fromLocalFile(str(MAIN_QML)))
    assert engine.rootObjects(), "main.qml failed to load"
