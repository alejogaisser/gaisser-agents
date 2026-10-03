# Contributing

## 1. Ground rules

- Everything in the repository is in English.
- One purpose per agent. Least privilege: grant only the capabilities an agent needs.
- Prompts are tool-neutral: write "web search", "the shell", and "CLAUDE.md or AGENTS.md", never a tool's own names.
- No emojis.
- Names are unique, kebab-case, and never contain `claude` or `anthropic`.
- Never commit personal or brand data, fonts, or binaries.

## 2. How the repository works

- `catalog.json` holds the marketplace metadata, the ordered `teams` list, and `renames` (append-only history of renamed or retired plugins).
- `teams/<team>/` holds the sources of one team: `team.json`, `agents/<name>/{agent.json,prompt.md}`, and `skills/<name>/{skill.json,instructions.md}`.

Sources go through `scripts/build.py` into generated files that are committed and never edited by hand:

- `.claude-plugin/marketplace.json` and `dist/claude-code/` (Claude Code plugin)
- `dist/codex/` (Codex custom agents as TOML, plus the skill)
- `dist/codex-plugin/` and `.agents/plugins/marketplace.json` (Codex plugin: skills only, because Codex plugins cannot carry custom agents)

Commit sources and regenerated outputs together. CI fails when they are out of sync.

## 3. Teams

- One team is one plugin: its agents plus one entry skill named like the team.
- The main conversation orchestrates: the entry skill runs in the main session, and the subagents never talk to the user or to each other.
- Team names end in `-team` (for example `dev-team`).

## 4. Improve an agent or skill

1. Edit the sources under `teams/<team>/`.
2. Run `py -3 scripts/build.py` (or `python3 scripts/build.py`). Python 3.11 or later is required.
3. Bump `version` in `teams/<team>/team.json`: MAJOR for removing or renaming an agent or skill or an incompatible role change, MINOR for adding an agent, skill, or capability, PATCH for wording.
4. Commit everything.

## 5. Add an agent

1. Create `teams/<team>/agents/<name>/agent.json` with `name`, `description` (40 to 400 chars, containing "Use "), `capabilities`, `model`, and optionally `effort` (forbidden when the model tier is `fast`).
2. Create `teams/<team>/agents/<name>/prompt.md` with the template: starts with "You are", then the headings `## When invoked`, `## Process`, `## Output format`, `## Boundaries` in that order, 25 to 80 lines, ending with the two standard Boundaries bullets.
3. If the team sets an `agentPrefix` in `team.json`, the agent name must start with it. Agent names are unique across the whole catalog.
4. List the agent in the entry skill's `skill.json` `agents` (and reference it with a `{{agent:NAME}}` token).
5. Add a row to the README catalog.
6. Build.

## 6. Add a team

Open an issue first. Then:

1. Create `teams/<team>/team.json`, with `agentPrefix` set (for example `content-`).
2. Set `targets` (`claude-code`, `codex`, or both).
3. Add the agents.
4. Add the entry skill `teams/<team>/skills/<team>/`, with a mode or flow section, a final report, and a single-session fallback.
5. Add the team to `teams` in `catalog.json`.
6. Update the README (teams table and catalog section).
7. Start at version `1.0.0`.
8. Build, check, validate with `claude plugin validate`, and run the tests.

## 7. Rename or retire a team

Add an entry to `renames` in `catalog.json`: the old plugin name maps to the new team name, or to `null` to retire it. Never edit or reuse old entries. Add a migration note to the README.

## 8. Neutral metadata reference

| Capability | Claude Code `tools` | Codex |
|---|---|---|
| `read` (required) | Read, Grep, Glob | always allowed |
| `edit` | Edit | `workspace-write` sandbox |
| `write` | Write | `workspace-write` sandbox |
| `notebook` | NotebookEdit | `workspace-write` sandbox |
| `shell` | Bash, PowerShell | commands run within the sandbox |
| `lsp` | LSP | not mapped |
| `web` | WebFetch, WebSearch | not mapped |

- Model tiers: `deep` (opus), `standard` (sonnet), `fast` (haiku, no effort). Codex does not set a model.
- Effort: `low`, `medium`, `high`, `xhigh`, `max`; it maps to Claude `effort` and Codex `model_reasoning_effort`.
- `capabilities: "inherit"` gives the agent every tool of the session (including MCP tools) except launching other agents; use it only for MCP-dependent agents. Claude output gets `disallowedTools: Agent` and no `tools` line, and Codex output gets no `sandbox_mode`.
- `effort` is optional for `deep` and `standard` (omitted means the session's value) and forbidden for `fast`.
- Codex agent names: hyphens become underscores in the TOML `name` and in Codex skill tokens (`x-helper` becomes `x_helper`); the file name keeps its hyphens. Reserved Codex names are checked before and after the mapping.
- The color is set per team in `team.json` and applies to Claude Code only.
- `targets` in `team.json` lists the tools a team is generated for: `claude-code`, `codex`, or both. A team that targets only `claude-code` produces no Codex output.

## 9. Skills

- `teams/<team>/skills/<name>/skill.json`: `name`, `description` (40 to 1024 chars), optional `argumentHint`, `modelInvocable`, and `agents` (which must belong to the same team).
- `teams/<team>/skills/<name>/instructions.md`: the body. Refer to agents with `{{agent:NAME}}` tokens; they render as `team:NAME` for Claude Code and `NAME` for Codex. Every token must name an agent listed in `skill.json`.
- Keep a single-session fallback section so the skill works without subagents.
- Limits: 500 lines, 1024-character description.
- Skill files: `assets/` and `references/` are flat folders of text files only (`md`, `txt`, `json`, `csv`, `yaml`, `yml`, lowercase kebab-case names), at most 64 KiB each, and are copied verbatim into every generated plugin.
- Project context files convention: teams never ship personal or brand data (voice, people, palettes, fonts, photos). The entry skill declares them in a `## Project context` section (file, default path, template, required). The default path is `team-context/<team>/<file>.md`, overridable in the project's CLAUDE.md or AGENTS.md. If a required file is missing, the skill copies its template from `assets/`, asks the user to fill it in, and stops; the resolved paths are passed to every subagent. Binary inputs such as fonts stay in the user's project and `.gitignore` excludes font files.
- The dev-team skill holds the canonical handoff template; the architect prompt repeats its six field names in order, and a test keeps them in sync.

## 10. Planned teams

- `content-team`: Instagram carousels, Claude Code only (Canva MCP plus Claude in Chrome).
- `finance-team`: to be designed with the owner first.

## 11. Test locally

- `py -3 scripts/build.py --check`
- `py -3 -m unittest discover -s scripts/tests -v`
- `claude plugin validate . --strict` and `claude plugin validate dist/claude-code/dev-team --strict`
- `claude --plugin-dir ./dist/claude-code/dev-team`
- The install scripts with `--base` (or `-Base`) pointing at a temporary folder. Never use your real home folder while testing.

## 12. New tools, and the pull request checklist

Adapters live in `scripts/build.py`. See the Roadmap in the README and open an issue before starting.

- [ ] Sources edited, never `dist/` by hand
- [ ] `py -3 scripts/build.py` run and outputs committed
- [ ] `version` bumped in `teams/<team>/team.json` when anything under `dist/` changed
- [ ] README catalog updated
- [ ] `py -3 scripts/build.py --check` reports 0 errors
