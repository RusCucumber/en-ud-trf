# Research Project Template

![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)
![R](https://img.shields.io/badge/R-4.4.3-276DC3?logo=r&logoColor=white)
![uv](https://img.shields.io/badge/uv-managed-DE5FE9?logo=uv&logoColor=white)
![renv](https://img.shields.io/badge/renv-managed-276DC3)
![Quarto](https://img.shields.io/badge/Quarto-notebooks-75AADB?logo=quarto&logoColor=white)

A research project template for Python and R.

- **Python**: version & dependencies managed by [uv](https://docs.astral.sh/uv/); notebooks with [marimo](https://marimo.io/)
- **R**: version managed by [rig](https://github.com/r-lib/rig), dependencies by [renv](https://rstudio.github.io/renv/); notebooks with [Quarto](https://quarto.org/)
- **Coding agent**: preconfigured for [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) (plugins, rules, skills, sandbox)

## Contents

- [Setup](#setup)
- [Environment Variables](#environment-variables)
- [Project Board](#project-board)
- [Workflow](#workflow)
- [Coding Agent (Claude Code)](#coding-agent-claude-code)
- [Project Structure](#project-structure)

## Setup

### Automatic Setup

```bash
uvx --from https://github.com/RusCucumber/research-project-template-setup-tool.git setup-template
```

> [!NOTE]
> Requires [uv](https://docs.astral.sh/uv/getting-started/installation/) and [GitHub CLI](https://cli.github.com/).
> The R environment, Claude Code plugins, and `CLAUDE.md` still need the [manual setup](./docs/manual_setup_flow.md) (steps 2, 5, and 6).

### Manual Setup

Follow [docs/manual_setup_flow.md](./docs/manual_setup_flow.md):

1. Rename the project
2. Set up the Python & R environment (`uv sync`, `renv::restore()`)
3. Log in to GitHub CLI for Claude Code (`gh auth login`)
4. [Optional] Set environment variables (`.env`)
5. Install Claude Code plugins
6. [Optional] Write `CLAUDE.md`

> [!IMPORTANT]
> Claude Code's git commands run over **HTTPS + GitHub CLI** (SSH does not work inside its sandbox). This is set only for Claude via `env` in `.claude/settings.json` — your own SSH setup and global git/gh config stay unchanged; just run `gh auth login` once.

## Environment Variables

| File | Role | Loaded by |
|------|------|-----------|
| `.env` | Project secrets & settings (e.g., `API_KEY`, `DATABASE_URL`) | Python: `src/research_project_template/config.py` / R: `dotenv` package |
| `.envrc` | Shell environment for the project directory (e.g., load `.env`, activate `.venv`) | [direnv](https://direnv.net/) |

Both files are **git-ignored** and **unreadable by Claude Code** (`.claude/settings.json`).
Keep values in `.env` and let `.envrc` just load it, so that Python/R and the shell share one source:

```bash
# .envrc
dotenv_if_exists .env
export VIRTUAL_ENV="$PWD/.venv"
PATH_add .venv/bin
```

Set up direnv once:

```bash
brew install direnv                                  # or see https://direnv.net/docs/installation.html
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc         # use your shell's hook
direnv allow                                         # run again after every .envrc change
```

- **Zed**: `.zed/settings.json` sets `"load_direnv": "direct"`, so language servers (ty, ruff, R), tasks and the terminal get the `.envrc` variables. Reopen the project after `direnv allow`.

> [!WARNING]
> Variables exported by direnv are visible to commands Claude Code runs (if launched from that shell), even though it cannot read the files. Do not export secrets you do not want an agent to use.

## Project Board

Issues and pull requests are automatically added to the [Task Manager project board](https://github.com/users/RusCucumber/projects/1) by `.github/workflows/add-to-task-manager.yml`.

1. **Add a project tag**: add an option for this project to the board's single-select "Project" field (e.g., Replication study of Sato & McDonough, 2019 → `Repl S&M`).
2. **Update the workflow**: set `field-value` for "Category" and "Project" in `add-to-task-manager.yml`:

```yml
- uses: nipe0324/update-project-v2-item-field@v2.0.2
  with:
    project-url: https://github.com/users/RusCucumber/projects/1
    github-token: ${{ secrets.PROJECT_CONTROL_TOKEN }}
    field-name: "Category"
    field-value: "Research" # Choose [Research, University, Private, Miscellaneous Work]

- uses: nipe0324/update-project-v2-item-field@v2.0.2
  with:
    project-url: https://github.com/users/RusCucumber/projects/1
    github-token: ${{ secrets.PROJECT_CONTROL_TOKEN }}
    field-name: "Project"
    field-value: "NaN" # Use the project tag you created in step 1 (e.g., Repl S&M, New Study, etc.)
```

## Workflow

This repository follows **GitHub Flow**: branch off `main`, open a pull request, and merge back after review. `.github/ruleset-main_push_block.json` defines a ruleset for the default branch that requires pull requests and blocks force pushes and deletion.

1. Create an issue from a template in `.github/ISSUE_TEMPLATE/` (Engineering / Analysis / General Task).
2. Create a branch named `<prefix>/<descriptive-name>-#<issue-number>` (e.g., `feat/pause-detector-#12`).
3. Commit with a tag: `[add]`, `[upd]`, or `[fix]` (e.g., `[add] pause detector module`).
4. Open a pull request to `main`.

| Prefix | File types | Description | Issue template |
|--------|------------|-------------|----------------|
| `feat/` | `.py` (package) | Common functions, class design | Engineering Task |
| `fix/` | `.py` | Bug fixes in functions | Engineering Task |
| `test/` | `.py` | Test case additions or modifications | Engineering Task |
| `analysis/` | `.ipynb`, `.qmd` | Analysis and visualization in notebooks | Analysis Task |
| `experiment/` | `.ipynb`, `.qmd` | Experimental code in notebooks | Analysis Task |
| `data/` | `.csv`, `.rds` | Manual data corrections & cleaning | General Task |
| `doc/` | `.md` | Documentation & paper writing | General Task |
| `chore/` | any | Environment & dependency updates, other tasks | General Task |

Descriptive names should be concise, lowercase, and hyphen-separated (e.g., `feat/measure-calculator`, `fix/data-loader-bug`).
Claude Code follows the same conventions through the `git-strategy` skill.

> [!NOTE]
> The Python test workflow (`.github/workflows/python_tests.yaml`, which runs pytest in the `Dockerfile` image) is currently disabled until tests exist.

## Coding Agent (Claude Code)

This template is preconfigured for Claude Code. Details: **[docs/claude_code.md](./docs/claude_code.md)**.

- **Plugins**: [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode), [superpowers](https://github.com/obra/superpowers), [genshijin](https://github.com/InterfaceX-co-jp/genshijin), and [claude-mem](https://github.com/thedotmack/claude-mem). They are not downloaded automatically — install them with [step 5 of the manual setup](./docs/manual_setup_flow.md#5-install-claude-code-plugins) (`claude-mem` needs [Bun](https://bun.sh/)).
- **Rules** (`.claude/rules/`): short project rules; most load only when Claude touches matching files.
- **Skills** (`.claude/skills/`): Python / R environment, notebooks, git workflow, and document tools. Update the upstream ones with `gh skill update`.
- **Instructions**: write project-specific instructions in the root `CLAUDE.md`, not in `.claude/CLAUDE.md` (managed by oh-my-claudecode).
- **Extras**: second-opinion reviews with Codex (`/oh-my-claudecode:ask codex`), an Obsidian vault via MCP, and token-saving tips.

## Project Structure

```
.
├── data/
│   ├── raw/                         # Raw data files
│   ├── processed/                   # Processed data files
│   └── external/                    # External data sources
├── src/
│   └── research_project_template/   # Main Python package
│       └── config.py                # Paths and .env loading
├── tests/                           # pytest test cases
├── notebooks/
│   ├── python/                      # marimo notebooks
│   └── R/                           # Quarto notebooks
│       └── template/                # Notebook template (new_r_notebook.sh)
├── results/
│   ├── tables/                      # Generated tables
│   ├── figures/                     # Generated figures
│   └── models/                      # Trained models
├── docs/
│   ├── manual_setup_flow.md         # Manual setup steps
│   └── claude_code.md               # Claude Code configuration
│
├── .claude/
│   ├── settings.json                # Plugins, permissions, sandbox
│   ├── rules/                       # Project rules for Claude
│   └── skills/                      # Agent Skills
├── .github/
│   ├── ISSUE_TEMPLATE/              # Issue templates
│   ├── workflows/                   # Project board automation, Python tests
│   ├── labels.json                  # Issue labels
│   └── ruleset-main_push_block.json # Branch ruleset for main
├── .vscode/                         # VS Code settings
├── .zed/                            # Zed settings and tasks
├── renv/                            # renv files
│
├── pyproject.toml                   # Python project configuration
├── uv.lock                          # uv lock file
├── .python-version                  # Python version
├── research-project-template.Rproj  # R project file
├── .Rprofile                        # R profile (activates renv)
├── renv.lock                        # renv lock file
├── run_radian.sh                    # Launch radian (R console)
├── _quarto.yml                      # Quarto configuration
├── Dockerfile                       # Python test image
├── CLAUDE.md                        # Project instructions for Claude (create per project)
└── README.md
```
