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
| `src/en_ud_trf/config.py`                 | Path constants to use in notebooks |
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
from en_ud_trf.config import RAW_DATA_DIR, PROCESSED_DATA_DIR

# Load data using config paths
df = pd.read_csv(RAW_DATA_DIR / "mydata.csv")
```

**Why:** Paths are canonical, environment variables loaded, reproducible across clones.

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

Always save to paths defined in `config.py`:

```python
from en_ud_trf.config import FIGURE_RESULT_DIR, TABLE_RESULT_DIR

# Save figure
fig.savefig(FIGURE_RESULT_DIR / "my_plot.png", dpi=300)

# Save table
df.to_csv(TABLE_RESULT_DIR / "summary.csv", index=False)
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

- ✅ Import from `en_ud_trf.config` in Python notebooks
- ✅ Load `.env` at notebook start if using environment variables
- ✅ Save outputs to `config.py` path constants

---

## See Also

- [python-environment skill](../python-environment/SKILL.md) — Manage Python version and dependencies
- [`src/en_ud_trf/config.py`](../../../src/en_ud_trf/config.py) — Path constants and `.env` loading
