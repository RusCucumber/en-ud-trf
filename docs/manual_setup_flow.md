# Manual Setup Flow

Follow these steps after creating a repository from this template. Steps marked **[Optional]** can be skipped.

- [1. Rename the Project](#1-rename-the-project)
- [2. Set Up Python & R Environment](#2-set-up-python--r-environment)
- [3. Set Up GitHub Authentication for Claude Code (GitHub CLI)](#3-set-up-github-authentication-for-claude-code-github-cli)
- [4. [Optional] Set Environment Variables](#4-optional-set-environment-variables)
- [5. Install Claude Code Plugins](#5-install-claude-code-plugins)
- [6. [Optional] Set Up `CLAUDE.md`](#6-optional-set-up-claudemd)

## 1. Rename the Project

Replace `research-project-template` / `research_project_template` with your project name.

- [ ] `pyproject.toml`
    ```toml
    [project]
    name = "research-project-template" # Replace with your project name
    version = "0.1.0"
    description = "Add your description here"

    :

    [tool.hatch.build.targets.wheel]
    packages = ["src/research_project_template"] # Adjust this to match your package structure
    ```
- [ ] Rename `src/research_project_template/` to match your package name.
- [ ] Rename `research-project-template.Rproj` to match your project name.
- [ ] Update the package imports:
    - `notebooks/python/marimo_sample.py`
    - `.claude/skills/notebook-workflows/SKILL.md`
- [ ] Update `source` in `.github/ruleset-main_push_block.json` to your repository (`<owner>/<repo>`).

> [!TIP]
> Find the remaining occurrences with:
> ```bash
> git grep -n -e research-project-template -e research_project_template -- ':!uv.lock' ':!renv.lock'
> ```

## 2. Set Up Python & R Environment

- [ ] Sync Python dependencies using uv:
    ```bash
    uv sync
    ```
- [ ] Restore R packages using renv (in R):
    ```r
    renv::restore()
    ```

**[Optional]** If you use different Python & R versions, set them using uv & rig:

- *Python version*
    - [ ] Command line:
        ```bash
        uv python pin {YOUR_PYTHON_VERSION}
        ```
    - [ ] `pyproject.toml`:
        ```toml
        [tool.ruff]
        target-version = "py311" # Update according to your Python version

        line-length = 119

        [tool.ruff.lint]
        select = ["E", "W", "F", "I", "C90"]
        ignore = ["E203"]

        [tool.ty.environment]
        python-version = "3.11" # Update according to your Python version
        ```
    - [ ] `Dockerfile`: update the base image (`FROM python:3.11-slim-trixie`).
- *R version*
    - [ ] Command line:
        ```bash
        rig add {YOUR_R_VERSION}
        rig default {YOUR_R_VERSION}
        ```
    - [ ] `run_radian.sh`: update the R framework path (`Versions/4.4-arm64`).

## 3. Set Up GitHub Authentication for Claude Code (GitHub CLI)

Claude Code's sandbox cannot reach the ssh-agent socket and denies reading `~/.ssh/**`, so git over SSH fails inside Claude Code.

Instead, `.claude/settings.json` sets `GIT_CONFIG_*` environment variables (`env`) that apply **only to commands Claude Code runs**:

- `url.https://github.com/.insteadOf` rewrites `git@github.com:` / `ssh://git@github.com/` remotes to HTTPS.
- `credential.https://github.com.helper` is reset and set to `!gh auth git-credential`, so the GitHub CLI token is used.

Your own terminal, `~/.gitconfig`, gh settings and the `origin` remote are untouched — keep using SSH as usual.

- [ ] Log in to GitHub CLI once (in your own terminal):
    ```bash
    gh auth login
    gh auth status   # should show "Logged in to github.com"
    ```

> [!NOTE]
> Requires git 2.31+ (`git --version`).

## 4. [Optional] Set Environment Variables

- [ ] Create a `.env` file in the project root to manage environment variables for both Python and R.
    ```
    DATABASE_URL=your_database_url
    API_KEY=your_api_key
    ```
- Load them in Python by importing `config.py`, and in R with the `dotenv` package:
    ```r
    library(dotenv)
    ```
- To share them with your shell and editor, see [Environment Variables](../README.md#environment-variables) in the README (direnv).

Put key / certificate files (`*.pem`, `*.key`, service-account JSON, etc.) under `secrets/`. It is git-ignored and unreadable by Claude Code (sandboxed Bash `denyRead` + Read/Edit `permissions.deny`).

- `*.pem` / `*.key` are denied (Bash, Read, Edit) only at the project root and in `src/`, `data/`, `notebooks/`, `results/`, `docs/`, `.github/`, `config/`, `scripts/` — not in dependency dirs such as `.venv/` or `renv/`, so CA bundles like `certifi/cacert.pem` stay readable.
- Do not use broad globs like `**/*.pem` in either `sandbox.filesystem.denyRead` or `permissions.deny` `Read(...)`: Read deny rules are also merged into the sandbox, and `allowRead` cannot override glob denies, so this would block `.venv/.../certifi/cacert.pem` again. If you add a new top-level directory that may hold keys, add it to both lists in `.claude/settings.json`.
- `tests/` is intentionally excluded so that dummy test certificates/keys used by pytest fixtures stay readable. Never put real secrets in `tests/`.

## 5. Install Claude Code Plugins

`.claude/settings.json` enables four plugins, but a plugin listed only in a project's settings is not downloaded automatically. See [docs/claude_code.md](./claude_code.md#plugins) for what each plugin does.

> [!WARNING]
> `claude-mem` requires [Bun](https://bun.sh/). Install Bun **before** the plugin; without it the plugin loads but nothing is saved or searchable.

- [ ] Install Bun and add the marketplaces (once per machine):
    ```bash
    brew install oven-sh/bun/bun   # or see https://bun.sh/docs/installation
    claude plugin marketplace add Yeachan-Heo/oh-my-claudecode
    claude plugin marketplace add InterfaceX-co-jp/genshijin
    claude plugin marketplace add thedotmack/claude-mem
    ```
    `superpowers` comes from the built-in `anthropic-plugin-directory` marketplace, so it needs no `marketplace add`.
- [ ] Install the plugins (once per clone):
    ```bash
    claude plugin install oh-my-claudecode@omc --scope project
    claude plugin install superpowers@anthropic-plugin-directory --scope project
    claude plugin install genshijin@genshijin --scope project
    claude plugin install claude-mem@thedotmack --scope project
    claude plugin list   # confirm all four are installed
    ```
- [ ] Set up oh-my-claudecode in a Claude Code session:
    ```
    /oh-my-claudecode:omc-setup
    ```
- claude-mem stores data in `~/.claude-mem/`; check its size now and then (see [Token Saving](./claude_code.md#token-saving)).

## 6. [Optional] Set Up `CLAUDE.md`

- [ ] Write project-specific instructions and context in `CLAUDE.md` at the **repository root**.
    - Do not edit `.claude/CLAUDE.md`: it is managed by oh-my-claudecode and rewritten by `omc-setup`.
    - You can run `/init` in Claude Code to generate a draft, then customize it for your project.
