import json
import logging
from pathlib import Path

from PySide6.QtCore import Property, QIODevice, QObject, QSaveFile, Signal, Slot

from .viewmodels import MainVM, SettingsVM

logger = logging.getLogger(__name__)

DEFAULT_THEME = "Carbon Amber"


class Controller(QObject):
    languageChanged = Signal()
    storageError = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._theme_path = (
            Path(__file__).parent.parent / "resources" / "runtime" / "CurrentTheme.json"
        )
        self._settings_path = (
            Path(__file__).parent.parent / "resources" / "runtime" / "Settings.json"
        )
        self._themes_path = (
            Path(__file__).parent.parent / "resources" / "style" / "themes"
        )
        self._theme_last_modified = 0
        self._theme_cache = DEFAULT_THEME

        self._main_vm = MainVM(self)
        self._settings_vm = SettingsVM(self)

        self._language_files = ["en.json", "fr.json", "de.json", "es.json", "it.json"]
        self._languages_path = (
            Path(__file__).parent.parent / "resources" / "assets" / "languages"
        )

        self._load_all_themes()
        self._current_language = self.get_language()

    def _read_json(self, path: Path, context: str) -> dict | None:
        if not path.exists():
            return None
        try:
            with open(path) as f:
                data = json.load(f)
        except (OSError, ValueError) as e:
            logger.warning("Could not read %s at %s: %s", context, path, e)
            return None
        if not isinstance(data, dict):
            logger.warning("Ignoring %s at %s: expected a JSON object", context, path)
            return None
        return data

    def _write_json(self, path: Path, data: dict, context: str) -> bool:
        try:
            payload = json.dumps(data, indent=2).encode("utf-8")
        except (TypeError, ValueError) as e:
            logger.error("Could not serialise %s: %s", context, e)
            self.storageError.emit(f"Could not save {context}: {e}")
            return False
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            out = QSaveFile(str(path))
            if not out.open(QIODevice.WriteOnly):
                raise OSError(out.errorString())
            if out.write(payload) == -1:
                raise OSError(out.errorString())
            if not out.commit():
                raise OSError(out.errorString())
        except OSError as e:
            logger.error("Could not write %s at %s: %s", context, path, e)
            self.storageError.emit(f"Could not save {context}: {e}")
            return False
        return True

    def _load_all_themes(self) -> None:
        self._base_config: dict = {}
        self._theme_colors: dict = {}

        base = self._read_json(self._themes_path / "base.json", "theme base")
        if base is not None:
            self._base_config = base

        for theme_path in sorted(self._themes_path.glob("*.json")):
            if theme_path.stem == "base":
                continue
            data = self._read_json(theme_path, f"theme '{theme_path.stem}'")
            if data is not None and "colors" in data:
                self._theme_colors[theme_path.stem] = data["colors"]

    def _load_theme(self) -> str:
        try:
            if self._theme_path.exists():
                current_mtime = self._theme_path.stat().st_mtime
                if current_mtime > self._theme_last_modified:
                    data = self._read_json(self._theme_path, "current theme")
                    if data is not None:
                        self._theme_cache = data.get("currentTheme", DEFAULT_THEME)
                    self._theme_last_modified = current_mtime
        except OSError as e:
            logger.warning("Could not stat current theme at %s: %s", self._theme_path, e)
        return self._theme_cache

    @Slot(str)
    def save_theme(self, theme_name: str) -> None:
        self._theme_cache = theme_name
        if self._write_json(
            self._theme_path, {"currentTheme": theme_name}, "current theme"
        ):
            try:
                self._theme_last_modified = self._theme_path.stat().st_mtime
            except OSError as e:
                logger.warning(
                    "Could not stat current theme at %s: %s", self._theme_path, e
                )

    @Slot(result=str)
    def get_current_theme(self) -> str:
        return self._load_theme()

    @Slot(result=dict)
    def get_base_config(self) -> dict:
        return self._base_config

    @Slot(result=dict)
    def get_theme_colors(self) -> dict:
        return self._theme_colors

    def _load_settings(self) -> dict:
        data = self._read_json(self._settings_path, "settings")
        return data if data is not None else {}

    def _save_settings(self, settings: dict) -> None:
        self._write_json(self._settings_path, settings, "settings")

    def _update_settings(self, **updates: object) -> dict:
        settings = self._load_settings()
        settings.update(updates)
        self._save_settings(settings)
        return settings

    @Slot(float)
    def save_scale_factor(self, factor: float) -> None:
        self._update_settings(scaleFactor=factor)

    @Slot(result=float)
    def get_scale_factor(self) -> float:
        return self._load_settings().get("scaleFactor", 1.0)

    @Slot(float)
    def save_corner_radius(self, factor: float) -> None:
        self._update_settings(cornerRadius=factor)

    @Slot(result=float)
    def get_corner_radius(self) -> float:
        return self._load_settings().get("cornerRadius", 1.0)

    @Slot(bool)
    def save_animations_enabled(self, value: bool) -> None:
        self._update_settings(animationsEnabled=bool(value))

    @Slot(result=bool)
    def get_animations_enabled(self) -> bool:
        return self._load_settings().get("animationsEnabled", True)

    @Slot(bool)
    def save_is_continuous(self, value: bool) -> None:
        self._update_settings(isContinuous=value)

    @Slot(result=bool)
    def get_is_continuous(self) -> bool:
        return self._load_settings().get("isContinuous", True)

    @Slot(str)
    def save_font_family(self, family: str) -> None:
        self._update_settings(fontFamily=family)

    @Slot(result=str)
    def get_font_family(self) -> str:
        return self._load_settings().get("fontFamily", "JetBrains Mono")

    @Slot(int)
    def save_language(self, index: int) -> None:
        self._update_settings(language=index)
        self._current_language = index
        self.languageChanged.emit()

    @Slot(result=int)
    def get_language(self) -> int:
        idx = self._load_settings().get("language", 0)
        if 0 <= idx < len(self._language_files):
            return idx
        return 0

    @Slot(result=list)
    def get_languages(self) -> list[str]:
        names: list[str] = []
        for filename in self._language_files:
            data = self._read_json(
                self._languages_path / filename, f"language '{filename}'"
            )
            names.append(data.get("language", filename) if data else filename)
        return names

    @Slot(result=dict)
    def get_language_data(self) -> dict:
        idx = self.get_language()
        if 0 <= idx < len(self._language_files):
            data = self._read_json(
                self._languages_path / self._language_files[idx], "language data"
            )
            if data is not None:
                return data
        return {}

    @Slot(result=dict)
    def get_shortcuts(self) -> dict:
        data = self._load_settings().get("shortcuts", {})
        return data if isinstance(data, dict) else {}

    @Slot(dict)
    def save_shortcuts(self, shortcuts: dict) -> None:
        self._update_settings(shortcuts=dict(shortcuts))

    @Property(QObject, constant=True)
    def mainVM(self) -> MainVM:
        return self._main_vm

    @Property(QObject, constant=True)
    def settingsVM(self) -> SettingsVM:
        return self._settings_vm