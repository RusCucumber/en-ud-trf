# Manual Setup Flow

Follow these steps after cloning this repository. Steps marked **[Optional]** can be skipped.

- [1. Set Up the Python Environment](#1-set-up-the-python-environment)
- [2. Set Up GitHub Authentication for Claude Code (GitHub CLI)](#2-set-up-github-authentication-for-claude-code-github-cli)
- [3. [Optional] Set Environment Variables](#3-optional-set-environment-variables)
- [4. Install Claude Code Plugins](#4-install-claude-code-plugins)
- [5. [Optional] Set Up `CLAUDE.md`](#5-optional-set-up-claudemd)

## 1. Set Up the Python Environment

- [ ] Sync Python dependencies using uv:
    ```bash
    uv sync
    ```

> [!IMPORTANT]
> Keep Python at **3.11** (`.python-version`, `[tool.ruff] target-version`, `[tool.ty.environment] python-version`, and the `Dockerfile` base image).
> The trained model must load in V-CAT, which pins `spacy>=3.5.3,<3.6.0` and `transformers<4.31`; those versions do not support newer Python releases.
> Change the Python version only together with V-CAT's spaCy pins.

Training needs a CUDA GPU (training `roberta-base` on CPU does not finish in a practical time).

- [ ] On the training machine, check the CUDA version and pick a matching `torch` build:
    ```bash
    nvidia-smi
    ```

## 2. Set Up GitHub Authentication for Claude Code (GitHub CLI)

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

## 3. [Optional] Set Environment Variables

- [ ] Create a `.env` file in the project root to manage environment variables, e.g., a Hugging Face token for pushing the packaged model:
    ```
    HF_TOKEN=your_hugging_face_token
    ```
- Python does not load `.env` itself. Load it into the shell with direnv (see [Environment Variables](../README.md#environment-variables) in the README), then read values with `os.getenv()`.

Put key / certificate files (`*.pem`, `*.key`, service-account JSON, etc.) under `secrets/`. It is git-ignored and unreadable by Claude Code (sandboxed Bash `denyRead` + Read/Edit `permissions.deny`).

- `*.pem` / `*.key` are denied (Bash, Read, Edit) only at the project root and in `src/`, `assets/`, `corpus/`, `notebooks/`, `results/`, `docs/`, `.github/`, `config/`, `scripts/` — not in dependency dirs such as `.venv/`, so CA bundles like `certifi/cacert.pem` stay readable.
- Do not use broad globs like `**/*.pem` in either `sandbox.filesystem.denyRead` or `permissions.deny` `Read(...)`: Read deny rules are also merged into the sandbox, and `allowRead` cannot override glob denies, so this would block `.venv/.../certifi/cacert.pem` again. If you add a new top-level directory that may hold keys, add it to both lists in `.claude/settings.json`.
- `tests/` is intentionally excluded so that dummy test certificates/keys used by pytest fixtures stay readable. Never put real secrets in `tests/`.

## 4. Install Claude Code Plugins

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

## 5. [Optional] Set Up `CLAUDE.md`

- [ ] Write project-specific instructions and context in `CLAUDE.md` at the **repository root**.
    - Do not edit `.claude/CLAUDE.md`: it is managed by oh-my-claudecode and rewritten by `omc-setup`.
    - You can run `/init` in Claude Code to generate a draft, then customize it for your project.
