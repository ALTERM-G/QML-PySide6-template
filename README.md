# QML + PySide6 Template

A clean, extensible Qt Quick (QML) + PySide6 template with a small design system, theming, i18n, and a Settings panel.

## Features

- Modular design system: `LayoutMetrics`, `Typography`, `Theme`
- Multi-language support (en, fr, de, es, it)
- Theme switching + System palette fallback
- Persistent settings (scale, font, language, theme, shortcuts, corner radius, animations)
- Reusable QML components and a Settings popup

## Requirements

- Python >= 3.11
- PySide6 >= 6.10.1

## Installation

```bash
pip install -e ".[dev]"
# or
uv sync --extra dev
```

## Running

```bash
qml-app
# or
python run.py
```

## Project structure

```text
src/app_name/
  backend/        # Controller, viewmodels, language manager
  resources/      # QML singletons, assets (fonts, icons, themes, languages), runtime
  ui/             # QML components, main.qml
```

## Development

- Lint QML: `qmllint -I src/app_name/ui <files>`
- Typecheck/format (optional): `ruff check .` / `ruff format .`
- Run: `PYTHONPATH=src timeout 6 python -u run.py` (clean exit 124 expected in offscreen)

## Renaming the app

Search/replace `app_name` and update `pyproject.toml`/entry points as needed.
