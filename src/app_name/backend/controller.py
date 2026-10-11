import json
import logging
from pathlib import Path

from PySide6.QtCore import Property, QIODevice, QObject, QSaveFile, Signal, Slot

from .viewmodels import MainVM, SettingsVM

logger = logging.getLogger(__name__)

DEFAULT_THEME = "Carbon Amber"


class Controller(QObject):
    languageChanged = Signal()

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

    def _load_all_themes(self) -> None:
        self._base_config: dict = {}
        self._theme_colors: dict = {}

        base_path = self._themes_path / "base.json"
        if base_path.exists():
            try:
                with open(base_path) as f:
                    self._base_config = json.load(f)
            except Exception:
                self._base_config = {}

        for theme_file in self._themes_path.glob("*.json"):
            if theme_file.stem == "base":
                continue
            try:
                with open(theme_file) as f:
                    data = json.load(f)
                if "colors" in data:
                    self._theme_colors[theme_file.stem] = data["colors"]
            except Exception:
                continue

    def _load_theme(self) -> str:
        try:
            if self._theme_path.exists():
                current_mtime = self._theme_path.stat().st_mtime
                if current_mtime > self._theme_last_modified:
                    with open(self._theme_path) as f:
                        theme_data = json.load(f)
                    self._theme_last_modified = current_mtime
                    self._theme_cache = theme_data.get("currentTheme", DEFAULT_THEME)
                return self._theme_cache
        except Exception as e:
            logger.warning("Error loading theme: %s", e)
        return self._theme_cache

    @Slot(str)
    def save_theme(self, theme_name: str) -> None:
        self._write_json(self._theme_path, {"currentTheme": theme_name})
        self._theme_cache = theme_name
        try:
            if self._theme_path.exists():
                self._theme_last_modified = self._theme_path.stat().st_mtime
        except OSError as e:
            logger.warning("Error stating theme: %s", e)

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
        try:
            if self._settings_path.exists():
                with open(self._settings_path) as f:
                    return json.load(f)
        except Exception as e:
            logger.warning("Error loading settings: %s", e)
        return {"scaleFactor": 1.0}

    @staticmethod
    def _write_json(path: Path, data: dict) -> None:
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            file = QSaveFile(str(path))
            if not file.open(QIODevice.WriteOnly | QIODevice.Text):
                raise OSError(file.errorString())
            file.write(json.dumps(data, indent=2).encode("utf-8"))
            if not file.commit():
                raise OSError(file.errorString())
        except Exception as e:
            logger.warning("Error writing %s: %s", path.name, e)

    def _save_settings(self, settings: dict) -> None:
        self._write_json(self._settings_path, settings)

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
            path = self._languages_path / filename
            try:
                with open(path) as f:
                    names.append(json.load(f).get("language", filename))
            except Exception as e:
                logger.warning("Error loading language name from %s: %s", filename, e)
                names.append(filename)
        return names

    @Slot(result=dict)
    def get_language_data(self) -> dict:
        try:
            idx = self.get_language()
            if 0 <= idx < len(self._language_files):
                path = self._languages_path / self._language_files[idx]
                if path.exists():
                    with open(path) as f:
                        return json.load(f)
        except Exception as e:
            logger.warning("Error loading language: %s", e)
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