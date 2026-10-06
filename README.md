# gaisser-agents

Agent teams for Claude Code, Codex, and more. Call a team by domain: each team has its subagents and one entry skill that runs them. All teams ship in one plugin, `gaisser-agents`, written once and generated for each tool. Installing it installs every team.

![ci](https://github.com/alejogaisser/gaisser-agents/actions/workflows/ci.yml/badge.svg)

## Teams

| Team | Call it | Agents | Tools |
|---|---|---|---|
| `dev-team` | `/gaisser-agents:dev-team` (Claude Code), `$gaisser-agents:dev-team` (Codex plugin) or `$dev-team` (Codex manual install) | `dev-architect`, `dev-coder`, `dev-tester` | Claude Code, Codex |
| `content-team` | `/gaisser-agents:content-team` (Claude Code), `$gaisser-agents:content-team` (Codex plugin) or `$content-team` (Codex manual install) | `content-brand`, `content-scout`, `content-writer`, `content-designer`, `content-qa` | Claude Code, Codex |

The main conversation runs the team's skill and is the only one that talks to you. The subagents never talk to you and never delegate to each other.

Next: `finance-team`.

Authors edit tool-neutral sources (`catalog.json` and `teams/<team>/`); `scripts/build.py` validates them and generates the per-tool files under `dist/`, plus the marketplace manifests for both tools.

## Install for Claude Code

```
/plugin marketplace add alejogaisser/gaisser-agents
/plugin install gaisser-agents@gaisser-agents
```

The same works from a shell with `claude plugin marketplace add ...` and `claude plugin install ...`.

To install from a local checkout instead of GitHub, add the marketplace by relative path from the
repository root, then install as above:

```
claude plugin marketplace add ./
claude plugin install gaisser-agents@gaisser-agents
```

The path must point at the folder holding `.claude-plugin/marketplace.json`, not at `dist/`. An absolute
Windows path with backslashes is rejected; use `./` from the repository root, or forward slashes. A local
install does not auto-update: rebuild, then re-add or update the marketplace to pick up changes.

- Run `/reload-plugins` or start a new session, then check with `claude plugin details gaisser-agents`.
- Updates: auto-update is off by default for community marketplaces. Enable it under `/plugin` > Marketplaces, or run `/plugin marketplace update gaisser-agents`.
- Removal: `claude plugin uninstall gaisser-agents@gaisser-agents`.
- Team setup, in `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "gaisser-agents": { "source": { "source": "github", "repo": "alejogaisser/gaisser-agents" } }
  },
  "enabledPlugins": { "gaisser-agents@gaisser-agents": true }
}
```

## Install for Codex

Codex plugins can carry skills but not custom agents, so Codex needs two steps: the plugin for the skills, and the install script for the subagents of every team.

1. Add the marketplace and install the plugin (the `dev-team` and `content-team` skills, and the skill of every team added later):

   ```
   codex plugin marketplace add alejogaisser/gaisser-agents
   ```

   Then install `gaisser-agents` from the `gaisser-agents` marketplace in Codex's plugin browser.
2. Install the subagents. Clone the repository and run the installer with `--agents-only`:

   ```
   git clone https://github.com/alejogaisser/gaisser-agents.git
   cd gaisser-agents
   bash install.sh --target codex --plugin gaisser-agents --agents-only
   ```

   On Windows: `powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target codex -Plugin gaisser-agents -AgentsOnly`.

- Where the agents go: `~/.codex/agents/*.toml` (or `$CODEX_HOME/agents`). For a single project, add `--base <project folder>`, which installs into `.codex/agents/`.
- Use the plugin OR the installer's skill, not both: both provide the team skills under the same names. Without the plugin, drop `--agents-only` and the installer also copies each team's skill to `~/.agents/skills/<team>/`.
- The single-session fallback works with the plugin alone, without the subagents.
- Restart Codex, then use `$gaisser-agents:<team> <task>` with the plugin, or `$<team> <task>` with the manual install (for example `dev-team` or `content-team`), or ask Codex to spawn an agent such as `dev_architect` or `content_scout`.
- Updating: `git pull`, then re-run the installer with `--force`; update the plugin from Codex.

## Call a team

```
/gaisser-agents:dev-team add rate limiting to the API with checkpoints
/dev-team add rate limiting to the API with checkpoints
$gaisser-agents:dev-team add rate limiting to the API with checkpoints
$dev-team add rate limiting to the API with checkpoints
```

The same forms work for every team: replace `dev-team` with `content-team` and the task with a content brief. The first form is the full plugin-scoped name. The short `/dev-team` works while no other skill claims that name. Codex prefixes a skill that comes from a plugin, so the plugin install is `$gaisser-agents:dev-team` and the manual install, which copies a loose skill file, is `$dev-team`.

Router tip for your CLAUDE.md or AGENTS.md:

```
For non-trivial code changes, use the dev-team skill (/dev-team in Claude Code, $gaisser-agents:dev-team in Codex).
For content pieces (carousels, posts, scripts), use the content-team skill (/content-team in Claude Code, $gaisser-agents:content-team in Codex).
For work on a single role, name the scoped agent, for example gaisser-agents:dev-architect.
Small changes (typos, one-line fixes) are made directly, without delegating.
```

## Migrating from dev-team 2.0.0

`dev-team` 2.0.0 was a plugin of its own. Since 3.0.0 every team ships in the single plugin `gaisser-agents`, and the agents carry the `dev-` prefix.

- Claude Code marketplace users:
  - The marketplace carries `"renames": {"dev-pipeline": "dev-team", "dev-team": "gaisser-agents"}`.
  - On Claude Code v2.1.193 or later, run `/plugin marketplace update gaisser-agents` first, then `/plugin install gaisser-agents@gaisser-agents` once. Renames rewrites your `enabledPlugins` key to the new name.
  - On older versions, uninstall `dev-team@gaisser-agents` first, then install `gaisser-agents@gaisser-agents`.
- Codex plugin users: run `codex plugin marketplace upgrade gaisser-agents`, uninstall the `dev-team` plugin, and install `gaisser-agents`.
- Installer users:
  1. Run `git pull`.
  2. Run `install.ps1 -Target all -Plugin gaisser-agents -Force` (or the `install.sh` equivalent).
  3. Delete the stale unprefixed agent files by hand: `~/.claude/agents/{architect,coder,tester}.md` and `~/.codex/agents/{architect,coder,tester}.toml`. The installers never delete files, and the old agents stay callable until you do.

| Before | After |
|---|---|
| `/dev-team` (plugin `dev-team`) | `/gaisser-agents:dev-team` |
| `$dev-team` (plugin `dev-team`) | `$gaisser-agents:dev-team` |
| `dev-team:architect` | `gaisser-agents:dev-architect` |
| Codex agent `architect` | Codex agent `dev_architect` |

## Migrating from dev-pipeline

`dev-pipeline` became `dev-team` 2.0.0.

- Claude Code marketplace users: the rename chain `dev-pipeline` -> `dev-team` -> `gaisser-agents` is followed from the oldest name, so follow the 2.0.0 steps above.
- Codex plugin users: run `codex plugin marketplace upgrade gaisser-agents`, uninstall `dev-pipeline`, and install `gaisser-agents`.
- Installer users:
  1. Run `git pull`.
  2. Run `install.ps1 -Target codex -Plugin gaisser-agents -Force` (or the `install.sh` equivalent).
  3. Delete `~/.agents/skills/pipeline/` or `~/.claude/skills/pipeline/` by hand. The installers never delete files.

| Before | After |
|---|---|
| `/dev-pipeline:pipeline` | `/gaisser-agents:dev-team` |
| `$pipeline` | `$gaisser-agents:dev-team` |
| `dev-pipeline:<agent>` | `gaisser-agents:dev-<agent>` |

Existing plans that carry the old marker are still overwritten.

## Catalog

### dev-team

| Agent | What it does | Claude Code | Codex |
|---|---|---|---|
| `dev-architect` | Writes the plan: handoff with acceptance criteria, design, risks, steps; revises it after design failures; keeps decision records and lessons; never edits project code | opus, effort high; Read, Grep, Glob, Edit, Write, Web | effort high, workspace-write |
| `dev-coder` | Implements the plan within its files and scope; flags gaps | sonnet, effort medium; Read, Grep, Glob, Edit, Write, NotebookEdit, Shell, LSP | effort medium, workspace-write |
| `dev-tester` | Checks every acceptance criterion and extra cases, reports per criterion, classifies failures as implementation or design; does not fix production code | sonnet, effort medium; Read, Grep, Glob, Edit, Write, Shell | effort medium, workspace-write |

`Shell` is Bash plus PowerShell; `Web` is WebFetch plus WebSearch.

Skill: `/gaisser-agents:dev-team` (short form `/dev-team`) in Claude Code, and `$gaisser-agents:dev-team` in Codex with the plugin or `$dev-team` with the manual install. One plugin carries every team, so installing it installs all of them.

How the dev team works:

Flow: `dev-architect -> review gate -> coder -> tester -> (at most 2 fix cycles) -> record -> final report`.

- Four modes, recognized in any language: single stage ("architect only"), full flow (default), checkpoints ("with checkpoints" or "step by step"), and direct (typos and one-line fixes, no delegation).
- Handoff: every plan starts with a handoff with the fields Goal, Context, Constraints, Files to touch, Out of scope, and Acceptance criteria. The coder receives the same handoff.
- Acceptance criteria are pass or fail checks written before any code exists. The tester checks each one, tests extra cases, and reports per criterion (`pass`, `fail`, or `not tested`).
- Failure routing: `implementation` failures go to the coder, and `design` failures go to the architect, who revises the plan in place. There are at most 2 fix cycles in total, then the team asks you.
- Project memory: `docs/decisions/` (one short record per decision) and `docs/lessons-learned.md`. The architect reads them before planning and records new entries after a run. Rename them or turn them off in your CLAUDE.md or AGENTS.md; an existing `docs/adr/` folder is reused.
- Plan markers: the plan file starts with `<!-- dev-team plan -->`; the older `<!-- dev-pipeline plan -->` marker is still recognized. The architect never overwrites a file that lacks both and writes `docs/plan-<task-slug>.md` instead.
- The review gate stops for your approval when the plan touches more than 3 files or changes the architecture, and again when a plan is revised.
- It always ends with a five-section report: request and status, changes, flow, tests, review.
- Single-session fallback: if subagents are disabled or not installed, the skill runs the same stages in the main conversation. You lose separate contexts, per-role model and effort, and per-role tool restrictions.
- On Codex, tool lists become a per-agent sandbox, the model is inherited from the session, and the agents are installed by script.

### content-team

| Agent | What it does | Claude Code | Codex |
|---|---|---|---|
| `content-brand` | Builds or refreshes the profile and visual system from sources you supply and marks unsourced values for confirmation | opus, effort high; Read, Grep, Glob, Write, Web | effort high, workspace-write |
| `content-scout` | Gathers dated public evidence, picks an angle and hooks, states a timing hypothesis; keeps broad evidence apart from your own results | sonnet, effort high; Read, Grep, Glob, Write, Web | effort high, workspace-write |
| `content-writer` | Writes every string of the piece in your voice, plus alt text | opus, effort high; Read, Grep, Glob, Write | effort high, workspace-write |
| `content-designer` | Writes a render-path-agnostic composition spec and renders the local path from code | sonnet, effort high; Read, Grep, Glob, Edit, Write, Shell | effort high, workspace-write |
| `content-qa` | Records one verdict per check with page or frame evidence; does not fix content | sonnet, effort high; Read, Grep, Glob, Write, Shell | effort high, workspace-write |

Skill: `/gaisser-agents:content-team` (short form `/content-team`) in Claude Code, and `$gaisser-agents:content-team` in Codex with the plugin or `$content-team` with the manual install. The team ships no personal data: your brand facts live in `team-context/content-team/` in your own project (templates ship under the skill's `assets/`), the render path is chosen per format, and the team produces drafts only until you approve an outward action.

## Manual install details

`install.sh` (macOS, Linux, Git Bash) and `install.ps1` (Windows PowerShell 5.1 and PowerShell 7) copy files without a plugin manager.

| install.sh | install.ps1 | Meaning |
|---|---|---|
| `-l`, `--list` | `-List` | List plugins for the target and exit |
| `-t`, `--target` | `-Target` | `claude` (default), `codex`, or `all` |
| `-p`, `--plugin` | `-Plugin` | Plugin name, `gaisser-agents` (repeatable or comma-separated) |
| `-a`, `--all` | `-All` | Every plugin (the whole catalog) |
| `-b`, `--base` | `-Base` | Home-like root (default: your home folder) |
| `-A`, `--agents-only` | `-AgentsOnly` | Codex: agents only, no skill (for plugin users) |
| `-f`, `--force` | `-Force` | Overwrite differing files after moving them to a backup |
| `-n`, `--dry-run` | `-DryRun` | Show what would happen |

- Existing files are skipped unless you pass force. With force, the old copy moves to `agent-catalog-backups/<timestamp>/` under `.claude/` or the Codex home.
- Claude manual installs are not namespaced: use `dev-architect`, not `gaisser-agents:dev-architect`; the skills are `/dev-team` and `/content-team`.
- To remove: delete the installed files listed by `--list`.

## Customize, and name collisions

- Plugin agents are scoped, for example `gaisser-agents:dev-architect`. The skill always uses the scoped names.
- Your own `~/.claude/agents/dev-architect.md` (and so on) wins for the bare name, because user-level agents beat plugin agents. The skill uses the scoped names, so both can coexist. Name the scoped agent when you call one role directly.
- Agent and skill names are unique across teams, and every team has a required unique agent prefix (`dev-` and `content-` today).
- Copy an agent to `~/.claude/agents/` or `~/.codex/agents/` and edit it. The installers keep your files unless you pass force.

## Security and permissions

- Claude Code: every agent has an explicit tool allowlist. Plugin agents cannot set permission modes, hooks, or MCP servers.
- Agents marked as using the session's tools get every tool of the session, including MCP tools, except launching other agents.
- Codex: each agent has a `sandbox_mode` (`read-only` or `workspace-write`) and your approval settings apply. Subagents inherit the session's sandbox.

## Troubleshooting

- Agents missing: reload plugins or restart the tool. Check `claude plugin list`, and for Codex the `~/.codex/agents` and plugin folders.
- Codex needs `[agents] enabled = true` (the default). Every team's agents follow the same rule. To change a role's reasoning effort, for example the architect's, edit `effort` in `teams/dev-team/agents/dev-architect/agent.json`, rebuild, or set `agents.default_subagent_reasoning_effort`.
- Windows: Claude's Bash tool needs Git for Windows; otherwise the agents use PowerShell.

## Roadmap

- More `content-team` formats, added only when a brief needs them.
- `finance-team` later.
- A knowledge team that connects to the project memory, later.
- More tools as adapters: Antigravity, GitHub Copilot, Cursor, Gemini CLI, OpenCode.

Suggestions welcome as issues.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Building needs Python 3.11 or later.

## License and name

Apache-2.0 (see `LICENSE` and `NOTICE`). If you redistribute this project or a modified version, keep the `NOTICE` attribution.

The license grants no rights to the project name or the author's name (Apache-2.0 section 6): published forks should use a different name.
