# R / Quarto Commands in the Claude Code Sandbox

- Plain `Rscript` hangs in the sandbox (renv's `pak` worker). Run it with `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE` and the renv library prepended to `.libPaths()` — read `.claude/rules/r-sandbox-execution.md` before the first `Rscript` call.
- `quarto render` runs the R chunks but fails at the Sass step (`unable to open database file`). Check the `.knit.md` output and ask the user to render the HTML — see `.claude/rules/quarto-render-sandbox.md`.
- Do not change `.Rprofile`, `renv/activate.R`, or `_quarto.yml` to work around either.
