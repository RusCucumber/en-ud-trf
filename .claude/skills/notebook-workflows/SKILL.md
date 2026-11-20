---
name: notebook-workflows
description: "Marimo notebook workflows. Use when creating, running, or debugging Python marimo notebooks; linking notebooks to package code; managing notebook dependencies; or reproducing analysis."
---

# Notebook Workflows Skill

A skill for creating, executing, and integrating Marimo (`.py`) notebooks with the research project package and environment.

## When to Use This Skill

- Creating a new Marimo interactive notebook in `notebooks/python/`
- Running or debugging a notebook and handling environment issues
- Linking notebook code to package functions in `src/en_ud_trf/`
- Managing notebook dependencies and reproducibility
- Reproducing analysis from an existing notebook

## Key Files

| File                                      | Purpose                            |
| ----------------------------------------- | ---------------------------------- |
| `notebooks/python/`                       | Marimo (`.py`) notebooks           |
| `assets/`                                 | Raw data (git-ignored)             |
| `corpus/`                                 | Training data (git-ignored)        |
| `metrics/`                                | Evaluation scores and outputs      |
| `pyproject.toml`                          | Python dependencies                |

## Python Notebooks (Marimo)

### 1. Create a Python Notebook

```bash
uv run marimo edit notebooks/python/my_notebook.py
```

Creates an interactive notebook as a `.py` file.

### 2. Import from Package in Notebooks

Always use absolute imports from the package:

```python
# ✅ CORRECT: Import from package
from en_ud_trf import some_module

# Load data with a path anchored at the repository root
from pathlib import Path

ASSETS_DIR = Path(__file__).parents[2] / "assets"
df = pd.read_csv(ASSETS_DIR / "mydata.csv")
```

**Why:** Anchoring paths at the repository root keeps notebooks reproducible across clones and independent of the working directory.

### 3. Run a Notebook from the Command Line

```bash
uv run marimo run notebooks/python/my_notebook.py
```

### 4. Manage Notebook-Specific Dependencies

Add notebook-specific dependencies to `pyproject.toml` dev group:

```bash
uv add --dev plotly               # for interactive plots
uv add --dev scikit-learn         # for machine learning
```

All dependencies are shared by the project and notebooks (no separate `requirements.txt`).

---

## Reproducibility

### Version Requirements

- **Python**: 3.11 (pinned in `uv.lock`)

### Reproducing a Notebook on Fresh Environment

1. Clone repository
2. Sync Python: `uv sync`
3. Run notebook: `uv run marimo edit notebooks/python/notebook.py` (or `uv run marimo run ...`)

### Saving Outputs from Notebooks

Always save under `metrics/`, anchored at the repository root:

```python
from pathlib import Path

METRICS_DIR = Path(__file__).parents[2] / "metrics"

# Save figure
fig.savefig(METRICS_DIR / "my_plot.png", dpi=300)

# Save table
df.to_csv(METRICS_DIR / "summary.csv", index=False)
```

---

## Troubleshooting

### "ModuleNotFoundError" in a Notebook

**Issue:** Notebook can't import from `en_ud_trf`

**Fix:**

1. Ensure the notebook runs inside the uv-managed environment (`uv run marimo ...`)
2. Restart the Marimo session
3. Verify package is installed: `uv run python -c "import en_ud_trf"`

### Notebook Dependencies Aren't Latest

**Issue:** Installed a new package but notebook doesn't see it

**Fix:**

1. Run `uv sync` in terminal
2. Restart the Marimo session
3. Re-run notebook cells

---

## Best Practices

- ✅ Import shared code from the `en_ud_trf` package in Python notebooks
- ✅ Anchor data and output paths at the repository root (`assets/`, `corpus/`, `metrics/`)
- ✅ Read environment variables with `os.getenv()` (loaded by direnv, see README)

---

## See Also

- [python-environment skill](../python-environment/SKILL.md) — Manage Python version and dependencies
- [README](../../../README.md#environment-variables) — Environment variables (`.env` via direnv)
