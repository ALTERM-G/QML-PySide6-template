import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl, QTimer
from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, QQmlComponent
from app_name.backend.controller import Controller

_qml_objects = []
_data_object = None


def main():
    app = QGuiApplication(sys.argv)
    src_path = Path(__file__).parent / "src" / "app_name"

    # ---------------- Components module -----------------
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(src_path / "ui"))

    def load_qml(engine, filename, context_name, callback=None):
        path = src_path / "resources" / filename
        if path.exists():
            component = QQmlComponent(engine, QUrl.fromLocalFile(str(path)))
            obj = component.create()
            if obj:
                engine.rootContext().setContextProperty(context_name, obj)
                if callback:
                    callback(obj)
                return obj
            else:
                print(
                    f"Error: Failed to create QML object from {filename}",
                    file=sys.stderr,
                )
                for error in component.errors():
                    print(f"  - {error.toString()}", file=sys.stderr)
                return None
        else:
            print(f"Error: QML file not found at {path}", file=sys.stderr)
        return None

    # ---------------- Fonts ----------------
    assets_path = src_path / "resources" / "assets"
    font_dir = assets_path / "fonts"
    loaded_fonts = {}

    if font_dir.exists():
        for font_path in font_dir.glob("*.ttf"):
            font_id = QFontDatabase.addApplicationFont(str(font_path))
            if font_id == -1:
                print(f"Failed to load font '{font_path.name}'", file=sys.stderr)
                continue
            families = QFontDatabase.applicationFontFamilies(font_id)
            if not families:
                print(f"No families found for font '{font_path.name}'", file=sys.stderr)
                continue
            family_name = families[0]
            loaded_fonts[font_path.name] = family_name
            print(f"Loaded font '{font_path.name}' with family '{family_name}'")

    engine.rootContext().setContextProperty("LoadedFonts", loaded_fonts)
    main_regular_font_file = "JetBrainsMonoNL-Regular-App.ttf"
    if main_regular_font_file in loaded_fonts:
        app.setFont(QFont(loaded_fonts[main_regular_font_file]))

    # ---------------- Icons ----------------
    icon_path = src_path / "resources" / "icons"
    QIcon.setThemeSearchPaths([str(icon_path)])
    app.setWindowIcon(
        QIcon(str(src_path / "resources" / "assets" / "icons" / "icon.svg"))
    )

    # ---------------- Create Controller ----------------
    controller = Controller()
    engine.rootContext().setContextProperty("controller", controller)
    engine.rootContext().setContextProperty("mainVM", controller.mainVM)
    engine.rootContext().setContextProperty("settingsVM", controller.settingsVM)

    # ---------------- Load scale factor ----------------
    scale_factor = controller.get_scale_factor()

    # ---------------- Load QML files ----------------
    qml_singletons = [
        (
            "LayoutMetrics",
            "style/LayoutMetrics.qml",
            lambda obj: obj.setScaleFactor(scale_factor),
        ),
        (
            "Metrics",
            "style/Metrics.qml",
            lambda obj: obj.setScaleFactor(scale_factor),
        ),
        ("SVGLibrary", "style/SVGLibrary.qml", None),
        (
            "Typography",
            "style/Typography.qml",
            lambda obj: obj.setScaleFactor(scale_factor),
        ),
        ("UiData", "data/UiData.qml", None),
        ("Theme", "style/Theme.qml", lambda obj: obj.initializeTheme()),
    ]
    qml_objects = {}

    for name, path, callback in qml_singletons:
        qml_objects[name] = load_qml(engine, path, name, callback)

    # ---------------- Load main.qml -----------------
    main_qml = src_path / "ui" / "main.qml"

    if not main_qml.exists():
        print(f"Error: main.qml not found at {main_qml}", file=sys.stderr)
        sys.exit(-1)

    try:
        engine.load(QUrl.fromLocalFile(str(main_qml)))
    except Exception as e:
        print(f"Error loading QML: {e}", file=sys.stderr)
        sys.exit(-1)

    if not engine.rootObjects():
        print(f"Error: Failed to load main.qml", file=sys.stderr)
        sys.exit(-1)

    exit_code = app.exec()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
