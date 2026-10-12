import json
import logging

import pytest

from app_name.backend.controller import DEFAULT_THEME, Controller

LOGGER_NAME = "app_name.backend.controller"


@pytest.fixture
def isolated_controller(tmp_path):
    controller = Controller()
    controller._settings_path = tmp_path / "Settings.json"
    controller._theme_path = tmp_path / "CurrentTheme.json"
    controller._theme_last_modified = 0
    controller._theme_cache = DEFAULT_THEME
    return controller


def test_missing_settings_is_not_logged(isolated_controller, caplog):
    with caplog.at_level(logging.WARNING, logger="app_name.backend.controller"):
        assert isolated_controller.get_scale_factor() == 1.0
    assert "settings" not in caplog.text


def test_corrupt_settings_falls_back_and_warns(isolated_controller, caplog):
    isolated_controller._settings_path.write_text("{ not valid json")

    with caplog.at_level(logging.WARNING, logger="app_name.backend.controller"):
        assert isolated_controller.get_scale_factor() == 1.0

    assert "settings" in caplog.text


def test_corrupt_current_theme_falls_back(isolated_controller, caplog):
    isolated_controller._theme_path.write_text("{ not json")

    with caplog.at_level(logging.WARNING, logger="app_name.backend.controller"):
        assert isolated_controller.get_current_theme() == DEFAULT_THEME

    assert "current theme" in caplog.text


def test_write_failure_emits_storage_error(isolated_controller):
    blocker = isolated_controller._settings_path.parent / "blocker"
    blocker.write_text("not a directory")
    isolated_controller._settings_path = blocker / "Settings.json"

    errors: list[str] = []
    isolated_controller.storageError.connect(errors.append)

    isolated_controller.save_scale_factor(2.0)

    assert errors, "storageError should be emitted when a write fails"
    assert isolated_controller.get_scale_factor() == 1.0


def test_corrupt_theme_file_is_skipped(tmp_path, caplog):
    controller = Controller()
    themes = tmp_path / "themes"
    themes.mkdir()
    (themes / "base.json").write_text(json.dumps({"fonts": {}}))
    (themes / "Good.json").write_text(json.dumps({"colors": {"themeColor": "#fff"}}))
    (themes / "Bad.json").write_text("{ broken")
    controller._themes_path = themes

    with caplog.at_level(logging.WARNING, logger="app_name.backend.controller"):
        controller._load_all_themes()

    colors = controller.get_theme_colors()
    assert "Good" in colors
    assert "Bad" not in colors
    assert "Bad" in caplog.text


def test_corrupt_language_falls_back_to_filename(tmp_path):
    controller = Controller()
    languages = tmp_path / "languages"
    languages.mkdir()
    (languages / "en.json").write_text("{ broken")
    controller._languages_path = languages

    assert controller.get_languages() == [
        "en.json",
        "fr.json",
        "de.json",
        "es.json",
        "it.json",
    ]
