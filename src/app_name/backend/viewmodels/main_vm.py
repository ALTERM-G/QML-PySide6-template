from PySide6.QtCore import Property, QObject, Signal, Slot

from .base_vm import BaseVM


class MainVM(BaseVM):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._window_title = "QML-PySide6-template"

    @Property(str, constant=True)
    def windowTitle(self):
        return self._window_title
