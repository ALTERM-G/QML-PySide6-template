from PySide6.QtCore import Property, Signal, Slot

from .base_vm import BaseVM


class SettingsVM(BaseVM):
    theme_changed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._theme = "dark"
        self._controller = parent

    @Property(str, notify=theme_changed)
    def theme(self):
        return self._theme

    @theme.setter
    def theme(self, value: str):
        if self._theme != value:
            self._theme = value
            self.theme_changed.emit()
            # Save theme via controller
            if self._controller:
                self._controller.save_theme(value)

    @Slot(result=str)
    def getCurrentTheme(self):
        """Load current theme from controller"""
        if self._controller:
            current_theme = self._controller.get_current_theme()
            if current_theme and current_theme != self._theme:
                self._theme = current_theme
                self.theme_changed.emit()
            return self._theme
        return self._theme
