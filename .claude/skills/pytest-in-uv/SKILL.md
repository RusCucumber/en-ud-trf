---
name: pytest-in-uv
description: 'Run and manage pytest in a uv-managed environment. Covers running tests, adding test deps with `uv add --dev`, and configuring pytest via `pyproject.toml`.'
---

# Pytest in a uv-managed environment

A focused skill for running and managing tests using `uv`. This covers the project-specific testing commands, how to manage test dependencies in `uv`, and recommended pytest configuration locations (e.g., `pyproject.toml`).

## When to Use This Skill

- Running the test suite locally or in CI
- Adding or updating test-only dependencies
- Adjusting pytest configuration (markers, test paths, options)
- Troubleshooting failing tests or environment mismatches

## Key Files

- [pyproject.toml](pyproject.toml) — central place for `pytest` configuration under `[tool.pytest.ini_options]` or `[tool.pytest]` (project convention)
- [uv.lock](uv.lock) — locked dependency graph managed by `uv`
- [.python-version](.python-version) — pinned Python version used by `uv`
- [tests/](tests/) — pytest test suite location

## Project-specific notes (extracted)

- For environment sync (`uv sync`) and adding dependencies (`uv add` / `uv add --dev`), follow the `python-environment` skill.
- Preferred test command in this repo:

```bash
uv run pytest -q
# or
uv run python -m pytest
```

## Step-by-step Workflows

### 1. Sync environment (after cloning or dependency changes)

Run `uv sync` (see the `python-environment` skill).

### 2. Run the full test suite (quiet)

```bash
uv run pytest -q
```

Alternative (equivalent):

```bash
uv run python -m pytest
```

Run from the repository root so tests in `tests/` are discovered.

### 3. Run a single test file or test node

```bash
uv run pytest tests/path/to/test_file.py -v              # single file
uv run pytest tests/path/to/test_file.py::test_name -q   # single test
uv run pytest -k "test_func"                             # keyword matching
```

### 4. Add a test-only dependency

Use `uv add --dev` as described in the `python-environment` skill (e.g., `uv add --dev pytest-xdist`).

### 5. Update or pin Python version if tests require it

```bash
uv python pin 3.11
uv sync
```

Also update `requires-python` in `pyproject.toml` if needed.

## Configuring pytest

Prefer placing pytest options in `pyproject.toml` so `uv`-managed workflows and editor integrations read a single config source. Example snippet to add under `pyproject.toml`:

```toml
[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q"
testpaths = ["tests"]
python_files = ["test_*.py"]

# Optional: set markers or filterwarnings
markers = ["slow: marks tests as slow"]
filterwarnings = ["ignore::DeprecationWarning"]
```

If your tooling prefers `pytest.ini` or `tox.ini`, keep a single authoritative config to avoid confusion.

## Running with parallelism (example)

To speed up test runs (if `pytest-xdist` is added via `uv add --dev`):

```bash
uv run pytest -n auto -q
```

## CI considerations

- Ensure CI uses `uv sync` to reproduce the environment from `uv.lock` before running tests.
- Commit both `pyproject.toml` and `uv.lock` after adding or updating dev deps.

## Troubleshooting

- Tests fail with `ModuleNotFoundError` after adding deps: run `uv sync` locally to ensure `.venv/` is updated and that `uv.lock` matches `pyproject.toml`.
- Wrong Python version in CI: check `.python-version` and pin the desired runtime with `uv python pin <version>` and then `uv sync`.
- Pytest options not applied: ensure configuration exists in `pyproject.toml` under `[tool.pytest.ini_options]` or a single `pytest.ini` and that there are no conflicting configs in subdirectories.

## Quick Commands Summary

- Sync deps: `uv sync`
- Run tests: `uv run pytest -q`
- Add dev dep: `uv add --dev <package>`
- Pin Python: `uv python pin <version>`

---

If you want, I can:
- add a recommended `tool.pytest.ini_options` snippet to `pyproject.toml`,
- or run `uv run pytest -q` in your environment and report results (I will need permission to run commands).