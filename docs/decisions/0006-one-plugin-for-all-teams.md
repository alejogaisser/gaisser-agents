# 0006. One plugin for all teams

- Date: 2026-10-05
- Status: accepted
- Supersedes: 0001, 0003, 0004
- Decision: Every team's agents and skills ship in one plugin per tool, named after `catalog.json` `plugin.name` (`gaisser-agents`) and versioned by `plugin.version`. Sources stay one folder per team. Agent names carry a required unique team prefix (`agentPrefix`, for example `dev-`). Each team keeps one entry skill named like the team (`/gaisser-agents:dev-team`, `$dev-team`). `targets` filters a team's components inside the shared plugins.
- Reason: The Claude Code slash menu nests only plugin -> skill, so one plugin per team means one top-level row per team, and at 20 teams one tidy plugin per tool beats per-team install granularity. Codex invokes skills by their own name, so collapsing costs no invocation change.
