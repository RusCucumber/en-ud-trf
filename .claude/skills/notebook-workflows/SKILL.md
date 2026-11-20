---
name: notebook-workflows
description: "Marimo and Quarto notebook execution workflows. Use when creating, running, or debugging Python Marimo notebooks or R Quarto notebooks; linking notebooks to package code; managing notebook dependencies; or understanding caching and reproducibility."
---

# Notebook Workflows Skill

A skill for creating, executing, and integrating Marimo (`.py`) and Quarto R (`.qmd`) notebooks with the research project package and environment.

## When to Use This Skill

- Creating a new Marimo interactive notebook in `notebooks/python/`
- Creating a new Quarto R notebook in `notebooks/R/`
- Running or debugging a notebook and handling environment issues
- Linking notebook code to package functions in `src/research_project_template/`
- Understanding notebook caching, kernel selection, or dependency isolation
- Rendering Quarto notebooks to HTML
- Reproducing analysis from an existing notebook

## Key Files

| File                                      | Purpose                                                       |
| ----------------------------------------- | ------------------------------------------------------------- |
| `notebooks/python/`                       | Marimo (`.py`) notebooks                                      |
| `notebooks/R/`                            | Quarto R notebooks (`.qmd`)                                   |
| `notebooks/R/template/template.qmd`       | Front matter + starter chunk for new R notebooks              |
| `notebooks/R/template/new_r_notebook.sh`  | Copies the template to a timestamped `.qmd` in `notebooks/R/` |
| `_quarto.yml`                             | Global Quarto configuration inherited by all `.qmd` files     |
| `src/research_project_template/config.py` | Path constants to use in notebooks                            |
| `pyproject.toml`                          | Python dependencies                                           |
| `renv.lock`                               | R package versions (used by Quarto)                           |

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
from research_project_template.config import RAW_DATA_DIR, PROCESSED_DATA_DIR
import research_project_template.loaders as loaders

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

## R Notebooks (Quarto)

### 1. Create a Quarto R Notebook

Run the template script — it copies `notebooks/R/template/template.qmd` to a timestamped `.qmd` in `notebooks/R/`:

```bash
./notebooks/R/template/new_r_notebook.sh
```

Template contents (`notebooks/R/template/template.qmd`):

```yaml
---
title: ""
---
```

```r
library("tidyverse")
library("here")
```

Fill in `title` and continue the analysis below it. The `format` settings inherit from `_quarto.yml`; override only if needed.

### 2. Use here::here() for Paths (Never Relative Strings)

```r
# ✅ CORRECT: Use here::here()
df <- read_csv(here("data", "raw", "mydata.csv"))
results <- write_csv(df, here("results", "tables", "summary.csv"))

# ❌ WRONG: Never relative strings
df <- read_csv("../data/raw/mydata.csv")  # Breaks when working directory changes
```

### 3. Load Environment Variables in Quarto

```r
library("dotenv")

# Load .env at start of notebook
load_dot_env(here::here(".env"))

# Access environment variables
api_key <- Sys.getenv("API_KEY")
```

### 4. Render a Quarto Notebook to HTML

```bash
quarto render notebooks/R/my_analysis.qmd

# Output: notebooks/R/my_analysis.html (self-contained, cache preserved)
```

> In the Claude Code sandbox, `quarto render` runs the R chunks but fails at the Sass step (`unable to open database file`). See [`.claude/rules/quarto-render-sandbox.md`](../../rules/quarto-render-sandbox.md); the user renders the final HTML outside the sandbox. Run `Rscript` checks as in [`.claude/rules/r-sandbox-execution.md`](../../rules/r-sandbox-execution.md).

### 5. Understand Quarto Caching

Quarto caches chunk outputs by default (`execute: cache: true` in `_quarto.yml`).

- **Cache is preserved**: Notebooks render faster on re-runs
- **Invalidate cache**: Delete `notebooks/R/_freeze/` subfolder to force re-execution
- **Modify data, invalidate**: If you change raw data, delete cache and re-render

---

## Reproducibility

### Version Requirements

- **Python**: 3.11 (pinned in `uv.lock`)
- **R**: 4.4.3 (pinned in `renv.lock`)
- **Quarto**: Installed locally; verify with `quarto --version` and use the same version across environments when reproducing renders

### Reproducing a Notebook on Fresh Environment

1. Clone repository
2. Sync Python: `uv sync`
3. Sync R: `renv::restore()` (from R console or `./run_radian.sh`)
4. Verify Quarto version: `quarto --version`
5. Run notebook:
    - Marimo: `uv run marimo edit notebooks/python/notebook.py`
    - Quarto: `quarto render notebooks/R/notebook.qmd` (outside the Claude Code sandbox; see [Render a Quarto Notebook](#4-render-a-quarto-notebook-to-html))

### Saving Outputs from Notebooks

Always save to paths defined in `config.py`:

```python
# Python
from research_project_template.config import FIGURE_RESULT_DIR, TABLE_RESULT_DIR

# Save figure
fig.savefig(FIGURE_RESULT_DIR / "my_plot.png", dpi=300)

# Save table
df.to_csv(TABLE_RESULT_DIR / "summary.csv", index=False)
```

```r
# R
library("here")

# Save figure (Quarto auto-saves, but you can also save explicitly)
ggsave(here("results", "figures", "my_plot.png"), dpi = 300, width = 10, height = 6)

# Save table
write_csv(df, here("results", "tables", "summary.csv"))
```

---

## Troubleshooting

The `quarto render` steps below fail inside the Claude Code sandbox; see the note in [Render a Quarto Notebook](#4-render-a-quarto-notebook-to-html).

### "ModuleNotFoundError" in a Notebook

**Issue:** Notebook can't import from `research_project_template`

**Fix:**

1. Ensure the notebook runs inside the uv-managed environment (`uv run marimo ...`)
2. Restart the Marimo session
3. Verify package is installed: `uv run python -c "import research_project_template"`

### "Package X not found" in Quarto

**Issue:** Quarto notebook can't load an R package

**Fix:**

1. Install package in R: `renv::install("pkg_name")`
2. Snapshot: `renv::snapshot(prompt = FALSE)`
3. Re-render: `quarto render notebooks/R/notebook.qmd`

### Notebook Dependencies Aren't Latest

**Issue:** Installed a new package but notebook doesn't see it

**Fix:**

1. Run `uv sync` in terminal
2. Restart the Marimo session
3. Re-run notebook cells

### Quarto Cache Causing Old Outputs

**Issue:** Made changes to R code but output hasn't updated

**Fix:**

```bash
# Delete cache and re-render
rm -rf notebooks/R/_freeze/
quarto render notebooks/R/notebook.qmd
```

---

## Best Practices

- ✅ Use `here::here()` in R notebooks, never relative paths
- ✅ Import from `research_project_template.config` in Python notebooks
- ✅ Load `.env` at notebook start if using environment variables
- ✅ Save outputs to `config.py` path constants
- ✅ Create new R notebooks via `notebooks/R/template/new_r_notebook.sh` rather than by hand
- ✅ Render `.qmd` before committing `.html` (for team collaboration)

---

## See Also

- [python-environment skill](../python-environment/SKILL.md) — Manage Python version and dependencies
- [r-environment skill](../r-environment/SKILL.md) — Manage R version and packages
- [CLAUDE.md Architecture section](../../CLAUDE.md) — Path constants and config patterns
