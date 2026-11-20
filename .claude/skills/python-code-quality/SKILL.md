---
name: python-code-quality
description: 'Ruff + ty guidance: run linting, formatting, and static type checking via uv, scoped to src/, tests/, and notebooks/python/ only. Use when adding tooling, running local checks, or configuring CI.'
---

# Python Code Quality

A focused skill for running and managing Python code quality tools (Ruff for linting/formatting and [ty](https://docs.astral.sh/ty/) for static type checking) in a `uv`-managed environment. This covers when to use these tools, how to run them locally, manage dependencies, and configure them for CI.

Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill. For example, if you renamed the package to `my_research_project`, replace `{project_name}` with `my_research_project` in import statements and path references.

## When to Use This Skill

- Use when adding or updating linting/formatting or static type checks.
- Use when configuring developer workflows or CI to enforce code quality.
- Use when troubleshooting lint or type-check failures from CI or local runs.

## Key Files

- [pyproject.toml](pyproject.toml) — central place for `ruff` configuration under `[tool.ruff]`, `[tool.ruff.lint]`, and `ty` configuration under `[tool.ty.environment]`, `[tool.ty.src]` (project convention)
- [uv.lock](uv.lock) — locked dependency graph managed by `uv`
- [.python-version](.python-version) — pinned Python version used by `uv`

## Project-specific notes (extracted)

- For environment sync (`uv sync`) and adding dependencies (`uv add` / `uv add --dev`), follow the `python-environment` skill.
- Preferred code quality commands in this repo:

```bash
uv run ruff check
uv run ty check
```

## Scope

Code quality checks in this repository target three directories only:

- `src/` — the Python package source
- `tests/` — the pytest test suite
- `notebooks/python/` — Marimo (`.py`) notebooks

Do not run ruff or ty against the repo root, `.github/`, `.claude/`, or any other directory. This keeps checks fast and avoids false positives from non-source files.

`[tool.ty.src]` in `pyproject.toml` already scopes `ty check` to `src`, `tests`, and `notebooks/python` via `include`/`exclude`, so a plain `uv run ty check` from the repo root respects this scope automatically.

## Step-by-step Workflows

Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill.

### 1. Sync environment (after cloning or dependency changes)

Run `uv sync` (see the `python-environment` skill).

### 2. Local checks

```bash
uv run ruff check src/ tests/ notebooks/python/
uv run ty check
```

### 3. Autoformat / autofix

```bash
uv run ruff format src/ tests/ notebooks/python/
uv run ruff check --fix src/ tests/ notebooks/python/
```

### 4. Full check (CI)

```bash
uv sync
uv run ruff check src/ tests/ notebooks/python/
uv run ty check
```

## Configuration

- Prefer placing `ruff` configuration in `pyproject.toml` under `[tool.ruff]`, `[tool.ruff.lint]`, and `ty` configuration under `[tool.ty.environment]`, `[tool.ty.src]` for a single source of truth.
- Alternative files are supported (`.ruff.toml`, `ty.toml`) but `pyproject.toml` is recommended.
- Typical `ty` settings: `[tool.ty.environment]` (`root`, `python-version`) and `[tool.ty.src]` (`include`, `exclude`) to scope checking. Configure `ruff` rules and excludes to match project conventions.

## CI Integration

- Ensure CI runs `uv sync` to reproduce the locked environment before executing checks.
- Example CI steps:

```yaml
- run: uv sync
- run: uv run ruff check src/ tests/ notebooks/python/
- run: uv run ty check
```

Note that `{project_name}` must be replaced with your actual project package name when following instructions in this skill.

## Recommendations & Best Practices

- Keep `ruff` and `ty` as `--dev` dependencies and commit `uv.lock` for reproducible tooling versions.
- Consider adding `uv run ruff format` to pre-commit hooks or developer tooling.

## Related files

- `pyproject.toml` — add `[tool.ruff]`, `[tool.ruff.lint]`, `[tool.ty.environment]`, and `[tool.ty.src]` blocks and declare dev dependencies.

## Troubleshooting

- Missing stubs/unresolved imports in `ty`: check third-party package stub availability, or add stub packages as dev dependencies.
- False positives from `ruff`: adjust selected rules or add per-file ignores in `pyproject.toml`.

## References

- `pyproject.toml` for configuration and dev dependency management.
- [ty documentation](https://docs.astral.sh/ty/) for configuration options and rule reference.
