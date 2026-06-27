from PySide6.QtCore import QObject, Property, Signal
from pathlib import Path
import json


class LanguageManager(QObject):
    dataChanged = Signal()

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._data = {}
        self._controller.languageChanged.connect(self._reload)
        self._reload()

    def _reload(self):
        self._data = self._controller.get_language_data()
        self.dataChanged.emit()

    @Property("QVariantMap", notify=dataChanged)
    def titles(self):
        return self._data.get("titles", {})

    @Property("QVariantMap", notify=dataChanged)
    def tabs(self):
        return self._data.get("tabs", {})

    @Property("QVariantMap", notify=dataChanged)
    def labels(self):
        return self._data.get("labels", {})

    @Property(str, notify=dataChanged)
    def greeting(self):
        return self._data.get("greeting", "Have Fun !")

    @Property(str, notify=dataChanged)
    def language(self):
        return self._data.get("language", "English")

    @Property("QVariantList", notify=dataChanged)
    def languages(self):
        return self._data.get("languages", ["English", "French", "Spanish", "German"])
