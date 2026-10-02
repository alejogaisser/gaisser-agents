# gaisser-agents

An agent catalog for Claude Code, Codex, and more: curated subagents and skills, written once and generated for each tool.

![ci](https://github.com/alejogaisser/gaisser-agents/actions/workflows/ci.yml/badge.svg)

## What's inside

| Plugin | Contents | Claude Code | Codex |
|---|---|---|---|
| `dev-pipeline` | Agents `architect`, `coder`, `tester` and the `pipeline` skill | Plugin (marketplace) | Plugin for the skill, install script for the agents |

Authors edit tool-neutral sources (`catalog.json`, `agents/`, `skills/`); `scripts/build.py` validates them and generates the per-tool files under `dist/`, plus the marketplace manifests for both tools.

## Install for Claude Code

```
/plugin marketplace add alejogaisser/gaisser-agents
/plugin install dev-pipeline@gaisser-agents
```

The same works from a shell with `claude plugin marketplace add ...` and `claude plugin install ...`.

- Run `/reload-plugins` or start a new session, then check with `claude plugin details dev-pipeline`.
- Updates: auto-update is off by default for community marketplaces. Enable it under `/plugin` > Marketplaces, or run `/plugin marketplace update gaisser-agents`.
- Removal: `claude plugin uninstall dev-pipeline@gaisser-agents`.
- Team setup, in `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "gaisser-agents": { "source": { "source": "github", "repo": "alejogaisser/gaisser-agents" } }
  },
  "enabledPlugins": { "dev-pipeline@gaisser-agents": true }
}
```

## Install for Codex

Codex plugins can carry skills but not custom agents, so Codex needs two steps: the plugin for the skill, and the install script for the three subagents.

1. Add the marketplace and install the plugin (the `pipeline` skill):

   ```
   codex plugin marketplace add alejogaisser/gaisser-agents
   ```

   Then install `dev-pipeline` from the `gaisser-agents` marketplace in Codex's plugin browser.
2. Install the subagents. Clone the repository and run the installer with `--agents-only`:

   ```
   git clone https://github.com/alejogaisser/gaisser-agents.git
   cd gaisser-agents
   bash install.sh --target codex --plugin dev-pipeline --agents-only
   ```

   On Windows: `powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target codex -Plugin dev-pipeline -AgentsOnly`.

- Where the agents go: `~/.codex/agents/*.toml` (or `$CODEX_HOME/agents`). For a single project, add `--base <project folder>`, which installs into `.codex/agents/`.
- Use the plugin OR the installer's skill, not both: both provide a skill named `pipeline`. Without the plugin, drop `--agents-only` and the installer also copies the skill to `~/.agents/skills/pipeline/`.
- The single-session fallback works with the plugin alone, without the subagents.
- Restart Codex, then use `$pipeline <task>`, or ask Codex to spawn the `architect` agent.
- AGENTS.md tip: "For non-trivial code changes, use the $pipeline skill."
- Updating: `git pull`, then re-run the installer with `--force`; update the plugin from Codex.

## The dev pipeline

Flow: `architect -> review gate -> coder -> tester -> (max 2 fix cycles) -> final report`.

```
/dev-pipeline:pipeline add rate limiting to the API with checkpoints
$pipeline add rate limiting to the API with checkpoints
```

- Four modes: single stage ("architect only"), full pipeline (default), checkpoints ("with checkpoints" or "step by step"), and direct (typos and one-line fixes, no delegation).
- The architect saves its plan to `docs/plan.md`. The first line of that file is the marker `<!-- dev-pipeline plan -->`; the architect never overwrites a file that lacks it and writes `docs/plan-<task-slug>.md` instead.
- The pipeline stops for your approval when the plan touches more than 3 files or changes the architecture.
- It always ends with a five-section report: request and status, changes, flow, tests, review.
- Single-session fallback: if subagents are disabled or not installed, the skill runs the same three stages in the main conversation. You lose separate contexts, per-role model and effort, and per-role tool restrictions.
- On Codex, tool lists become a per-agent sandbox, the model is inherited from the session, and the agents are installed by script.
- CLAUDE.md tip: "For non-trivial code changes, use /dev-pipeline:pipeline."

## Catalog

### dev-pipeline

| Agent | What it does | Claude Code | Codex |
|---|---|---|---|
| `architect` | Reads the code and writes an implementation plan; never edits project code | opus, effort max; Read, Grep, Glob, Write, Web | effort max, workspace-write |
| `coder` | Implements the plan step by step and flags gaps instead of improvising | sonnet, effort medium; Read, Grep, Glob, Edit, Write, NotebookEdit, Shell, LSP | effort medium, workspace-write |
| `tester` | Writes and runs tests, reports what passed and failed; does not fix production code | sonnet, effort medium; Read, Grep, Glob, Edit, Write, Shell | effort medium, workspace-write |

`Shell` is Bash plus PowerShell; `Web` is WebFetch plus WebSearch.

Skill: `pipeline`, invoked as `/dev-pipeline:pipeline` in Claude Code and `$pipeline` in Codex.

## Manual install details

`install.sh` (macOS, Linux, Git Bash) and `install.ps1` (Windows PowerShell 5.1 and PowerShell 7) copy files without a plugin manager.

| install.sh | install.ps1 | Meaning |
|---|---|---|
| `-l`, `--list` | `-List` | List plugins for the target and exit |
| `-t`, `--target` | `-Target` | `claude` (default), `codex`, or `all` |
| `-p`, `--plugin` | `-Plugin` | Plugin name (repeatable or comma-separated) |
| `-a`, `--all` | `-All` | Every plugin |
| `-b`, `--base` | `-Base` | Home-like root (default: your home folder) |
| `-A`, `--agents-only` | `-AgentsOnly` | Codex: agents only, no skill (for plugin users) |
| `-f`, `--force` | `-Force` | Overwrite differing files after moving them to a backup |
| `-n`, `--dry-run` | `-DryRun` | Show what would happen |

- Existing files are skipped unless you pass force. With force, the old copy moves to `agent-catalog-backups/<timestamp>/` under `.claude/` or the Codex home.
- Claude manual installs are not namespaced: use `architect`, not `dev-pipeline:architect`, and `/pipeline` for the skill.
- To remove: delete the installed files listed by `--list`.

## Customize, and name collisions

- Copy an agent to `~/.claude/agents/` or `~/.codex/agents/` and edit it. In Claude Code, user-level agents win over plugin agents with the same name, so the pipeline skill refers to the scoped names such as `dev-pipeline:architect`.
- If you already have agents named `architect`, `coder`, or `tester`, the installers keep yours unless you pass force.

## Security and permissions

- Claude Code: every agent has an explicit tool allowlist. Plugin agents cannot set permission modes, hooks, or MCP servers.
- Codex: each agent has a `sandbox_mode` (`read-only` or `workspace-write`) and your approval settings apply. Subagents inherit the session's sandbox.

## Troubleshooting

- Agents missing: reload plugins or restart the tool. Check `claude plugin list`, and for Codex the `~/.codex/agents` and plugin folders.
- Codex needs `[agents] enabled = true` (the default). If Codex rejects `model_reasoning_effort = "max"` for the architect, change `effort` in `agents/architect/agent.json`, rebuild, or set `agents.default_subagent_reasoning_effort`.
- Windows: Claude's Bash tool needs Git for Windows; otherwise the agents use PowerShell.

## Roadmap

- More plugins, one at a time: `code-quality`, `research`, `docs-writing`, `devops-infra`, `data-analytics`, `product-design`.
- More tools as adapters: Antigravity, GitHub Copilot, Cursor, Gemini CLI, OpenCode.

Suggestions welcome as issues.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Building needs Python 3.11 or later.

## License and name

Apache-2.0 (see `LICENSE` and `NOTICE`). If you redistribute this project or a modified version, keep the `NOTICE` attribution.

The license grants no rights to the project name or the author's name (Apache-2.0 section 6): published forks should use a different name.
