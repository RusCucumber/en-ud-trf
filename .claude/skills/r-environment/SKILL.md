---
name: r-environment
description: 'Manages the R environment for this research project using renv and rig. Use when asked to install or update R packages, pin the R version, add new packages, run R linters/formatters (lintr, styler), set environment variables, or troubleshoot package / reproducibility issues. Covers `renv`, `renv.lock`, `renv/` conventions, and `rig` workflows.'
---

# R Environment Skill

A skill for managing the R environment in this research project. The repository uses **`renv`** for per-project package management and **`rig`** (R installer) for pinning the R runtime. This skill documents common workflows and best practices for package management, linting/formatting, environment variables, and reproducibility.

Note: replace `{project_name}` with the actual package name if following examples that use package namespaces.

## When to Use This Skill

- Restoring or updating R package dependencies for the project
- Pinning or changing the R version used by the project
- Adding or removing R packages (CRAN, GitHub/remotes)
- Running linters (`lintr`) or formatters (`styler`) on R code
- Loading environment variables in R sessions and Quarto documents
- Troubleshooting reproducibility or failing R-based analyses

## Key Files

| File | Purpose |
|------|---------|
| [renv.lock](../../../renv.lock) | Locked R package versions for reproducible installs |
| [renv/activate.R](../../../renv/activate.R) | Auto-activation bootstrap for `renv` when opening the project |
| [renv/settings.json](../../../renv/settings.json) | `renv` project settings (library paths, snapshot type) |
| [run_radian.sh](../../../run_radian.sh) | Helper to launch an enhanced R console used in development |
| {project_name}.Rproj | RStudio project metadata |
| [notebooks/R/sample.qmd](../../../notebooks/R/sample.qmd) | Example Quarto notebook that uses the R environment |

## Step-by-Step Workflows

### 1. Initial Setup / Restore Dependencies

After cloning or pulling changes, restore the project's R packages exactly as recorded in `renv.lock`:

```bash
R -e "install.packages('renv'); renv::restore()"
```

This will install packages into the project library and write `renv/library/` entries. In CI, prefer a single Rscript invocation to restore.

### 2. Add a New Package

From an interactive R session or an R script:

```r
renv::install('pkgname')
renv::snapshot(prompt = FALSE)
```

Commit both the updated `renv.lock` and any changes to `renv/settings.json` if applicable.

### 3. Add a Package from GitHub / Remotes

Use `remotes::install_github()` or `devtools::install_github()` to install, then snapshot:

```r
remotes::install_github('owner/repo')
renv::snapshot(prompt = FALSE)
```

For reproducibility prefer pinning to a commit SHA and document the source in `renv.lock`.

### 4. Pin or Change the R Version (rig)

To install and pin a specific R version locally:

```bash
rig add 4.4.3
rig default 4.4.3
# Restart your shell/IDE so the new R is used
```

In CI, ensure the runner installs the same R version (use `rig` or the CI provider's R image). Commit `renv.lock` after restoring with the target R version so `renv` records the R platform.

### 5. Linting and Formatting (lintr, styler)

Use `lintr` for style/lint checks and `styler` to auto-format code.

Run linters for the package/project:

```r
lintr::lint_package()
```

Run styler to reformat the codebase:

```r
styler::style_pkg()
```

Configure lintr rules in a `.lintr` file at the repo root or via `lintr::with_defaults()` in a lint script. Typical settings include linters for spacing, naming, and avoiding global side effects.

### 6. Environment Variables in R

Use `.env` + `dotenv` for development secrets. Examples:

In the repo root create an untracked `.env` with:

```
DB_HOST=localhost
API_KEY=xxxx
```

Load variables in R sessions or Quarto documents:

```r
# using dotenv
if (requireNamespace('dotenv', quietly = TRUE)) dotenv::load_dot_env()

Sys.getenv('API_KEY')
```

Do not commit secrets. Use CI secrets or environment variables in workflows for automated runs.

## R-specific Best Practices

- Commit `renv.lock` to the repository; do not commit `renv/library/` unless you intentionally vendor packages.
- Use `renv::snapshot()` after adding/removing packages and commit the lock file.
- Prefer pinned CRAN versions or GitHub commit SHAs for non-CRAN packages.
- Use `rig` to pin the R runtime and document the version in project README/CI.
- Keep secrets out of the repo; use `.env` locally and CI secrets in workflows.
- If building an R package, follow standard package structure and run `devtools::check()` regularly.
- Use `styler` to enforce consistent formatting and `lintr` for style checks in CI.

## CI Notes

- Make the CI job restore packages with `renv::restore()` before running tests or rendering notebooks.
- Ensure the CI runner uses the same R major/minor version (use `rig` or the CI provider's R image).
- Cache the package library between CI runs if desired, but validate integrity by restoring from `renv.lock` when necessary.

## Example Commands Summary

```bash
# Restore environment
R -e "install.packages('renv'); renv::restore()"

# Add package and snapshot
R -e "install.packages('dplyr'); renv::snapshot(prompt = FALSE)"

# Install a GitHub package and snapshot
R -e "remotes::install_github('owner/repo'); renv::snapshot(prompt = FALSE)"

# Pin R with rig
rig add 4.4.3 && rig default 4.4.3

# Run linters and formatters
R -e "lintr::lint_package()"
R -e "styler::style_pkg()"
```

## Troubleshooting

- Missing package after clone: run `R -e "install.packages('renv'); renv::restore()"`.
- `renv::restore()` fails due to unavailable binary: try installing from source or switch to a supported R version via `rig`.
- Tests fail with namespace issues: ensure `renv::restore()` completed successfully and that the R session is using the project library (`renv::activate()` may help).
- Lintr complaints: configure `.lintr` to adapt rules to the project's conventions and run `styler::style_pkg()` to auto-fix format issues.
- `Rscript` hangs/times out when run from the Claude Code Bash tool: this is a sandbox-only issue with the `pak`-backed renv autoloader, not a project problem — see [r-sandbox-execution](../../rules/r-sandbox-execution.md) for the root cause and workaround.
- `quarto render` fails with `ERROR: unable to open database file` (Sass cache) from the Claude Code Bash tool: sandbox-only; R chunks still run (check the `.knit.md`), but the user must render the `.html` themselves — see [quarto-render-sandbox](../../rules/quarto-render-sandbox.md).

If you'd like, I can also scaffold a `.lintr` and `styler` config for this repository and add example CI steps that run `renv::restore()`, linting, and tests.
