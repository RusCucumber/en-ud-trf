---
name: python-environment
description: 'Manages the Python environment for this research project using uv. Use when asked to install or update Python dependencies, pin the Python version, add new packages, run tests, configure linting/type-checking (ruff, ty), set up environment variables via .env, or troubleshoot import errors and missing packages. Covers pyproject.toml conventions, and uv workflows.'
---

# Python Environment Skill

A skill for managing the Python environment in this research project. The project uses **[uv](https://docs.astral.sh/uv/)** for Python version management and dependency management. The project template currently pins **Python 3.11** by default; update as needed for your project. 

Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill. For example, if you renamed the package to `my_research_project`, replace `{project_name}` with `my_research_project` in import statements and path references.

## When to Use This Skill

- Installing or updating Python packages
- Pinning a different Python version
- Adding or removing dependencies in `pyproject.toml`
- Running tests with pytest
- Configuring or running linters (`ruff`) and type-checkers (`ty`)
- Setting up or loading environment variables (`.env`)
- Renaming the project package
- Troubleshooting import errors or missing packages

## Key Files

| File | Purpose |
|------|---------|
| [pyproject.toml](../../../pyproject.toml) | Package metadata, dependencies, dev deps, ruff/ty config |
| [uv.lock](../../../uv.lock) | Locked dependency graph (committed to repo) |
| [.python-version](../../../.python-version) | Pinned Python version (read by uv) |
| notebooks/python/ | Marimo notebooks using the Python environment |
| src/{project_name}/config.py | Canonical path constants and `.env` loading |
| src/{project_name}/__init__.py | Package entry point |
| [tests/](../../../tests/) | pytest test suite |

## Step-by-Step Workflows

### 1. Initial Setup / Sync Dependencies

After cloning or pulling changes, sync the Python environment:

```bash
uv sync
```

This installs all dependencies from `uv.lock` into the managed virtual environment (`.venv/`).

### 2. Run Tests

```bash
uv run pytest -q
```

For other test commands and pytest configuration, see the `pytest-in-uv` skill.

### 3. Add a New Dependency

Add a runtime dependency:

```bash
uv add <package-name>
```

Add a development-only dependency (testing / linting / type-checking tools such as `pytest`, `ruff`, `ty`; goes to `[dependency-groups] dev`):

```bash
uv add --dev <package-name>
```

Both commands update `pyproject.toml` and regenerate `uv.lock`. Commit both files.

### 4. Pin a Different Python Version

```bash
uv python pin <version>   # e.g., uv python pin 3.11
```

This updates `.python-version`. Also update the version references in `pyproject.toml`:

```toml
[project]
requires-python = ">= 3.11"   # update accordingly

[tool.ruff]
target-version = "py311"       # update accordingly

[tool.ty.environment]
python-version = "3.11"        # update accordingly
```

Then re-sync:

```bash
uv sync
```

### 5. Run Linting and Type-Checking

Follow the `python-code-quality` skill (it defines the target directories and the commands).

### 6. Set Up Environment Variables

Create a `.env` file in the repository root:

```
DATABASE_URL=your_database_url
API_KEY=your_api_key
```

Python code accesses environment variables by importing from `config.py`:

```python
from {project_name}.config import WORK_DIR, DATA_DIR, RAW_DATA_DIR
import os

api_key = os.getenv("API_KEY")
```

`config.py` automatically loads `.env` on import using `python-dotenv`. **Never commit `.env` to version control.**
Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill.

### 7. Use Path Constants from config.py

`src/{project_name}/config.py` defines standard path constants rooted at the repository root (update folder name when you rename the package):

```python
from {project_name}.config import (
    WORK_DIR,           # repo root
    DATA_DIR,           # data/
    RAW_DATA_DIR,       # data/raw/
    PROCESSED_DATA_DIR, # data/processed/
    EXTERNAL_DATA_DIR,  # data/external/
    RESULT_DIR,         # results/
    FIGURE_RESULT_DIR,  # results/figures/
    MODEL_RESULT_DIR,   # results/models/
    TABLE_RESULT_DIR,   # results/tables/
)
```

Always use these constants instead of hard-coded paths.
Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill. 

## Current Runtime Dependencies

Defined in `pyproject.toml` under `[project] dependencies`:

| Package | Purpose |
|---------|---------|
| `numpy` | Numerical computing |
| `pandas` | Data manipulation |
| `scipy` | Scientific computing |
| `matplotlib` | Plotting |
| `seaborn` | Statistical visualization |
| `python-dotenv` | `.env` loading |
| `pydantic` | Data validation and settings |
| `marimo` | Reactive Python notebooks |
| `openai` | OpenAI API client |

## Development Dependencies

Defined under `[dependency-groups] dev`:

| Package | Purpose |
|---------|---------|
| `ty` | Static type-checking |
| `ruff` | Linting and formatting |
| `pytest` | Testing framework |
| `pypdf` | PDF processing utilities for development and testing |
| `radian` | Enhanced R console (used via `run_radian.sh`) |

## Troubleshooting

### Import errors after adding a package

Run `uv sync` to ensure the lockfile and virtual environment are in sync.

### Tests fail with `ModuleNotFoundError`

Ensure the package is installed in editable mode. `uv sync` handles this automatically because `[tool.uv] package = true` is set in `pyproject.toml`.

### Wrong Python version in use

Check `.python-version` at the repo root. Run `uv python pin <version>` to reset it, then `uv sync`.

### Ruff or ty not found

Run `uv sync` to install dev dependencies, then prefix commands with `uv run` (e.g., `uv run ruff check src/`, `uv run ty check`).

### Environment variables not loading

Ensure `.env` exists at the repo root (not in a subdirectory) and that `config.py` is imported before accessing `os.getenv()`.
