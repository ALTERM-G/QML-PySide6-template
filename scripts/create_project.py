import argparse
import importlib.util
import json
import keyword
import os
import re
import select
import shutil
import subprocess
import sys
import unicodedata
from pathlib import Path

try:
    import termios
    import tty
except ImportError:
    termios = tty = None

TEMPLATE = Path(__file__).resolve().parent.parent

EXCLUDED_NAMES = {
    ".git",
    ".venv",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    "__pycache__",
    "docs",
    "scripts",
    "uv.lock",
}

FONT_PACKAGES = [
    ("JetBrains Mono", "JetBrainsMono"),
    ("Inter", "Inter"),
    ("Syne", "Syne"),
    ("Monocraft", "monocraft"),
    ("Nullify", "Nullify"),
    ("Unbounded", "Unbounded"),
    ("Bricolage Grotesque", "Bricolage_Grotesque"),
]

FONTS = [family for family, _ in FONT_PACKAGES]

ICON_EXTENSIONS = (".svg", ".png", ".ico")

COLOR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
BOLD = "\033[1m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
RESET = "\033[0m"


def paint(text: str, code: str) -> str:
    return f"{code}{text}{RESET}" if COLOR else text


BANNER_ART = r"""  ______                     __      __
 /_  __/__  ____ ___  ____  / /___ _/ /____
  / / / _ \/ __ `__ \/ __ \/ / __ `/ __/ _ \
 / / /  __/ / / / / / /_/ / / /_/ / /_/  __/
/_/  \___/_/ /_/ /_/ .___/_/\__,_/\__/\___/
                  /_/                       """


def banner() -> None:
    line = "=" * 56
    print(paint(line, CYAN))
    print(paint(BANNER_ART, CYAN))
    print(paint(line, CYAN))
    print()
    print("   QML + PySide6 - New Project Setup")
    print()
    print("Creates a fresh, configured copy of the template.")
    print("Press Ctrl+C at any time to cancel.")
    print()


def read_line(prompt: str) -> str:
    try:
        return input(prompt).strip()
    except (EOFError, KeyboardInterrupt):
        print()
        print("Setup cancelled.")
        sys.exit(1)


def ask(prompt: str, default: str | None = None) -> str:
    while True:
        suffix = f" [{default}]" if default not in (None, "") else ""
        answer = read_line(f"? {prompt}{suffix}: ")
        if answer:
            return answer
        if default is not None:
            return default
        print("  Please enter a value.")


def arrows_available() -> bool:
    return bool(termios and tty and sys.stdin.isatty() and sys.stdout.isatty())


class Keyboard:
    def __init__(self) -> None:
        self.fd = sys.stdin.fileno()
        self.saved = None

    def __enter__(self) -> "Keyboard":
        self.saved = termios.tcgetattr(self.fd)
        tty.setcbreak(self.fd)
        return self

    def __exit__(self, *exc_info) -> None:
        termios.tcsetattr(self.fd, termios.TCSADRAIN, self.saved)

    def read(self) -> str | None:
        try:
            first = os.read(self.fd, 1)
        except OSError:
            return None
        if not first:
            return None
        if first == b"\x1b":
            sequence = b""
            for _ in range(4):
                ready, _, _ = select.select([self.fd], [], [], 0.04)
                if not ready:
                    break
                sequence += os.read(self.fd, 1)
                if sequence in (b"[A", b"[B", b"[C", b"[D", b"[H", b"[F"):
                    break
            return {
                b"[A": "up",
                b"[B": "down",
                b"[C": "right",
                b"[D": "left",
                b"[H": "home",
                b"[F": "end",
            }.get(sequence, "esc")
        if first in (b"\r", b"\n"):
            return "enter"
        if first == b" ":
            return "space"
        if first == b"\x03":
            raise KeyboardInterrupt
        if first == b"\x7f":
            return "backspace"
        try:
            return first.decode("utf-8")
        except UnicodeDecodeError:
            return ""


def redraw(lines: list[str], previous: int) -> int:
    if previous:
        sys.stdout.write(f"\033[{previous}A")
    sys.stdout.write("\r\033[J")
    for line in lines:
        sys.stdout.write(line + "\n")
    sys.stdout.flush()
    return len(lines)


def cancel_setup() -> None:
    print()
    print("Setup cancelled.")
    sys.exit(1)


def choose_one(prompt: str, options: list[str], default: int = 0) -> str:
    print(f"? {prompt}")
    print(f"  {paint('up/down', CYAN)} + Enter, or type a number")
    selected = min(max(default, 0), len(options) - 1)
    drawn = 0
    try:
        with Keyboard() as keyboard:
            while True:
                lines = []
                for i, option in enumerate(options):
                    marker = paint(">", CYAN) if i == selected else " "
                    lines.append(f"  {marker} {paint(str(i + 1), BOLD)}. {option}")
                drawn = redraw(lines, drawn)
                key = keyboard.read()
                if key is None:
                    raise EOFError
                if key == "up":
                    selected = (selected - 1) % len(options)
                elif key == "down":
                    selected = (selected + 1) % len(options)
                elif key == "home":
                    selected = 0
                elif key == "end":
                    selected = len(options) - 1
                elif key == "enter":
                    print()
                    return options[selected]
                elif key == "esc":
                    raise KeyboardInterrupt
                elif key and key.isdigit():
                    index = int(key) - 1
                    if 0 <= index < len(options):
                        selected = index
    except (KeyboardInterrupt, EOFError):
        cancel_setup()
    raise AssertionError("unreachable")


def choose_many(prompt: str, options: list[str]) -> list[str]:
    print(f"? {prompt}")
    print(
        f"  {paint('up/down', CYAN)} move · "
        f"{paint('Space', CYAN)} toggle · "
        f"{paint('A', CYAN)} all/none · "
        f"{paint('Enter', CYAN)} confirm"
    )
    selected = set(range(len(options)))
    cursor = 0
    drawn = 0
    warning = ""
    try:
        with Keyboard() as keyboard:
            while True:
                lines = []
                for i, option in enumerate(options):
                    marker = paint(">", CYAN) if i == cursor else " "
                    box = paint("[x]", GREEN) if i in selected else "[ ]"
                    lines.append(f"  {marker} {box} {i + 1}. {option}")
                if warning:
                    lines.append(paint(f"  {warning}", YELLOW))
                drawn = redraw(lines, drawn)
                warning = ""
                key = keyboard.read()
                if key is None:
                    raise EOFError
                if key == "up":
                    cursor = (cursor - 1) % len(options)
                elif key == "down":
                    cursor = (cursor + 1) % len(options)
                elif key == "home":
                    cursor = 0
                elif key == "end":
                    cursor = len(options) - 1
                elif key == "space":
                    selected.symmetric_difference_update({cursor})
                elif key and key.lower() == "a":
                    selected = set() if selected else set(range(len(options)))
                elif key == "enter":
                    if not selected:
                        warning = "Select at least one option."
                        continue
                    print()
                    return [options[i] for i in sorted(selected)]
                elif key == "esc":
                    raise KeyboardInterrupt
                elif key and key.isdigit():
                    index = int(key) - 1
                    if 0 <= index < len(options):
                        selected.symmetric_difference_update({index})
    except (KeyboardInterrupt, EOFError):
        cancel_setup()
    raise AssertionError("unreachable")


def ask_choice(prompt: str, options: list[str], default: int | None = None) -> str:
    if arrows_available():
        return choose_one(prompt, options, default if default is not None else 0)
    print(f"? {prompt}")
    for i, option in enumerate(options, 1):
        tag = "  (default)" if default is not None and i - 1 == default else ""
        print(f"  {i}. {option}{tag}")
    while True:
        answer = read_line("  Choice: ").lower()
        if not answer and default is not None:
            return options[default]
        if answer.isdigit() and 1 <= int(answer) <= len(options):
            return options[int(answer) - 1]
        for option in options:
            if answer and answer == option.lower():
                return option
        print("  Please enter one of the listed numbers.")


def ask_multi(prompt: str, options: list[str]) -> list[str]:
    if arrows_available():
        return choose_many(prompt, options)
    print(f"? {prompt} (numbers/ranges like 1 3 5-7, or 'all')")
    for i, option in enumerate(options, 1):
        print(f"  {i}. {option}")
    while True:
        answer = read_line("  Selection [all]: ").lower()
        if not answer or answer in ("all", "*"):
            return list(options)
        picks: set[int] = set()
        valid = True
        for token in re.split(r"[\s,]+", answer):
            if not token:
                continue
            match = re.fullmatch(r"(\d+)(?:-(\d+))?", token)
            if not match:
                valid = False
                break
            start = int(match.group(1))
            end = int(match.group(2) or start)
            if start < 1 or end > len(options) or start > end:
                valid = False
                break
            picks.update(range(start, end + 1))
        if valid and picks:
            return [options[i - 1] for i in sorted(picks)]
        print(f"  Enter numbers 1-{len(options)}, ranges like 2-4, or 'all'.")


def ask_confirm(prompt: str, default: bool = True) -> bool:
    hint = "Y/n" if default else "y/N"
    answer = read_line(f"? {prompt} [{hint}]: ").lower()
    if not answer:
        return default
    return answer in ("y", "yes")


def slugify(name: str) -> str:
    text = unicodedata.normalize("NFKD", name)
    text = text.encode("ascii", "ignore").decode()
    text = re.sub(r"[^a-zA-Z0-9]+", "_", text.lower())
    text = re.sub(r"_+", "_", text).strip("_")
    if not text:
        return ""
    if not text[0].isalpha():
        text = f"app_{text}"
    if keyword.iskeyword(text):
        text = f"{text}_app"
    return text


def available_themes() -> list[str]:
    themes_dir = TEMPLATE / "src" / "app_name" / "resources" / "style" / "themes"
    names = sorted(p.stem for p in themes_dir.glob("*.json") if p.stem != "base")
    return names + ["System"]


def remove_block(text: str, header: str) -> str:
    lines = text.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.strip() != header:
            continue
        depth = 0
        end = None
        for j in range(i, len(lines)):
            depth += lines[j].count("{") - lines[j].count("}")
            if depth == 0:
                end = j
                break
        if end is None:
            raise RuntimeError(f"unterminated block: {header}")
        stop = end + 1
        if stop < len(lines) and not lines[stop].strip():
            stop += 1
        del lines[i:stop]
        return "".join(lines)
    raise RuntimeError(f"block not found: {header}")


def remove_lines(text: str, *needles: str) -> str:
    lines = text.splitlines(keepends=True)
    return "".join(line for line in lines if not any(n in line for n in needles))


def replace_in_file(
    path: Path, mapping: list[tuple[str, str]], required: bool = True
) -> None:
    text = path.read_text(encoding="utf-8")
    for old, new in mapping:
        if required and old not in text:
            raise RuntimeError(f"{path.name}: pattern not found: {old[:70]!r}")
        text = text.replace(old, new)
    path.write_text(text, encoding="utf-8")


def replace_required(text: str, old: str, new: str) -> str:
    if old not in text:
        raise RuntimeError(f"pattern not found: {old[:70]!r}")
    return text.replace(old, new)


def patch_settings_tests(path: Path, file_themes: list[str],
                         default_theme: str, default_font: str) -> None:
    text = path.read_text(encoding="utf-8")
    old_tuple = (
        "    for theme in (\n"
        '        "Carbon Amber",\n'
        '        "Catppuccin Mocha",\n'
        '        "Dracula",\n'
        '        "Everforest",\n'
        '        "Github Dark",\n'
        '        "Gruvbox",\n'
        '        "Monokai",\n'
        '        "Vanilla Light",\n'
        "    ):\n"
    )
    text = replace_required(text, old_tuple, f"    for theme in {file_themes!r}:\n")
    text = replace_required(text, '"Dracula"', f'"{default_theme}"')
    text = replace_required(
        text,
        'assert controller.get_font_family() == "JetBrains Mono"',
        f'assert controller.get_font_family() == "{default_font}"',
    )
    text = replace_required(
        text,
        'assert DEFAULT_THEME == "Carbon Amber"',
        f'assert DEFAULT_THEME == "{default_theme}"',
    )
    text = replace_required(
        text,
        "def test_theme_defaults_to_carbon_amber(",
        "def test_theme_defaults(",
    )
    path.write_text(text, encoding="utf-8")


def copy_template(dest: Path) -> None:
    def ignore(directory: str, names: list[str]) -> set[str]:
        skip: set[str] = set()
        for name in names:
            if name in EXCLUDED_NAMES or name.endswith(".egg-info"):
                skip.add(name)
            elif Path(directory).name == "runtime" and name.endswith(".json"):
                skip.add(name)
        return skip

    shutil.copytree(TEMPLATE, dest, ignore=ignore)


def set_language_titles(dest: Path, slug: str, display: str) -> None:
    lang_dir = dest / "src" / slug / "resources" / "assets" / "languages"
    for path in sorted(lang_dir.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        data.setdefault("titles", {})["appName"] = display
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=4) + "\n", encoding="utf-8"
        )


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=4) + "\n",
                    encoding="utf-8")


def strip_sidebar(pkg: Path) -> None:
    ui = pkg / "ui"

    main_qml = ui / "main.qml"
    text = main_qml.read_text(encoding="utf-8")
    text = remove_lines(text, "onSidebarToggleClicked")
    text = remove_block(text, "SideBar {")
    text = remove_block(text, "MouseArea {")
    main_qml.write_text(text, encoding="utf-8")

    top_bar = ui / "components" / "layout" / "TopBar.qml"
    text = top_bar.read_text(encoding="utf-8")
    text = remove_block(text, "IconButton {")
    text = remove_lines(text, "signal sidebarToggleClicked()")
    top_bar.write_text(text, encoding="utf-8")

    shortcuts = pkg / "resources" / "data" / "Shortcuts.qml"
    text = shortcuts.read_text(encoding="utf-8")
    text = remove_lines(text, "toggleSidebar", "closeSidebar")
    shortcuts.write_text(text, encoding="utf-8")

    qmldir = ui / "components" / "qmldir"
    text = qmldir.read_text(encoding="utf-8")
    text = remove_lines(text, "SideBar")
    qmldir.write_text(text, encoding="utf-8")

    layout = pkg / "resources" / "style" / "LayoutMetrics.qml"
    text = layout.read_text(encoding="utf-8")
    text = remove_lines(
        text, "sideBarWidthOverride", "sideBarWidth:", "sideBarItemHeight"
    )
    layout.write_text(text, encoding="utf-8")

    layout_dir = ui / "components" / "layout"
    for name in ("SideBar.qml", "SideBarItem.qml", "SideBarToggle.qml"):
        (layout_dir / name).unlink(missing_ok=True)


def write_readme(dest: Path, display: str, slug: str) -> None:
    content = f"""# {display}

QML + PySide6 desktop application generated from the QML-PySide6 template.

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
python run.py
# or, after install:
{slug}
```

## Project structure

```text
src/{slug}/
  backend/     # Controller, viewmodels, language manager
  resources/   # QML singletons, assets (fonts, icons, themes, languages)
  ui/          # QML components, main.qml
```

## Development

- Lint (Python): `ruff check .`
- Tests: `pytest -q`
- Lint (QML): `qmllint -I src/{slug}/ui <files>`
"""
    (dest / "README.md").write_text(content, encoding="utf-8")


def generate(answers: dict) -> Path:
    dest: Path = answers["dest"]
    slug: str = answers["slug"]
    display: str = answers["name"]

    copy_template(dest)

    pkg_src = dest / "src" / "app_name"
    if slug != "app_name":
        pkg_src.rename(dest / "src" / slug)
    pkg = dest / "src" / slug

    python_files = [
        dest / "run.py",
        dest / "pyproject.toml",
        pkg / "bootstrap.py",
        pkg / "__main__.py",
    ]
    python_files += sorted((dest / "tests").glob("*.py"))
    for path in python_files:
        replace_in_file(path, [("app_name", slug)], required=False)

    replace_in_file(
        dest / "pyproject.toml",
        [
            ('name = "qml-pyside6-template"', f'name = "{slug}"'),
            ('description = "QML + PySide6 application template with design system, '
             'theming and i18n"', f'description = "{display}"'),
            (
                f'qml-app = "{slug}.__main__:main"',
                f'{slug} = "{slug}.__main__:main"',
            ),
        ],
    )

    icon = answers["icon"]
    if icon != "keep":
        icon_path = Path(icon).expanduser()
        if not icon_path.is_absolute():
            icon_path = Path.cwd() / icon_path
        target_ext = icon_path.suffix.lower()
        target = pkg / "resources" / "assets" / "icons" / f"icon{target_ext}"
        shutil.copy2(icon_path, target)
        replace_in_file(pkg / "bootstrap.py", [("icon.svg", f"icon{target_ext}")])

    set_language_titles(dest, slug, display)

    default_theme = answers["default_theme"]
    default_font = answers["default_font"]
    file_themes = [t for t in answers["themes"] if t != "System"]

    write_json(
        pkg / "resources" / "assets" / "fonts" / "fonts.json",
        {"defaultFamily": default_font},
    )

    for family, dirname in FONT_PACKAGES:
        if family not in answers["fonts"]:
            shutil.rmtree(pkg / "resources" / "assets" / "fonts" / dirname,
                         ignore_errors=True)

    themes_dir = pkg / "resources" / "style" / "themes"
    for path in list(themes_dir.glob("*.json")):
        if path.stem != "base" and path.stem not in answers["themes"]:
            path.unlink()

    theme_mappings = [
        (
            'property string currentTheme: "Carbon Amber"',
            f'property string currentTheme: "{default_theme}"',
        ),
    ]
    if "System" not in answers["themes"]:
        theme_mappings.append(
            (
                'property var themeNames: Object.keys(themeColors)'
                '.concat(["System"])',
                "property var themeNames: Object.keys(themeColors)",
            )
        )
    replace_in_file(pkg / "resources" / "style" / "Theme.qml", theme_mappings)

    replace_in_file(
        pkg / "backend" / "controller.py",
        [
            ('DEFAULT_THEME = "Carbon Amber"', f'DEFAULT_THEME = "{default_theme}"'),
            ('"JetBrains Mono"', f'"{default_font}"'),
        ],
    )

    patch_settings_tests(dest / "tests" / "test_settings.py",
                         file_themes, default_theme, default_font)

    runtime = pkg / "resources" / "runtime"
    runtime.mkdir(parents=True, exist_ok=True)
    write_json(runtime / "CurrentTheme.json",
               {"currentTheme": default_theme})

    if not answers["sidebar"]:
        strip_sidebar(pkg)

    write_readme(dest, display, slug)
    return dest


def verify(dest: Path, slug: str) -> bool:
    print()
    print(paint("Verifying generated project", BOLD))
    ok = True
    has_qt = importlib.util.find_spec("PySide6") is not None
    has_tests = has_qt and importlib.util.find_spec("pytest") is not None
    env = dict(
        os.environ,
        PYTHONPATH=str(dest / "src"),
        QT_QPA_PLATFORM="offscreen",
    )

    qmllint = shutil.which("qmllint")
    lint_files = [
        dest / "src" / slug / "ui" / "main.qml",
        dest / "src" / slug / "ui" / "components" / "layout" / "TopBar.qml",
        dest / "src" / slug / "resources" / "data" / "Shortcuts.qml",
        dest / "src" / slug / "resources" / "style" / "LayoutMetrics.qml",
    ]
    if qmllint:
        result = subprocess.run(
            [qmllint, "-I", str(dest / "src" / slug / "ui"), *map(str, lint_files)],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            print(f"  {paint('[ OK ]', GREEN)} qmllint")
        else:
            ok = False
            print(f"  {paint('[FAIL]', RED)} qmllint")
            print(result.stdout + result.stderr)
    else:
        print(f"  {paint('[SKIP]', YELLOW)} qmllint (not installed)")

    if has_tests:
        result = subprocess.run(
            [sys.executable, "-m", "pytest", "-q"],
            cwd=dest,
            env=env,
            capture_output=True,
            text=True,
            timeout=180,
        )
        if result.returncode == 0:
            print(f"  {paint('[ OK ]', GREEN)} pytest")
        else:
            ok = False
            print(f"  {paint('[FAIL]', RED)} pytest")
            print(result.stdout + result.stderr)
    else:
        print(f"  {paint('[SKIP]', YELLOW)} pytest (PySide6/pytest not available)")

    if has_qt:
        try:
            result = subprocess.run(
                [sys.executable, "-u", "run.py"],
                cwd=dest,
                env=env,
                capture_output=True,
                text=True,
                timeout=8,
            )
            output = result.stdout + result.stderr
            boot_ok = result.returncode == 0 and "Error:" not in output
        except subprocess.TimeoutExpired:
            boot_ok = True
        if boot_ok:
            print(f"  {paint('[ OK ]', GREEN)} offscreen boot")
        else:
            ok = False
            print(f"  {paint('[FAIL]', RED)} offscreen boot")
            print(output)
    else:
        print(f"  {paint('[SKIP]', YELLOW)} offscreen boot (PySide6 not available)")

    if not has_qt:
        print()
        print("PySide6 is not installed for this interpreter.")
        print("Finish setup in the new project, then run:")
        print(f"  cd {dest} && pip install -e '.[dev]' && pytest -q")
    return ok


def init_git(dest: Path) -> None:
    if not shutil.which("git"):
        print(f"  {paint('[SKIP]', YELLOW)} git init (git not installed)")
        return
    subprocess.run(["git", "init", "-q"], cwd=dest, capture_output=True)
    subprocess.run(["git", "add", "-A"], cwd=dest, capture_output=True)
    result = subprocess.run(
        ["git", "commit", "-q", "-m", "Initial project commit"],
        cwd=dest,
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        print(f"  {paint('[ OK ]', GREEN)} git init + initial commit")
    else:
        print(f"  {paint('[SKIP]', YELLOW)} git commit (configure git identity first)")


def print_summary(answers: dict) -> None:
    print()
    print(paint("Summary", BOLD))
    all_themes = available_themes()
    themes_value = (
        "all" if sorted(answers["themes"]) == sorted(all_themes)
        else ", ".join(answers["themes"])
    )
    fonts_value = (
        "all" if sorted(answers["fonts"]) == sorted(FONTS)
        else ", ".join(answers["fonts"])
    )
    rows = [
        ("Name", answers["name"]),
        ("Package", answers["slug"]),
        ("Icon", "template icon" if answers["icon"] == "keep" else answers["icon"]),
        ("Themes", themes_value),
        ("Default theme", answers["default_theme"]),
        ("Fonts", fonts_value),
        ("Default font", answers["default_font"]),
        ("Sidebar", "yes" if answers["sidebar"] else "no"),
        ("Destination", str(answers["dest"])),
    ]
    for label, value in rows:
        print(f"  {label:<14} {value}")
    print()


def pick_default_theme(selected: list[str]) -> str:
    return "Github Dark" if "Github Dark" in selected else selected[0]


def pick_default_font(selected: list[str]) -> str:
    return "JetBrains Mono" if "JetBrains Mono" in selected else selected[0]


def collect_answers(args: argparse.Namespace) -> dict:
    themes = available_themes()
    answers: dict = {
        "name": "",
        "slug": "",
        "icon": "keep",
        "themes": list(themes),
        "default_theme": "Github Dark",
        "fonts": list(FONTS),
        "default_font": "JetBrains Mono",
        "sidebar": True,
    }

    if args.name:
        answers["name"] = args.name
        answers["slug"] = (args.slug or slugify(args.name)).lower()
        if not re.fullmatch(r"[a-z][a-z0-9_]*", answers["slug"]) or keyword.iskeyword(
            answers["slug"]
        ):
            print(
                paint(
                    f"Invalid package name '{answers['slug']}' — must be lowercase, "
                    "start with a letter, use only letters/numbers/underscores, and not be a keyword.",
                    RED,
                )
            )
            sys.exit(1)
        answers["icon"] = args.icon or "keep"
        answers["themes"] = list(dict.fromkeys(args.theme)) if args.theme else themes
        answers["default_theme"] = args.default_theme or pick_default_theme(
            answers["themes"]
        )
        answers["fonts"] = list(dict.fromkeys(args.font)) if args.font else list(FONTS)
        answers["default_font"] = args.default_font or pick_default_font(
            answers["fonts"]
        )
        answers["sidebar"] = args.sidebar != "no"
        if answers["default_theme"] not in answers["themes"]:
            print(paint(
                f"Default theme not among selected themes: "
                f"{answers['default_theme']}", RED,
            ))
            sys.exit(1)
        if answers["default_font"] not in answers["fonts"]:
            print(paint(
                f"Default font not among selected fonts: "
                f"{answers['default_font']}", RED,
            ))
            sys.exit(1)
    else:
        banner()
        answers["name"] = ask("Application name", default=args.name or "My App")
        derived = slugify(args.slug or answers["name"]).lower()
        if not derived or not re.fullmatch(r"[a-z][a-z0-9_]*", derived):
            derived = "app"
        if keyword.iskeyword(derived):
            derived = f"{derived}_app"
        print(f"  Package name: {paint(derived, BOLD)}")
        answers["slug"] = ask("Package name", default=derived).lower()
        if not re.fullmatch(r"[a-z][a-z0-9_]*", answers["slug"]) or keyword.iskeyword(
            answers["slug"]
        ):
            answers["slug"] = slugify(answers["slug"]).lower()
        while not re.fullmatch(r"[a-z][a-z0-9_]*", answers["slug"]) or keyword.iskeyword(
            answers["slug"]
        ):
            print(
                paint(
                    "  Package name must be lowercase letters, numbers, underscores, "
                    "start with a letter, and not be a Python keyword.",
                    YELLOW,
                )
            )
            suggested = slugify(answers["slug"]).lower() or derived
            if not re.fullmatch(r"[a-z][a-z0-9_]*", suggested) or keyword.iskeyword(
                suggested
            ):
                suggested = derived
            answers["slug"] = ask("Package name", default=suggested).lower()

        icon_choice = ask_choice(
            "App icon",
            ["Keep the template icon", "Use my own file (.svg, .png, .ico)"],
            default=0,
        )
        if icon_choice.startswith("Use"):
            while True:
                candidate = ask("Path to icon file")
                path = Path(candidate).expanduser()
                if path.is_file() and path.suffix.lower() in ICON_EXTENSIONS:
                    answers["icon"] = candidate
                    break
                print(paint(f"  Not a valid {ICON_EXTENSIONS} file: {candidate}", RED))
        else:
            answers["icon"] = "keep"

        answers["themes"] = ask_multi("Themes to include", themes)
        answers["default_theme"] = pick_default_theme(answers["themes"])
        if len(answers["themes"]) > 1:
            answers["default_theme"] = ask_choice(
                "Default theme",
                answers["themes"],
                default=answers["themes"].index(answers["default_theme"]),
            )

        answers["fonts"] = ask_multi("Fonts to include", FONTS)
        answers["default_font"] = pick_default_font(answers["fonts"])
        if len(answers["fonts"]) > 1:
            answers["default_font"] = ask_choice(
                "Default UI font",
                answers["fonts"],
                default=answers["fonts"].index(answers["default_font"]),
            )

        sidebar_choice = ask_choice("Include sidebar?", ["yes", "no"], default=0)
        answers["sidebar"] = sidebar_choice == "yes"

    if not re.fullmatch(r"[a-z][a-z0-9_]*", answers["slug"]) or keyword.iskeyword(
        answers["slug"]
    ):
        print(paint(f"Invalid package name: {answers['slug']}", RED))
        sys.exit(1)

    if args.dest:
        dest = Path(args.dest).expanduser().resolve()
    else:
        dest = (TEMPLATE.parent / answers["slug"]).resolve()
    answers["dest"] = dest

    print_summary(answers)

    if dest.exists():
        if args.name:
            print(paint(f"Destination already exists: {dest}", RED))
            sys.exit(1)
        print(paint(f"Destination already exists: {dest}", YELLOW))
        answers["dest"] = Path(ask("New destination path", default=f"{dest}-2")).resolve()
        print()

    proceed = args.yes if args.name else ask_confirm("Create project?", default=True)
    if not proceed:
        print("Setup cancelled.")
        sys.exit(1)
    return answers


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate a configured copy of the QML + PySide6 template."
    )
    parser.add_argument("--name", help="display name of the application")
    parser.add_argument("--slug", help="python package name (derived from name)")
    parser.add_argument("--icon", help='icon file path, or "keep" for template icon')
    parser.add_argument("--theme", action="append", choices=available_themes(),
                        metavar="THEME", help="theme to include (repeatable; default: all)")
    parser.add_argument("--font", action="append", choices=FONTS, metavar="FONT",
                        help="font to include (repeatable; default: all)")
    parser.add_argument("--default-theme", choices=available_themes(),
                        metavar="THEME", help="initial theme (must be included)")
    parser.add_argument("--default-font", choices=FONTS, metavar="FONT",
                        help="initial font (must be included)")
    parser.add_argument("--sidebar", choices=["yes", "no"], default="yes",
                        help="include the sidebar (default: yes)")
    parser.add_argument("--dest", help="destination directory (default: ../<slug>)")
    parser.add_argument("--yes", action="store_true", help="skip the confirm prompt")
    parser.add_argument("--no-verify", action="store_true",
                        help="skip tests/boot/qmllint checks")
    parser.add_argument("--git-init", action="store_true",
                        help="run git init + initial commit in the new project")
    args = parser.parse_args()

    if not (TEMPLATE / "src" / "app_name").is_dir():
        print(paint(f"Template not found at {TEMPLATE}", RED))
        return 1

    answers = collect_answers(args)
    dest = answers["dest"]
    slug = answers["slug"]

    print()
    print(paint(f"Creating project at {dest} ...", BOLD))
    generate(answers)
    print(f"  {paint('[ OK ]', GREEN)} files written")

    passed = True
    if not args.no_verify:
        passed = verify(dest, slug)

    if args.git_init:
        init_git(dest)

    rel = os.path.relpath(dest, Path.cwd())
    if rel.startswith(".."):
        rel = str(dest)
    print()
    if passed:
        print(paint("Done.", GREEN))
    else:
        print(paint("Project created, but verification reported failures.", RED))
    print()
    print("Next steps:")
    print(f"  cd {rel}")
    print('  uv sync --extra dev   (or: pip install -e ".[dev]")')
    print("  python run.py")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
