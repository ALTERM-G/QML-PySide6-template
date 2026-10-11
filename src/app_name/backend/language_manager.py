from typing import TYPE_CHECKING

from PySide6.QtCore import Property, QObject, Signal

if TYPE_CHECKING:
    from .controller import Controller


class LanguageManager(QObject):
    dataChanged = Signal()

    def __init__(self, controller: "Controller", parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._controller = controller
        self._data: dict = {}
        self._controller.languageChanged.connect(self._reload)
        self._reload()

    def _reload(self) -> None:
        self._data = self._controller.get_language_data()
        self.dataChanged.emit()

    @Property("QVariantMap", notify=dataChanged)
    def titles(self) -> dict:
        return self._data.get("titles", {})

    @Property("QVariantMap", notify=dataChanged)
    def tabs(self) -> dict:
        return self._data.get("tabs", {})

    @Property("QVariantMap", notify=dataChanged)
    def labels(self) -> dict:
        return self._data.get("labels", {})

    @Property("QVariantMap", notify=dataChanged)
    def shortcuts(self) -> dict:
        return self._data.get("shortcuts", {})

    @Property(str, notify=dataChanged)
    def greeting(self) -> str:
        return self._data.get("greeting", "Have Fun !")

    @Property(str, notify=dataChanged)
    def language(self) -> str:
        return self._data.get("language", "English")

    @Property("QVariantList", notify=dataChanged)
    def languages(self) -> list:
        return self._data.get("languages", ["English", "French", "Spanish", "German"])