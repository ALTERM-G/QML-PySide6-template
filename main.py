<<<<<<< HEAD
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from PySide6.QtCore import QUrl
from PySide6.QtGui import QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, QQmlComponent

from app_name.backend.controller import Controller

_qml_objects = []
_data_object = None


def main():
    app = QGuiApplication(sys.argv)

    # ---------------- Components module -----------------
    qml_modules_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "."
    )
    engine = QQmlApplicationEngine()
    engine.addImportPath(os.path.join(qml_modules_path, "ui"))

    def load_qml(engine, filename, context_name, callback=None):
        path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "ressources", filename
        )
        if os.path.exists(path):
            component = QQmlComponent(engine, QUrl.fromLocalFile(path))
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
    assets_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "ressources", "assets"
    )
    font_dir = os.path.join(assets_path, "fonts")
    if os.path.exists(font_dir):
        for font_filename in os.listdir(font_dir):
            if font_filename.endswith(".ttf"):
                font_path = os.path.join(font_dir, font_filename)
                font_id = QFontDatabase.addApplicationFont(font_path)
                family = QFontDatabase.applicationFontFamilies(font_id)[0]

    # ---------------- Icons ----------------
    base_path = os.path.dirname(os.path.abspath(__file__))
    icon_path = os.path.join(base_path, "ressources", "icons")
    QIcon.setThemeSearchPaths([icon_path])
    app.setWindowIcon(
        QIcon(os.path.join(base_path, "ressources/assets/icons/icon.svg"))
    )

    # ---------------- Create Controller ----------------
    controller = Controller()
    engine.rootContext().setContextProperty("controller", controller)

    # ---------------- Load QML files ----------------
    qml_singletons = [
        ("AppConfig", "style/AppConfig.qml", None),
        ("ASCIIart", "style/ASCIIart.qml", None),
        ("LayoutMetrics", "style/LayoutMetrics.qml", None),
        ("SVGLibrary", "style/SVGLibrary.qml", None),
        ("Typography", "style/Typography.qml", None),
        ("Theme", "style/Theme.qml", lambda obj: obj.initializeTheme()),
    ]
    qml_objects = {}

    for name, path, callback in qml_singletons:
        qml_objects[name] = load_qml(engine, path, name, callback)

    # ---------------- Load main.qml -----------------
    main_qml = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "ui", "main.qml"
    )
    engine.load(QUrl.fromLocalFile(main_qml))

    if not engine.rootObjects():
        sys.exit(-1)
    exit_code = app.exec()
    sys.exit(exit_code)

=======
import sys
from pathlib import Path

project_root = Path(__file__).resolve().parent
sys.path.insert(0, str(project_root / "src"))

from app_name.main import main
>>>>>>> 9164856 (Refactor)

if __name__ == "__main__":
    main()
