from typing import TYPE_CHECKING

from PySide6.QtCore import Property, Signal, Slot

from .base_vm import BaseVM

if TYPE_CHECKING:
    from ..controller import Controller


class SettingsVM(BaseVM):
    theme_changed = Signal()

    def __init__(self, parent: "Controller | None" = None) -> None:
        super().__init__(parent)
        self._controller = parent
        self._theme = self._controller.get_current_theme() if self._controller else "System"

    @Property(str, notify=theme_changed)
    def theme(self) -> str:
        return self._theme

    @theme.setter
    def theme(self, value: str) -> None:
        if self._theme != value:
            self._theme = value
            self.theme_changed.emit()
            if self._controller:
                self._controller.save_theme(value)

    @Slot(result=str)
    def getCurrentTheme(self) -> str:
        if self._controller:
            current_theme = self._controller.get_current_theme()
            if current_theme and current_theme != self._theme:
                self._theme = current_theme
                self.theme_changed.emit()
            return self._theme
        return self._theme