---
paths:
  - "**/*.R"
  - "**/*.qmd"
---

# Running R / Rscript in the Claude Code Sandbox

A plain `Rscript` invocation from the Claude Code sandboxed Bash tool in this repo hangs (60s+) and gets killed, on every call, even for a bare `cat("hi")`.

## Root cause

This project's `.Rprofile` forces `options(renv.config.pak.enabled = TRUE)` before `source("renv/activate.R")`. That makes renv's autoloader use `pak`, which spins up a background worker subprocess for async downloads. Bootstrapping that worker involves process-control calls (e.g. `nice()`) that the Claude Code sandbox denies with `operation not permitted`, and the handshake with the worker hangs instead of failing cleanly.

This is a sandbox-only limitation — the user's own terminal, `radian` (`./run_radian.sh`), RStudio, and CI are unaffected. Do not "fix" `.Rprofile` or `renv/activate.R` to work around this; those files are renv-managed / intentional.

`RENV_CONFIG_PAK_ENABLED=FALSE` does **not** help: `.Rprofile` sets the option unconditionally before activate.R's own config resolution runs, and renv prefers an already-set `option()` over the env var of the same name.

## Workaround

Skip the renv autoloader entirely and manually prepend the project's renv library to `.libPaths()`:

```bash
RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript -e '
.libPaths(c("renv/library/macos/R-4.4/aarch64-apple-darwin20", .libPaths()))
suppressMessages(library("tidyverse"))
# ... rest of the code to verify
'
```

If the platform subpath is unknown or may have changed, resolve it first:

```bash
find renv/library -maxdepth 3 -type d
```

## When this applies

- Any direct `Rscript -e '...'` or `Rscript path/to/script.R` call made from the Bash tool while debugging `.qmd` chunks, package code, or one-off checks in this repo.
- Not needed when the *user* runs `quarto render` or R themselves outside the sandbox — that path is unaffected and should not be changed on their behalf.
- Loading heavy packages (e.g. `tidyverse`) still takes real wall-clock time even with the autoloader skipped; prefer `run_in_background` for anything beyond a trivial check rather than assuming it will return within the default timeout.
