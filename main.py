import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# -------------------------------
# Paths
# -------------------------------
APP_DIR = Path(__file__).parent
UI_DIR = APP_DIR / "ui"
MAIN_QML = UI_DIR / "main.qml"

# -------------------------------
# Create the application
# -------------------------------
app = QGuiApplication(sys.argv)

# -------------------------------
# Load QML
# -------------------------------
engine = QQmlApplicationEngine()
engine.load(str(MAIN_QML))

if not engine.rootObjects():
    sys.exit("Failed to load QML file")

# -------------------------------
# Run the app
# -------------------------------
sys.exit(app.exec())
