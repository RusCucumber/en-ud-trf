---
paths:
  - "**/*.qmd"
---

# Running `quarto render` in the Claude Code Sandbox

`quarto render notebooks/R/*.qmd` from the Claude Code sandboxed Bash tool in this repo executes
all R chunks successfully (produces a valid `.knit.md`) but then fails at the Pandoc/Sass stage with:

```
ERROR: unable to open database file

Stack trace:
    at async Object.openKv (ext:deno_kv/01_db.ts:9:15)
    at async sassCache (...)
    at async compileWithCache (...)
```

## Root cause

Quarto compiles theme SCSS through a Sass cache backed by a Deno KV database file. On macOS this
cache always lives at `~/Library/Caches/quarto/sass` (`darwinUserCacheDir("quarto")` — hardcoded per
OS, not affected by `XDG_CACHE_HOME`). That path is outside the Claude Code sandbox's writable
directory allowlist, so opening the KV file for write is denied and the render aborts after R
execution has already completed.

This is a sandbox-only limitation — the user's own terminal, RStudio, and CI are unaffected. Do not
"fix" this by modifying `_quarto.yml` theme/sass settings; that would be a real-usage config change
to work around a sandbox artifact.

## Workaround

None found that stays within the sandbox — `XDG_CACHE_HOME` and similar env vars have no effect
because the cache dir resolution ignores them on darwin, and `~/Library/Caches` is not writable in
this sandbox and not something to add to it unilaterally.

In practice: you can still verify the *content* of a re-executed notebook from inside the sandbox
(the `.knit.md` reflects correct chunk output/values even though final HTML rendering fails), but
producing the committed `.html` requires the user to run `quarto render` themselves outside the
sandbox.

## When this applies

- Any `quarto render notebooks/R/*.qmd` call made from the Bash tool in this repo.
- Not needed when the *user* runs `quarto render` themselves outside the sandbox — that path is
  unaffected and should not be changed on their behalf.
