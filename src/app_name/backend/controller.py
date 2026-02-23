from PySide6.QtCore import QObject, Property, Signal, Slot
from pathlib import Path
import json
from .viewmodels import MainVM, SettingsVM


class Controller(QObject):
    myPropertyChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._my_property = "Hello my friend!"
        self._theme_path = (
            Path(__file__).parent.parent
            / "ressources"
            / "runtime"
            / "CurrentTheme.json"
        )
        self._themes_path = (
            Path(__file__).parent.parent / "ressources" / "style" / "themes"
        )
        self._theme_last_modified = 0

        self._main_vm = MainVM(self)
        self._settings_vm = SettingsVM(self)

        self._load_all_themes()

    def _load_all_themes(self):
        self._base_config = {}
        self._theme_colors = {}

        base_path = self._themes_path / "base.json"
        if base_path.exists():
            with open(base_path) as f:
                self._base_config = json.load(f)

        for theme_file in self._themes_path.glob("*.json"):
            if theme_file.stem == "base":
                continue
            with open(theme_file) as f:
                data = json.load(f)
                if "colors" in data:
                    self._theme_colors[theme_file.stem] = data["colors"]

    @Property(str, notify=myPropertyChanged)
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

    @Slot(result=dict)
    def get_base_config(self):
        return self._base_config

    @Slot(result=dict)
    def get_theme_colors(self):
        return self._theme_colors

    # View Model Properties
    @Property(QObject, constant=True)
    def mainVM(self):
        return self._main_vm

    @Property(QObject, constant=True)
    def settingsVM(self):
        return self._settings_vm
