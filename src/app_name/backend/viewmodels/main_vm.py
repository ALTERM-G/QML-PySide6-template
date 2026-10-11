from PySide6.QtCore import Property, QObject

from .base_vm import BaseVM


class MainVM(BaseVM):
    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._window_title = "QML-PySide6-template"

    @Property(str, constant=True)
    def windowTitle(self) -> str:
        return self._window_title