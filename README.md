# gaisser-agents

Agent teams for Claude Code, Codex, and more. Call a team by domain: each team has its subagents and one entry skill that runs them. All teams ship in one plugin, `gaisser-agents`, written once and generated for each tool. Installing it installs every team.

![ci](https://github.com/alejogaisser/gaisser-agents/actions/workflows/ci.yml/badge.svg)

## Teams

| Team | Call it | Agents | Tools |
|---|---|---|---|
| `software-team` | `/gaisser-agents:software-team` (Claude Code), `$gaisser-agents:software-team` (Codex plugin) or `$software-team` (Codex manual install) | `software-architect`, `software-engineer`, `software-test-engineer`; on call: `software-debugger`, `software-diagrammer`, `software-docs-writer`, `software-security-reviewer`, `software-code-reviewer`, `software-performance-reviewer`, `software-devops`, `software-db-engineer` | Claude Code, Codex |
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

1. Add the marketplace and install the plugin (the `software-team` and `content-team` skills, and the skill of every team added later):

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
- Restart Codex, then use `$gaisser-agents:<team> <task>` with the plugin, or `$<team> <task>` with the manual install (for example `software-team` or `content-team`), or ask Codex to spawn an agent such as `software_architect` or `content_scout`.
- Updating: `git pull`, then re-run the installer with `--force`; update the plugin from Codex.

## Call a team

```
/gaisser-agents:software-team add rate limiting to the API with checkpoints
/software-team add rate limiting to the API with checkpoints
$gaisser-agents:software-team add rate limiting to the API with checkpoints
$software-team add rate limiting to the API with checkpoints
```

The same forms work for every team: replace `software-team` with `content-team` and the task with a content brief. The first form is the full plugin-scoped name. The short `/software-team` works while no other skill claims that name. Codex prefixes a skill that comes from a plugin, so the plugin install is `$gaisser-agents:software-team` and the manual install, which copies a loose skill file, is `$software-team`.

Router tip for your CLAUDE.md or AGENTS.md:

```
For non-trivial code changes, use the software-team skill (/software-team in Claude Code, $gaisser-agents:software-team in Codex).
For content pieces (carousels, posts, scripts), use the content-team skill (/content-team in Claude Code, $gaisser-agents:content-team in Codex).
For work on a single role, name the scoped agent, for example gaisser-agents:software-architect.
Small changes (typos, one-line fixes) are made directly, without delegating.
```

## Migrating from gaisser-agents 3.x

In 4.0.0 the dev team became the software team, and its agents were renamed.

| Before | After |
|---|---|
| `/gaisser-agents:dev-team`, `/dev-team` | `/gaisser-agents:software-team`, `/software-team` |
| `$gaisser-agents:dev-team`, `$dev-team` | `$gaisser-agents:software-team`, `$software-team` |
| `dev-architect` (Codex `dev_architect`) | `software-architect` (Codex `software_architect`) |
| `dev-coder` (Codex `dev_coder`) | `software-engineer` (Codex `software_engineer`) |
| `dev-tester` (Codex `dev_tester`) | `software-test-engineer` (Codex `software_test_engineer`) |

- Plugin users (Claude Code and Codex): update the plugin. The plugin name is unchanged, so no renames entry is needed, but skills and agents have no renames map: update anything that calls the old names, such as a router tip in your CLAUDE.md or AGENTS.md.
- Installer users: run `git pull`, re-run the installer with `-Force` (`--force`), then delete the stale files by hand: `~/.claude/agents/dev-{architect,coder,tester}.md`, `~/.codex/agents/dev-{architect,coder,tester}.toml`, and the `dev-team` skill folder in `~/.claude/skills/` or `~/.agents/skills/`. The installers never delete files.
- Plans written with the old `<!-- dev-team plan -->` marker are still recognized and overwritten.

## Migrating from dev-team 2.0.0

`dev-team` 2.0.0 was a plugin of its own. Since 3.0.0 every team ships in the single plugin `gaisser-agents`, and the agents carry a team prefix (`dev-` in 3.x, `software-` since 4.0.0).

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
| `/dev-team` (plugin `dev-team`) | `/gaisser-agents:software-team` |
| `$dev-team` (plugin `dev-team`) | `$gaisser-agents:software-team` |
| `dev-team:architect` | `gaisser-agents:software-architect` |
| Codex agent `architect` | Codex agent `software_architect` |

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
| `/dev-pipeline:pipeline` | `/gaisser-agents:software-team` |
| `$pipeline` | `$gaisser-agents:software-team` |
| `dev-pipeline:<agent>` | `gaisser-agents:software-<role>` (see the 3.x table) |

Existing plans that carry the old marker are still overwritten.

## Catalog

### software-team

| Agent | What it does | Claude Code | Codex |
|---|---|---|---|
| `software-architect` | Writes the plan: handoff with acceptance criteria, design, risks, steps; revises it after design failures; keeps decision records and lessons; never edits project code | opus, effort high; Read, Grep, Glob, Edit, Write, Web | effort high, workspace-write |
| `software-engineer` | Implements the plan within its files and scope; flags gaps | sonnet, effort medium; Read, Grep, Glob, Edit, Write, NotebookEdit, Shell, LSP | effort medium, workspace-write |
| `software-test-engineer` | Checks every acceptance criterion and extra cases, reports per criterion, classifies failures as implementation or design; does not fix production code | sonnet, effort medium; Read, Grep, Glob, Edit, Write, Shell | effort medium, workspace-write |
| `software-debugger` | Debug: reproduces a bug, isolates its root cause with evidence, leaves a failing reproduction test, and proposes a fix classified as implementation or design; never fixes production code | opus, effort high; Read, Grep, Glob, Edit, Write, Shell | effort high, workspace-write |
| `software-diagrammer` | Diagram run: draws Mermaid (and PlantUML when needed) flowchart, sequence, class, state, ER, and C4 diagrams from the code or the plan into `docs/diagrams/`, and checks each one renders with an installed CLI | sonnet, effort medium; Read, Grep, Glob, Edit, Write, Shell | effort medium, workspace-write |
| `software-docs-writer` | Diagram run: writes and updates the README, guides, reference, architecture overview, and changelog from the code and the diagrams; never edits code | sonnet, effort medium; Read, Grep, Glob, Edit, Write | effort medium, workspace-write |
| `software-security-reviewer` | Review: injection, auth, secrets, input handling, configuration, and dependencies, with installed scanners; findings by severity with a fix and a cause; never edits files | opus, effort high; Read, Grep, Glob, Shell | effort high, read-only |
| `software-code-reviewer` | Review: correctness, contracts, test gaps, clarity, and project conventions; findings by severity with a fix and a cause; never edits files | sonnet, effort high; Read, Grep, Glob, Shell | effort high, read-only |
| `software-performance-reviewer` | Review: complexity, N+1 queries, indexes, I/O, memory, caching, and bundle size, measured when possible; findings by severity with a fix and a cause; never edits files | sonnet, effort high; Read, Grep, Glob, Shell | effort high, read-only |
| `software-devops` | Specialist: CI workflows, build and release scripts, containers, environment configuration, and versioning, within a handoff; never deploys | sonnet, effort high; Read, Grep, Glob, Edit, Write, Shell, Web | effort high, workspace-write |
| `software-db-engineer` | Specialist: schemas, migrations with rollback, indexes, constraints, and queries, within a handoff; local databases only | sonnet, effort high; Read, Grep, Glob, Edit, Write, Shell | effort high, workspace-write |

`Shell` is Bash plus PowerShell; `Web` is WebFetch plus WebSearch.

Skill: `/gaisser-agents:software-team` (short form `/software-team`) in Claude Code, and `$gaisser-agents:software-team` in Codex with the plugin or `$software-team` with the manual install. One plugin carries every team, so installing it installs all of them.

How the software team works:

Core flow: `software-architect -> review gate -> software-engineer -> software-test-engineer -> (at most 2 fix cycles) -> record -> final report`.

- Groups on call: the core flow is the default, and the other agents run only when you call them. Say "debug" or "why does this fail" for the debugger, which runs before the plan, "diagrams" or "docs" for the diagram run (diagrammer, then docs writer), "review" for the three reviewers in parallel, and "devops" or "db engineer" for a specialist. Name one agent to run it alone, for example "just the security reviewer".
- Mix freely: "full flow with review", "db engineer and then review", "debug and then the full flow", or "review and diagrams". Stages always run in the order diagnose, plan, build, verify, review, diagram run, record, and stages nobody called are skipped.
- Review findings rated `critical` or `high` go through the fix loop when the same run built the change; a review on its own only reports and asks before anything is fixed.
- Modes, recognized in any language: composed run (default), checkpoints ("with checkpoints" or "step by step"), and direct (typos and one-line fixes, no delegation).
- Handoff: every plan starts with a handoff with the fields Goal, Context, Constraints, Files to touch, Out of scope, and Acceptance criteria. The engineer receives the same handoff.
- Acceptance criteria are pass or fail checks written before any code exists. The test engineer checks each one, tests extra cases, and reports per criterion (`pass`, `fail`, or `not tested`).
- Failure routing: `implementation` failures go to the engineer, and `design` failures go to the architect, who revises the plan in place. There are at most 2 fix cycles in total, then the team asks you.
- Project memory: `docs/decisions/` (one short record per decision) and `docs/lessons-learned.md`. The architect reads them before planning and records new entries after a run. Rename them or turn them off in your CLAUDE.md or AGENTS.md; an existing `docs/adr/` folder is reused.
- Plan markers: the plan file starts with `<!-- software-team plan -->`; the older `<!-- dev-team plan -->` and `<!-- dev-pipeline plan -->` markers are still recognized. The architect never overwrites a file that lacks all three and writes `docs/plan-<task-slug>.md` instead.
- The review gate stops for your approval when the plan touches more than 3 files or changes the architecture, and again when a plan is revised.
- It always ends with a five-section report: request and status, changes, flow, tests, review.
- Single-session fallback: if subagents are disabled or not installed, the skill runs the same stages in the main conversation. You lose separate contexts, per-role model and effort, and per-role tool restrictions.
- On Codex, tool lists become a per-agent sandbox, the model is inherited from the session, and the agents are installed by script.

### content-team

| Agent | What it does | Claude Code | Codex |
|---|---|---|---|
| `content-brand` | Builds or refreshes the profile and visual system from sources you supply and marks unsourced values for confirmation | opus, effort high; Read, Grep, Glob, Write, Web | effort high, workspace-write |
| `content-scout` | Researches in depth (at least 12 dated sources, visual sites such as Pinterest, your image connectors), saves visual and motion references to `scout-refs/`, picks an angle and hooks, states a timing hypothesis; keeps broad evidence apart from your own results | sonnet, effort high; inherits your session's tools, including connectors, read and search only | effort high, workspace-write |
| `content-writer` | Writes every string of the piece in your voice, plus alt text | opus, effort high; Read, Grep, Glob, Write | effort high, workspace-write |
| `content-designer` | Art-directs each piece, writes a composition and motion spec, and renders the local path from code: stills, and fully animated video built with GSAP and captured frame by frame | opus, effort high; Read, Grep, Glob, Edit, Write, Shell | effort high, workspace-write |
| `content-qa` | Records one verdict per check, including motion quality, using machine checks and contact sheets instead of frame-by-frame review; does not fix content | sonnet, effort medium; Read, Grep, Glob, Write, Shell | effort medium, workspace-write |

Video renders need Node.js 18 or later and ffmpeg on your path; the designer installs GSAP and Playwright into each run's `code/` folder. The designer's guides (`motion-design.md`, `kinetic-typography.md`, `video-pipeline.md`, `visual-fx.md`) and the scout's `scout-research.md` ship in the skill's `references/` folder, and `visual-system.md` has an optional `## 10. Motion` slot for your own motion rules.

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
- Claude manual installs are not namespaced: use `software-architect`, not `gaisser-agents:software-architect`; the skills are `/software-team` and `/content-team`.
- To remove: delete the installed files listed by `--list`.

## Customize, and name collisions

- Plugin agents are scoped, for example `gaisser-agents:software-architect`. The skill always uses the scoped names.
- Your own `~/.claude/agents/software-architect.md` (and so on) wins for the bare name, because user-level agents beat plugin agents. The skill uses the scoped names, so both can coexist. Name the scoped agent when you call one role directly.
- Agent and skill names are unique across teams, and every team has a required unique agent prefix (`dev-` and `content-` today).
- Copy an agent to `~/.claude/agents/` or `~/.codex/agents/` and edit it. The installers keep your files unless you pass force.

## Security and permissions

- Claude Code: every agent has an explicit tool allowlist. Plugin agents cannot set permission modes, hooks, or MCP servers.
- Agents marked as using the session's tools get every tool of the session, including MCP tools, except launching other agents.
- Codex: each agent has a `sandbox_mode` (`read-only` or `workspace-write`) and your approval settings apply. Subagents inherit the session's sandbox.

## Troubleshooting

- Agents missing: reload plugins or restart the tool. Check `claude plugin list`, and for Codex the `~/.codex/agents` and plugin folders.
- Codex needs `[agents] enabled = true` (the default). Every team's agents follow the same rule. To change a role's reasoning effort, for example the architect's, edit `effort` in `teams/software-team/agents/software-architect/agent.json`, rebuild, or set `agents.default_subagent_reasoning_effort`.
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
