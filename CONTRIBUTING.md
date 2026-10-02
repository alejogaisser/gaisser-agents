# Contributing

## 1. Ground rules

- Everything in the repository is in English.
- One purpose per agent. Least privilege: grant only the capabilities an agent needs.
- Prompts are tool-neutral: write "web search", "the shell", and "CLAUDE.md or AGENTS.md", never a tool's own names.
- No emojis.
- Names are unique, kebab-case, and never contain `claude` or `anthropic`.

## 2. How the repository works

Sources (`catalog.json`, `agents/`, `skills/`) go through `scripts/build.py` into generated files that are committed and never edited by hand:

- `.claude-plugin/marketplace.json` and `dist/claude-code/` (Claude Code plugin)
- `dist/codex/` (Codex custom agents as TOML, plus the skill)
- `dist/codex-plugin/` and `.agents/plugins/marketplace.json` (Codex plugin: skills only, because Codex plugins cannot carry custom agents)

Commit sources and regenerated outputs together. CI fails when they are out of sync.

## 3. Improve an agent or skill

1. Edit the sources.
2. Run `py -3 scripts/build.py` (or `python3 scripts/build.py`). Python 3.11 or later is required.
3. Bump the plugin `version` in `catalog.json`: MAJOR for removing or renaming an agent or skill or an incompatible role change, MINOR for adding an agent, skill, or capability, PATCH for wording.
4. Commit everything.

## 4. Add an agent

1. Create `agents/<name>/agent.json` with `name`, `description` (40 to 400 chars, containing "Use "), `capabilities`, `model`, and `effort` (required unless the model tier is `fast`).
2. Create `agents/<name>/prompt.md` with the template: starts with "You are", then the headings `## When invoked`, `## Process`, `## Output format`, `## Boundaries` in that order, 25 to 80 lines, ending with the two standard Boundaries bullets.
3. Add the name to a plugin's `agents` list in `catalog.json`.
4. Add a row to the README catalog.
5. Build.

For a new theme (a new plugin), open an issue first.

## 5. Neutral metadata reference

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
- The color is set per plugin in `catalog.json` and applies to Claude Code only.

## 6. Skills

- `skills/<name>/skill.json`: `name`, `description` (40 to 1024 chars), optional `argumentHint`, `modelInvocable`, and `agents`.
- `skills/<name>/instructions.md`: the body. Refer to agents with `{{agent:NAME}}` tokens; they render as `plugin:NAME` for Claude Code and `NAME` for Codex. Every token must name an agent listed in `skill.json`.
- Keep a single-session fallback section so the skill works without subagents.
- Limits: 500 lines, 1024-character description.

## 7. Test locally

- `py -3 scripts/build.py --check`
- `py -3 -m unittest discover -s scripts/tests -v`
- `claude plugin validate . --strict` and `claude plugin validate dist/claude-code/dev-pipeline --strict`
- `claude --plugin-dir ./dist/claude-code/dev-pipeline`
- The install scripts with `--base` (or `-Base`) pointing at a temporary folder. Never use your real home folder while testing.

## 8. New tools

Adapters live in `scripts/build.py`. See the Roadmap in the README and open an issue before starting.

## 9. Pull request checklist

- [ ] Sources edited, never `dist/` by hand
- [ ] `py -3 scripts/build.py` run and outputs committed
- [ ] Plugin `version` bumped in `catalog.json` when anything under `dist/` changed
- [ ] README catalog updated
- [ ] `py -3 scripts/build.py --check` reports 0 errors
