---
name: git-strategy
description: "Git workflow guidance for this repository. Use when adding features, fixing bugs, enhancing analyses, creating branches, writing commit messages, creating GitHub issues, or opening pull requests. Covers GitHub Flow, branch prefix selection, commit message format ([add]/[upd]/[fix] tags), GitHub issue creation with .github/ISSUE_TEMPLATE templates, and end-to-end PR workflow from branch creation through merge."
---

# Git Strategy Skill

A skill for following the git conventions of this repository when implementing any change — from creating a branch to opening a pull request.

## When to Use This Skill

- Adding a new feature, fixing a bug, or enhancing an existing Python module
- Creating or updating an analysis or experiment notebook
- Any other change that requires creating a branch and a PR
- Writing commit messages
- Opening pull requests

## End-to-End Workflow

1. Identify the correct branch **prefix** from the table below
2. Read the matching issue template file (see mapping below) and use its `body` field labels to construct the issue body
3. Create the GitHub issue with `gh issue create`, filling in each field from the template
4. Create branch: `git checkout -b <prefix>/descriptive-name-#<issue-number>`
5. Implement the change
6. Lint and test (for Python changes): `uv run ruff check . && uv run ruff format . && uv run pytest -q`
7. Commit: `git commit -m "[tag] short description"`
8. (Optional) For a non-trivial change, get a second opinion before opening the PR: `/oh-my-claudecode:ask codex`
9. Push and open a PR to `main` (HTTPS only — see [Pushing (HTTPS)](#pushing-https))

## Pushing (HTTPS)

SSH does not work inside the Claude Code sandbox (no ssh-agent socket access, and `~/.ssh/**` is unreadable). `.claude/settings.json` therefore sets `GIT_CONFIG_*` env vars for Claude's commands only: GitHub SSH URLs (`git@github.com:` / `ssh://git@github.com/`) are rewritten to HTTPS (`url.<base>.insteadOf`), and `gh auth git-credential` supplies the token. The user keeps SSH in their own terminal — **do not** change the remote URL or global git/gh config.

- Push with `git push origin <branch>` (**no `-u`**), whether `origin` is SSH or HTTPS. The sandbox cannot write `.git/config`, so `-u` makes the push succeed but then fails with `could not lock config file ... Operation not permitted` — that error does not mean the push failed. If an upstream is needed, ask the user to run `! git branch --set-upstream-to=origin/<branch>`.
- If authentication fails, check `env | grep '^GIT_CONFIG_'` (the `insteadOf` and `gh auth git-credential` entries should be there; Claude Code may append its own entries such as `safe.directory`, so the count can exceed 4. If missing, ask the user to restart Claude Code) and `gh auth status`; if not logged in, ask the user to run `gh auth login` in their own terminal.

## Branching Strategy

This repository uses **GitHub Flow** — all work branches off `main` and merges back via PR.

| Prefix        | Use case                              | Linked issue template |
| ------------- | ------------------------------------- | --------------------- |
| `feat/`       | New Python package functionality      | Engineering Task      |
| `fix/`        | Bug fixes                             | Engineering Task      |
| `test/`       | Test additions/updates                | Engineering Task      |
| `analysis/`   | Analysis notebooks (`.ipynb`, `.qmd`) | Analysis Task         |
| `experiment/` | Experimental notebooks                | Analysis Task         |
| `data/`       | Manual data corrections/cleaning      | General Task          |
| `doc/`        | Documentation changes                 | General Task          |
| `chore/`      | Tooling/dependency/environment tasks  | General Task          |

**Branch naming rule:** `<prefix>/descriptive-name-#<issue-number>`

- Lowercase, hyphen-separated words
- Always append the linked GitHub issue number at the end
- Examples: `feat/pause-detector-#12`, `analysis/filled-pause-rate-#7`, `fix/config-path-#3`

## GitHub Issue Templates

Three issue templates live in `.github/ISSUE_TEMPLATE/`. **Always create an issue before branching**, using the template that matches the planned branch prefix.

| Template         | File                   | Title prefix | Label                                         | Branch prefixes            | Workflow                                                                                                               |
| ---------------- | ---------------------- | ------------ | --------------------------------------------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Engineering Task | `engineering_task.yml` | `[Dev]`      | `Feature` / `Bug` / `Test` (pick one)         | `feat/`, `fix/`, `test/`   | branch → implement → add/update tests → ensure tests pass → PR                                                         |
| Analysis Task    | `analysis_task.yml`    | `[Analysis]` | `Analysis`                                    | `analysis/`, `experiment/` | branch → create notebook (`notebooks/python/*.ipynb` or `notebooks/R/*.qmd`) → PR → summarize results in issue comment |
| General Task     | `general_task.yml`     | `[Task]`     | `Data` / `Documentation` / `Chore` (pick one) | `data/`, `doc/`, `chore/`  | branch → implement → PR                                                                                                |

### Issue Template Usage (REQUIRED)

Before creating any issue:

1. Read the appropriate template file from `.github/ISSUE_TEMPLATE/` using the Read tool
2. Parse each `label` field under `body` in the YAML
3. Build the `gh issue create --body` content using those labels as section headers, filling in values based on context

**Branch prefix → template file mapping:**

| Branch prefix              | Template file                                 |
| -------------------------- | --------------------------------------------- |
| `feat/`, `fix/`, `test/`   | `.github/ISSUE_TEMPLATE/engineering_task.yml` |
| `analysis/`, `experiment/` | `.github/ISSUE_TEMPLATE/analysis_task.yml`    |
| `data/`, `doc/`, `chore/`  | `.github/ISSUE_TEMPLATE/general_task.yml`     |

**Example — Engineering Task** (e.g., `feat/` branch, new feature):

```bash
gh issue create \
  --title "[Dev] add pause detector module" \
  --label "Feature" \
  --body "$(cat <<'EOF'
## Task Description
Implement a pause detector module that identifies silent gaps in audio.

## Branch Type
- [x] `feat/`: New feature implementation (.py)

## Implementation Details
- Accept an audio file path and a silence threshold (dB) as inputs
- Return a list of (start_ms, end_ms) tuples for each detected pause

## Action Steps
- [ ] Create a branch named `feat/pause-detector-#<issue-number>`
- [ ] Implement the feature/bug fix/test
- [ ] Add or update tests as necessary
- [ ] Ensure all tests pass locally
- [ ] Push the branch, open a PR, and review the code changes

## Additional Notes
EOF
)"
```

**Example — Analysis Task** (`analysis/` or `experiment/` branch):

```bash
gh issue create \
  --title "[Analysis] filled pause rate by speaker" \
  --label "Analysis" \
  --body "$(cat <<'EOF'
## Objective / Hypothesis
Measure filled pause rate per speaker to detect fluency differences.

## Data Source
data/raw/interviews.csv

## Action Steps
- [ ] Create a branch named `analysis/filled-pause-rate-#<issue-number>`
- [ ] Create a Python/R notebook
- [ ] Push the branch, open a PR, and review the outcome
- [ ] Summarize the results in a comment on this Issue

## Additional Notes
EOF
)"
```

**Example — General Task** (e.g., `chore/` branch):

```bash
gh issue create \
  --title "[Task] update renv.lock for new tidyverse version" \
  --label "Chore" \
  --body "$(cat <<'EOF'
## Task Description
Upgrade tidyverse to 2.0 and update renv.lock accordingly.

## Branch Type
- [x] `chore/`: Environment setup or dependency updates

## Task Details
Run renv::update("tidyverse") and renv::snapshot() after verifying notebooks render correctly.

## Action Steps
- [ ] Create a branch named `chore/update-tidyverse-#<issue-number>`
- [ ] Implement the task as described
- [ ] Push the branch, open a PR, and review the changes

## Additional Notes
EOF
)"
```

Always derive section headers from the template's `label` values — do not hardcode them. For templates with multiple possible labels (Engineering Task: `Feature`/`Bug`/`Test`; General Task: `Data`/`Documentation`/`Chore`), pick the single label that best matches the task.

## Commit Message Format

Use short prefix tags before the description:

| Tag     | When to use                              | Example                                   |
| ------- | ---------------------------------------- | ----------------------------------------- |
| `[add]` | Adding something new                     | `[add] pause detector module`             |
| `[upd]` | Updating or enhancing existing code/docs | `[upd] revise README with setup steps`    |
| `[fix]` | Fixing a bug                             | `[fix] config path resolution on Windows` |

Format: `[tag] short description` — keep the description concise and in lowercase.

## Constraints

- Do not push directly to `main`; always use a PR
- Do not use `--no-verify` or skip CI checks; fix root causes
- Do not push over SSH, change the user's git/gh config, or try to work around the sandbox; rely on the Claude-only HTTPS setup (see [Pushing (HTTPS)](#pushing-https))
- Do not change `uv.lock` or `renv.lock` unless the dependency change is intentional
- CI workflow (`.github/workflows/python_tests.yaml`) is currently disabled — do not re-enable until tests exist
