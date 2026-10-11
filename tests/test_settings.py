import json

import pytest

from app_name.backend.controller import DEFAULT_THEME, Controller


@pytest.fixture
def isolated_controller(tmp_path):
    controller = Controller()
    controller._settings_path = tmp_path / "Settings.json"
    controller._theme_path = tmp_path / "CurrentTheme.json"
    controller._theme_last_modified = 0
    controller._theme_cache = DEFAULT_THEME
    return controller


def test_defaults_without_settings(isolated_controller):
    controller = isolated_controller
    assert controller.get_scale_factor() == 1.0
    assert controller.get_corner_radius() == 1.0
    assert controller.get_animations_enabled() is True
    assert controller.get_is_continuous() is True
    assert controller.get_font_family() == "JetBrains Mono"
    assert controller.get_language() == 0
    assert controller.get_shortcuts() == {}


def test_settings_round_trip(isolated_controller):
    controller = isolated_controller
    controller.save_scale_factor(2.5)
    controller.save_corner_radius(0.75)
    controller.save_animations_enabled(False)
    controller.save_is_continuous(False)
    controller.save_font_family("Fira Code")

    assert controller.get_scale_factor() == 2.5
    assert controller.get_corner_radius() == 0.75
    assert controller.get_animations_enabled() is False
    assert controller.get_is_continuous() is False
    assert controller.get_font_family() == "Fira Code"

    data = json.loads(controller._settings_path.read_text())
    assert data["scaleFactor"] == 2.5
    assert data["cornerRadius"] == 0.75
    assert data["animationsEnabled"] is False
    assert data["isContinuous"] is False
    assert data["fontFamily"] == "Fira Code"


def test_theme_defaults_to_carbon_amber(isolated_controller):
    controller = isolated_controller
    assert DEFAULT_THEME == "Carbon Amber"
    assert controller.get_current_theme() == DEFAULT_THEME

    controller.save_theme("Dracula")
    assert controller.get_current_theme() == "Dracula"
    assert json.loads(controller._theme_path.read_text())["currentTheme"] == "Dracula"


def test_all_known_themes_registered():
    controller = Controller()
    colors = controller.get_theme_colors()
    for theme in (
        "Carbon Amber",
        "Catppuccin Mocha",
        "Dracula",
        "Everforest",
        "Github Dark",
        "Gruvbox",
        "Monokai",
        "Vanilla Light",
    ):
        assert theme in colors, f"missing theme {theme}"


def test_get_languages_returns_endonyms(isolated_controller):
    controller = isolated_controller
    assert controller.get_languages() == [
        "English",
        "Français",
        "Deutsch",
        "Español",
        "Italiano",
    ]


def test_language_round_trip(isolated_controller):
    controller = isolated_controller
    controller.save_language(3)
    assert controller.get_language() == 3
    assert controller.get_language_data()["language"] == "Español"


def test_out_of_range_language_clamped(isolated_controller):
    controller = isolated_controller
    controller.save_language(99)
    assert controller.get_language() == 0