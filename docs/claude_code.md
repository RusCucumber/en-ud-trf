# Claude Code in This Repository

This document describes how [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) is configured in this repository.
For installation steps, see [steps 4 and 5 of the manual setup](./manual_setup_flow.md#4-install-claude-code-plugins).

- [Configuration Files](#configuration-files)
- [Plugins](#plugins)
- [Rules and `CLAUDE.md`](#rules-and-claudemd)
- [Skills](#skills)
- [Sandbox](#sandbox)
- [Codex (Second-Opinion Reviews)](#codex-second-opinion-reviews)
- [Obsidian](#obsidian)
- [Token Saving](#token-saving)

## Configuration Files

| Path | Role | Committed |
|------|------|-----------|
| `.claude/settings.json` | Enabled plugins, permissions, sandbox, `env` for HTTPS git | ✅ |
| `.claude/settings.local.json` | Personal overrides | ❌ (Claude Code adds it to your global git ignore) |
| `.claude/rules/*.md` | Project rules (see [Rules](#rules-and-claudemd)) | ✅ |
| `.claude/skills/*/SKILL.md` | Agent Skills (see [Skills](#skills)) | ✅ |
| `.claude/CLAUDE.md` | Managed by oh-my-claudecode; rewritten by `omc-setup` | ✅ |
| `CLAUDE.md` (repository root) | Your project-specific instructions | per project |

## Plugins

`.claude/settings.json` enables the following plugins. A plugin listed only in a project's settings is **not downloaded automatically** — install each one as described in [the manual setup](./manual_setup_flow.md#4-install-claude-code-plugins).

| Plugin | Marketplace | Purpose |
|--------|-------------|---------|
| [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) | `omc` | Multi-agent orchestration, planning / review workflows, `/oh-my-claudecode:ask codex` |
| [superpowers](https://github.com/obra/superpowers) | `anthropic-plugin-directory` (built in) | Skills for brainstorming, TDD, systematic debugging, and code review |
| [genshijin](https://github.com/InterfaceX-co-jp/genshijin) | `genshijin` | Compressed Japanese replies to reduce token usage (`/genshijin` to switch levels) |
| [claude-mem](https://github.com/thedotmack/claude-mem) | `thedotmack` | Persistent memory across sessions (see [Token Saving](#token-saving)) |

> [!WARNING]
> `claude-mem` requires [Bun](https://bun.sh/): its worker daemon uses `bun:sqlite`, and its dependencies are installed with Bun. Without Bun, the plugin loads but its worker cannot start, so nothing is saved or searchable (`~/.claude-mem/CAPTURE_BROKEN` is written, and the plugin list shows "needs bun, which is not installed"). Install Bun **before** the plugin; if you installed the plugin first, install Bun and reinstall the plugin.

## Rules and `CLAUDE.md`

`.claude/rules/` holds short project rules. A rule with `paths` frontmatter is loaded only when Claude reads or edits a matching file; a rule without it is loaded in every session.

| Rule | Loaded | Content |
|------|--------|---------|
| `obsidian.md` | always | Where Claude may read and write in the Obsidian vault |
| `python-tdd.md` | `src/`, `tests/`, `scripts/` `*.py` | Test-driven development workflow |

- Keep rules short and do not repeat what a skill already says; link to the skill instead.
- Put caveats that apply to **commands** (not files) in an always-loaded rule: a path-scoped rule is not loaded when Claude only runs a Bash command.
- Write project-specific instructions in the root `CLAUDE.md`, not in `.claude/CLAUDE.md` (oh-my-claudecode rewrites it).

## Skills

Agent Skills live in `.claude/skills/`. Each `SKILL.md` describes when it applies, so Claude picks them up automatically.

| Origin | Skills | How to update |
|--------|--------|---------------|
| [anthropics/skills](https://github.com/anthropics/skills) | `doc-coauthoring`, `docx`, `pdf`, `pptx`, `skill-creator`, `xlsx` | `gh skill update` |
| [obsidianmd/obsidian-skills](https://github.com/obsidianmd/obsidian-skills) | `obsidian-markdown` | `gh skill update` |
| oh-my-claudecode | `wiki` | updated with oh-my-claudecode |
| this repository | `git-strategy`, `notebook-workflows`, `python-environment`, `python-code-quality`, `pytest-in-uv` | edit directly |

- Upstream skills record their source in the `metadata` frontmatter (`github-repo`, `github-path`). `gh skill update` keeps extra local files such as `LICENSE.txt`.
- Repository skills each own one topic. For example, `uv sync` / `uv add` are described only in `python-environment`, and the others link to it. Keep it that way when editing.

## Sandbox

Claude Code runs Bash commands in a sandbox configured in `.claude/settings.json`.

- **Git over HTTPS**: SSH does not work inside the sandbox. Claude's git commands use HTTPS + GitHub CLI credentials via `GIT_CONFIG_*` in `env`; your own SSH setup and global git/gh config are untouched. See [step 2 of the manual setup](./manual_setup_flow.md#2-set-up-github-authentication-for-claude-code-github-cli).
- **Secrets**: `.env*`, `.envrc`, `secrets/`, and `*.pem` / `*.key` in project directories are unreadable by Claude. See [step 3 of the manual setup](./manual_setup_flow.md#3-optional-set-environment-variables).

## Codex (Second-Opinion Reviews)

[Codex](https://github.com/openai/codex) is used for second-opinion reviews via `/oh-my-claudecode:ask codex` (see the PR steps in the `git-strategy` skill).
`.claude/settings.json` allows the network hosts (`chatgpt.com`, `*.openai.com`) and the write access to `~/.codex` that Codex needs inside the sandbox. Install and log in to the Codex CLI yourself.

## Obsidian

Experiment logs and research notes in an Obsidian vault can be read through the `obsidian` MCP server (configured per user, not in this repository).
Claude writes only under `97_claude/<project>/` in the vault. See [`.claude/rules/obsidian.md`](../.claude/rules/obsidian.md).

## Token Saving

- `claude-mem` is included by default.
    - Data lives in `~/.claude-mem/` (`CLAUDE_MEM_DATA_DIR` to change). The sandbox allows writing there.
    - The ChromaDB store can grow very large (a 420 GB case is reported). Check `du -sh ~/.claude-mem` now and then.
- `genshijin` shortens Claude's Japanese replies. Turn it off with `/genshijin off` when you need full sentences.
- Add the following per project, by repository size (not included by default because their tool definitions themselves cost tokens):

    | Tool | Suitable size | Note |
    |------|---------------|------|
    | [mgrep](https://github.com/mixedbread-ai/mgrep) | small (up to a few thousand lines) | semantic search only |
    | serena-slim | medium (thousands to tens of thousands of lines) | about 11.9k tokens of tool definitions |
    | [Serena](https://github.com/oraios/serena) | large (tens of thousands of lines or more) | about 23.9k tokens of tool definitions; needs LSP setup and an index |

    Reference: [Claude Code token limit survival guide (Zenn)](https://zenn.dev/okamyuji/articles/claude-code-token-limit-survival-guide)
