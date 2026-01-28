from PySide6.QtCore import QObject, Property, Slot
from pathlib import Path
import json

class Controller(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._my_property = "Hello my friend!"
        self._theme_path = Path(__file__).parent.parent / "ressources" / "runtime" / "CurrentTheme.json"
        self._theme_last_modified = 0

    @Property(str)
    def myProperty(self):
        return self._my_property

    @myProperty.setter
    def myProperty(self, value):
        if self._my_property != value:
            self._my_property = value
            self.myPropertyChanged.emit()

    @Slot(str, result=str)
    def mySlot(self, message):
        print(f"Received message in Python: {message}")
        return f"Python says: '{message}' received!"

    # -------------- Theme --------------

    def _load_theme(self):
        try:
            if self._theme_path.exists():
                current_mtime = self._theme_path.stat().st_mtime
                if current_mtime > self._theme_last_modified:
                    with open(self._theme_path) as f:
                        theme_data = json.load(f)
                        self._theme_last_modified = current_mtime
                        return theme_data.get("currentTheme", "Carbon Amber")
        except Exception as e:
            print(f"Error loading theme: {e}")

        return "Carbon Amber"

    @Slot(str)
    def save_theme(self, theme_name):
        try:
            theme_data = {"currentTheme": theme_name}
            with open(self._theme_path, "w") as f:
                json.dump(theme_data, f, indent=2)
            print(f"Theme saved to {self._theme_path}: {theme_name}")
        except Exception as e:
            print(f"Error saving theme: {e}")

    @Slot(result=str)
    def get_current_theme(self):
        return self._load_theme()
