import json
import sys
from collections.abc import Callable
from pathlib import Path

from PySide6.QtCore import Property, QEvent, QObject, QUrl, Signal
from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, QQmlComponent

from app_name.backend.controller import Controller
from app_name.backend.language_manager import LanguageManager


class InputTracker(QObject):
    keyboardChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._keyboard = False

    def _get_keyboard(self) -> bool:
        return self._keyboard

    def _set_keyboard(self, value: bool) -> None:
        if value != self._keyboard:
            self._keyboard = value
            self.keyboardChanged.emit()

    keyboard = Property(bool, _get_keyboard, _set_keyboard, notify=keyboardChanged)

    def eventFilter(self, watched: QObject, event: QEvent) -> bool:
        event_type = event.type()
        if event_type == QEvent.Type.KeyPress:
            self._set_keyboard(True)
        elif event_type in (
            QEvent.Type.MouseMove,
            QEvent.Type.MouseButtonPress,
            QEvent.Type.MouseButtonDblClick,
            QEvent.Type.Wheel,
        ):
            self._set_keyboard(False)
        return False


def _load_singleton(
    engine: QQmlApplicationEngine,
    src_path: Path,
    filename: str,
    context_name: str,
    callback: Callable[[QObject], None] | None = None,
) -> QObject | None:
    path = src_path / "resources" / filename
    if not path.exists():
        print(f"Error: QML file not found at {path}", file=sys.stderr)
        return None

    component = QQmlComponent(engine, QUrl.fromLocalFile(str(path)))
    obj = component.create()
    if obj is None:
        print(f"Error: Failed to create QML object from {filename}", file=sys.stderr)
        for error in component.errors():
            print(f"  - {error.toString()}", file=sys.stderr)
        return None

    engine.rootContext().setContextProperty(context_name, obj)
    if callback:
        callback(obj)
    return obj


def _load_fonts(
    app: QGuiApplication, src_path: Path
) -> tuple[dict[str, str], set[str], str]:
    font_dir = src_path / "resources" / "assets" / "fonts"
    loaded_fonts: dict[str, str] = {}

    if font_dir.exists():
        for pattern in ("*.ttf", "*.otf", "*.ttc"):
            for font_path in sorted(font_dir.rglob(pattern)):
                font_id = QFontDatabase.addApplicationFont(str(font_path))
                if font_id == -1:
                    print(f"Failed to load font '{font_path.name}'", file=sys.stderr)
                    continue
                families = QFontDatabase.applicationFontFamilies(font_id)
                if not families:
                    print(f"No families found for font '{font_path.name}'", file=sys.stderr)
                    continue
                loaded_fonts[font_path.name] = families[0]

    all_families = set(loaded_fonts.values())
    font_family: str = next(iter(all_families), "sans-serif")

    config_path = font_dir / "fonts.json"
    if config_path.exists():
        try:
            with open(config_path) as f:
                preferred = json.load(f).get("defaultFamily", "")
            if preferred in all_families:
                font_family = preferred
        except Exception:
            pass

    return loaded_fonts, all_families, font_family


def build_engine(src_path: Path | None = None) -> QQmlApplicationEngine:
    if src_path is None:
        src_path = Path(__file__).parent / "src" / "app_name"

    engine = QQmlApplicationEngine()
    engine.addImportPath(str(src_path / "ui"))

    app = QGuiApplication.instance()

    input_tracker = InputTracker(app)
    app.installEventFilter(input_tracker)
    engine.rootContext().setContextProperty("InputState", input_tracker)

    loaded_fonts, all_families, font_family = _load_fonts(app, src_path)
    engine.rootContext().setContextProperty("LoadedFonts", loaded_fonts)
    engine.rootContext().setContextProperty("FontFamilies", list(all_families))

    app.setWindowIcon(
        QIcon(str(src_path / "resources" / "assets" / "icons" / "icon.svg"))
    )

    controller = Controller(app)
    engine.rootContext().setContextProperty("controller", controller)
    engine.rootContext().setContextProperty("mainVM", controller.mainVM)
    engine.rootContext().setContextProperty("settingsVM", controller.settingsVM)

    saved_family = controller.get_font_family()
    if saved_family and saved_family in all_families:
        font_family = saved_family
    if font_family != "sans-serif":
        app.setFont(QFont(font_family))
    engine.rootContext().setContextProperty("FontFamily", font_family)

    language_manager = LanguageManager(controller, controller)
    engine.rootContext().setContextProperty("Lang", language_manager)

    scale_factor = controller.get_scale_factor()
    corner_radius = controller.get_corner_radius()
    animations_enabled = controller.get_animations_enabled()

    singletons = [
        (
            "LayoutMetrics",
            "style/LayoutMetrics.qml",
            lambda obj: (
                obj.setScaleFactor(scale_factor),
                obj.setIsContinuous(controller.get_is_continuous()),
                obj.setCornerRadiusFactor(corner_radius),
                obj.setAnimationsEnabled(animations_enabled),
            ),
        ),
        ("SVGLibrary", "style/SVGLibrary.qml", None),
        (
            "Typography",
            "style/Typography.qml",
            lambda obj: (
                obj.setScaleFactor(scale_factor),
                obj.setIsContinuous(controller.get_is_continuous()),
            ),
        ),
        ("Shortcuts", "data/Shortcuts.qml", lambda obj: obj.load(controller.get_shortcuts())),
        ("Theme", "style/Theme.qml", lambda obj: obj.initializeTheme()),
    ]
    for name, path, callback in singletons:
        _load_singleton(engine, src_path, path, name, callback)

    return engine


def main() -> None:
    app = QGuiApplication(sys.argv)
    src_path = Path(__file__).parent / "src" / "app_name"

    engine = build_engine(src_path)

    main_qml = src_path / "ui" / "main.qml"
    if not main_qml.exists():
        print(f"Error: main.qml not found at {main_qml}", file=sys.stderr)
        sys.exit(-1)

    engine.load(QUrl.fromLocalFile(str(main_qml)))
    if not engine.rootObjects():
        print("Error: Failed to load main.qml", file=sys.stderr)
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()