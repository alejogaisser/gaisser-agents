<!-- dev-team plan -->
# Plan: collapse every team into one plugin, `gaisser-agents`, for both tools

- Repository: https://github.com/alejogaisser/gaisser-agents, branch `main`, local copy `C:\dev\Agents`.
- Date: 2026-10-05. Revision 1 (see `## Revisions`): Codex collapses too.
- Review gate: yes (more than 3 files, and it changes how the catalog is packaged).

## Handoff

### Goal

One installable unit per tool, named `gaisser-agents`, holding every team's agents and skills. In
Claude Code the slash menu shows one top-level row, "Gaisser Agents", whose submenu lists one entry
skill per team. Sources keep one folder per team under `teams/`. After the change the user runs
`/gaisser-agents:dev-team` and calls `@agent-gaisser-agents:dev-architect`, `dev-coder`, `dev-tester`;
in Codex the skill stays `$dev-team` and the agents become `dev_architect`, `dev_coder`, `dev_tester`.
At 20 teams the repository still has one plugin per tool, not 20.

### Context

- `catalog.json`: tool-neutral root (`marketplace`, `teams`, `renames`). Gains the plugin identity.
- `scripts/build.py`: the only writer of generated files. `render_outputs` (line ~672) keys every
  output by relative path; `load_sources` validates; `check_version_bumps` maps `dist/` paths to
  `teams/<team>/team.json`.
- `teams/dev-team/`: `team.json`, `agents/{architect,coder,tester}/`, `skills/dev-team/`.
- `scripts/tests/test_build.py`: ~190 references to the old names and paths.
- `README.md`, `CONTRIBUTING.md`, `install.sh`, `install.ps1`, `.github/workflows/ci.yml`.
- `docs/decisions/0001-group-sources-by-team.md` ("one team folder is one plugin") and
  `0003-team-names-and-entry-skills.md` are contradicted; `0004-per-team-tool-targets.md` keeps its
  decision but changes meaning (see decision 4); `0002` (renames map) stays as it is.
- Claude Code `renames`, verified 2026-10-05: maps a former plugin `name` to its current name or to
  `null`; Claude Code rewrites the old key in `enabledPlugins` and `pluginConfigs` (user, project,
  local scopes) and shows `Renamed to "<new>" in the "<marketplace>" marketplace` once. Append-only,
  the chain is followed from the oldest name and must end at a name in `plugins[]` or at `null`. For
  a git-hosted marketplace the renamed plugin reports `Plugin "<name>" not cached at <path>` until
  the user runs `/plugin install <new>@<marketplace>` once. Sources:
  /docs/en/plugins/marketplace-reference, /docs/en/plugins/host-marketplace.
- Codex, verified 2026-10-05 (see decision 3 for what the docs do **not** settle): a plugin bundles
  "one or more" skills and discovers them from its root `skills/` directory; skills are invoked by
  their own name (`$<skill>` in the Codex CLI and the IDE extension); custom subagents are standalone
  TOML files in `~/.codex/agents/` or `.codex/agents/`, identified by their `name` field, with no
  folder or plugin grouping; the Agent Plugins manifest requires only `$schema` and `name` and has no
  field that lists skills. Sources: developers.openai.com/plugins/build/plugins,
  agent-plugins.org/schemas/1.0.0/plugin.schema.json, learn.chatgpt.com/codex/skills,
  learn.chatgpt.com/codex/plugins, learn.chatgpt.com/codex/agent-configuration/subagents.

### Constraints

- Source layout per team stays: adding a team is still adding one folder under `teams/`.
- Generated files are only ever produced by `scripts/build.py`; commit sources and outputs together.
- ASCII-only in `install.sh`, `install.ps1`, `scripts/build.py`; no emoji anywhere.
- Decided by the owner, do not re-open: plugin slug `gaisser-agents`, `displayName` "Gaisser Agents",
  install id `gaisser-agents@gaisser-agents`; entry skill stays `dev-team`; agents become
  `dev-architect`, `dev-coder`, `dev-tester`; the build must reject an agent-name collision between
  two teams; tidiness at ~20 teams outranks per-team install granularity.
- Keep Python 3.11+, stdlib only.

### Files to touch

- `catalog.json` (modify): add the `plugin` block; extend `renames`.
- `teams/dev-team/team.json` (modify): add `agentPrefix`, remove `version`.
- `teams/dev-team/agents/{architect,coder,tester}/` (rename to `dev-architect`, `dev-coder`,
  `dev-tester`): folder name and the `name` field must match.
- `teams/dev-team/skills/dev-team/{skill.json,instructions.md}` (modify): renamed agents and tokens.
- `scripts/build.py` (modify): one plugin per tool out of N teams.
- `scripts/tests/test_build.py` (modify): paths, names, renames, versions, installer expectations.
- `README.md`, `CONTRIBUTING.md` (modify): new names, install ids, migration section.
- `install.sh`, `install.ps1` (modify): hint lines and the `-p/--plugin` help text.
- `.github/workflows/ci.yml` (modify): the smoke-test file names.
- `docs/decisions/0006-one-plugin-for-all-teams.md` (create); `0001`, `0003`, `0004` (modify: Status
  line only); `docs/lessons-learned.md` (modify: one line).
- Generated, by running the build: `.claude-plugin/marketplace.json`, `dist/claude-code/**`,
  `dist/codex/**`, `dist/codex-plugin/**`, `.agents/plugins/marketplace.json`.

### Out of scope

- Adding the content team or any new team.
- Changing the installers' copy semantics or the Agent Plugins schema version.
- Rewriting history in `docs/plan-content-team.md`, `docs/research-content-team.md`,
  `docs/content-team-*.md`, or old decision records beyond their Status lines.

### Acceptance criteria

- AC1: `py -3 scripts/build.py` writes exactly these 13 files and removes every stale one.
  Check: run it, then `git status --porcelain`. Pass: 13 files, 0 errors, and the set is
  `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`,
  `dist/claude-code/gaisser-agents/.claude-plugin/plugin.json`,
  `dist/claude-code/gaisser-agents/agents/{dev-architect,dev-coder,dev-tester}.md`,
  `dist/claude-code/gaisser-agents/skills/dev-team/SKILL.md`,
  `dist/codex/gaisser-agents/agents/{dev-architect,dev-coder,dev-tester}.toml`,
  `dist/codex/gaisser-agents/skills/dev-team/SKILL.md`,
  `dist/codex-plugin/gaisser-agents/plugin.json`,
  `dist/codex-plugin/gaisser-agents/skills/dev-team/SKILL.md`; no `*/dev-team/` folder is left under
  `dist/claude-code/`, `dist/codex/`, or `dist/codex-plugin/`.
- AC2: `py -3 scripts/build.py --check` reports `0 error(s)` on the committed tree.
- AC3: `.claude-plugin/marketplace.json` has exactly one entry, `{"name": "gaisser-agents",
  "source": "./dist/claude-code/gaisser-agents", ...}`, and
  `"renames": {"dev-pipeline": "dev-team", "dev-team": "gaisser-agents"}`.
  `.agents/plugins/marketplace.json` has exactly one entry, named `gaisser-agents`, whose
  `source.path` is `./dist/codex-plugin/gaisser-agents` and resolves to an existing folder.
- AC4: `dist/claude-code/gaisser-agents/skills/dev-team/SKILL.md` contains
  `` `gaisser-agents:dev-architect` ``, `` `gaisser-agents:dev-coder` ``,
  `` `gaisser-agents:dev-tester` `` and no `dev-team:` prefix; both Codex SKILL.md copies contain
  `` `dev_architect` ``, `` `dev_coder` ``, `` `dev_tester` `` and are byte-identical to each other.
- AC5: a second team whose agent name collides with `dev-architect` fails the build.
  Check: in a temp copy add a team with an agent named `dev-architect`, run `build.validate`.
  Pass: ERROR on `catalog.json` saying the agent is defined by more than one team. Same for a
  colliding skill name.
- AC6: a team without `agentPrefix`, or with a prefix another team already uses, fails the build.
  Pass: ERROR on `teams/<team>/team.json` (missing) or `catalog.json` (duplicate).
- AC7: `py -3 -m unittest discover -s scripts/tests` passes with 0 failures and 0 errors.
- AC8: `claude plugin validate . --strict` and
  `claude plugin validate dist/claude-code/gaisser-agents --strict` exit 0.
- AC9: any change under `dist/` without a bump of `plugin.version` in `catalog.json` is an error.
  Check: edit a prompt, rebuild without bumping, run
  `py -3 scripts/build.py --check --base-ref <ref>`. Pass: ERROR on `catalog.json` naming
  `plugin.version`. A lower version is also an ERROR; a base ref whose `catalog.json` has no
  `plugin` key is skipped with no error.
- AC10: `bash install.sh --list --target all` prints the same plugin name for both targets:
  `[claude] gaisser-agents   agents: dev-architect, dev-coder, dev-tester   skills: dev-team` and
  `[codex] gaisser-agents   agents: dev-architect, dev-coder, dev-tester   skills: dev-team`, and
  `bash install.sh --target all --plugin gaisser-agents --base <tmp>` prints no `n/a` line.
- AC11 (manual, cannot be checked by the build): in Codex, after installing the single
  `gaisser-agents` plugin, `$dev-team` resolves and runs the dev team. If Codex turns out to prefix a
  plugin's skills, record the real invocation in the README instead; nothing in the build changes.
- AC12: `targets` still filters per team. Check: in a temp copy add a `claude-code`-only team and a
  `codex`-only team, build. Pass: the claude-only team's agents exist only under
  `dist/claude-code/gaisser-agents/`, the codex-only team's only under `dist/codex/gaisser-agents/`
  and `dist/codex-plugin/gaisser-agents/`, and each tool's plugin manifest is written once.

## Design decisions

1. **One plugin identity, in `catalog.json`.** The plugin is catalog-level data now, so
   `catalog.json` gains a required `plugin` object, used for both tools' manifests. Deriving it from
   `marketplace` was rejected: the plugin needs its own `version` and `displayName`.

   ```json
   "plugin": {
     "name": "gaisser-agents",
     "displayName": "Gaisser Agents",
     "version": "3.0.0",
     "description": "<single line, one sentence>",
     "category": "development",
     "keywords": ["agents", "teams", "orchestration", "planning", "testing"]
   }
   ```

2. **Claude Code: one plugin directory named after the slug.** All teams merge into
   `dist/claude-code/gaisser-agents/{.claude-plugin/plugin.json, agents/<agent>.md,
   skills/<skill>/SKILL.md}`, one marketplace entry. Agent and skill names are flat there, which is
   why prefixes become mandatory. Rejected: making `dist/claude-code/` itself the plugin root,
   because the installers and the CI validator loop iterate `dist/claude-code/*/`.

3. **Codex: collapses the same way.** `dist/codex-plugin/gaisser-agents/` holds every team's skills
   and one `plugin.json`, and `.agents/plugins/marketplace.json` carries one entry. The docs settle
   the two points this needs: a plugin bundles one or more skills discovered from its root `skills/`
   directory, and a skill is invoked by its own name (`$dev-team`), so merging changes no invocation.
   `dist/codex/` collapses to `dist/codex/gaisser-agents/` on the same tidiness grounds: Codex loads
   subagents as standalone TOML files from a flat `~/.codex/agents/`, identified by their `name`
   field, with no grouping, so the per-team folder was only a label for the installer, and
   `dist/codex/gaisser-agents/skills/` keeps the manual-install skill beside the agents it runs.
   **Not settled by the docs:** the plugin build page says a host uses the plugin name as the
   "component namespace", while the skills and plugins pages say skills keep their own invocation
   names. Assumed: no prefix, so `$dev-team` is unchanged; AC11 verifies it by hand, and the worst
   case is a README wording fix, not a rebuild. Also not documented: any Codex equivalent of
   `renames`, and the Agent Plugins schema has no such field, so Codex plugin users uninstall
   `dev-team` and install `gaisser-agents` (decision 6).
   Trade-off accepted by the owner: neither tool can install a single team any more. `--all` and
   `-p gaisser-agents` install the whole catalog, and at 20 teams `dist/` holds 3 folders instead of
   41. This also removes the per-target divergence the installers would otherwise have had.

4. **`targets` keeps its job, with a narrower meaning.** It now filters which trees a team's
   components are emitted into, instead of deciding whether a per-team plugin exists. A tool's
   plugin manifest and marketplace entry are written once, when at least one team lists that tool;
   a `claude-code`-only team contributes nothing under `dist/codex*/`, and a `codex`-only team
   contributes nothing under `dist/claude-code/`. If no team targets a tool, that tool gets no
   plugin directory and an empty `plugins` array, which the build reports as a WARN. ADR 0004 is
   superseded by 0006 for this wording; the field itself stays.

5. **`agentPrefix` becomes required, and unique across teams.** A structural guarantee against
   collisions on top of the existing global duplicate-name error, and it protects the flat
   `~/.codex/agents/` namespace too. `dev-team` gets `"agentPrefix": "dev-"`.

6. **Token rendering.** `_render_skill_body(text, plugin_name, tool)` already takes the name used for
   the Claude prefix; the call site passes `catalog["plugin"]["name"]`, so `{{agent:dev-architect}}`
   renders as `` `gaisser-agents:dev-architect` `` for Claude Code and `` `dev_architect` `` for
   Codex (mapping unchanged).

7. **Migration.** Claude Code: `renames` becomes
   `{"dev-pipeline": "dev-team", "dev-team": "gaisser-agents"}` - append-only, and the chain resolves
   because `dev-team` is a key in the map and `gaisser-agents` is in `plugins[]`. A user who has
   `dev-team@gaisser-agents` installed is migrated, not forced to uninstall: after
   `/plugin marketplace update gaisser-agents` the settings key is rewritten, and because the
   marketplace is git-hosted they then run `/plugin install gaisser-agents@gaisser-agents` once.
   Claude Code older than v2.1.193 has no renames support (uninstall, then install), and managed
   settings cannot be rewritten by Claude Code. Codex: no documented rename mechanism, so uninstall
   the `dev-team` plugin and install `gaisser-agents`. Installer users re-run with `--force` and
   delete the old unprefixed files by hand.
   `_validate_renames` must resolve against the plugin name, not `catalog["teams"]`, because
   `dev-team` is still a team folder name while no longer being a plugin name.

8. **One version for everything: `plugin.version`.** Both manifests take it, so `team.json` loses
   `version` (it would no longer appear in any output, and a per-team bump rule would contradict a
   shared plugin version). `check_version_bumps` becomes one rule: any change under `dist/` requires
   a higher `plugin.version`. Trade-off: a wording fix in one team bumps the version every user sees,
   which is correct for a single plugin but means release notes must say which team changed.
   `team.json` keeps `displayName` as a docs-only human label; `color` stays per team and still
   reaches each agent's Claude Code frontmatter.

## Risks and edge cases

- Codex namespacing is the one unverified point (decision 3). Mitigation: AC11, and the README says
  the invocation plainly so a correction is one line.
- Stale copies: manual installs keep `~/.claude/agents/{architect,coder,tester}.md` and
  `~/.codex/agents/{architect,coder,tester}.toml`; the installers never delete. The README migration
  section must tell users to remove them, or the old unprefixed agents stay callable.
- A user who installs the new id before updating the marketplace would briefly hold two plugins with
  the same skill name; the documented order (marketplace update first) avoids it.
- `--base-ref` against a commit whose `catalog.json` has no `plugin` key: skip the check instead of
  failing (same policy the per-team check used for a new team).
- Dropping `version` from `team.json` is caught by the existing unknown-key check, which gives a
  clear error for anyone carrying an old team folder. Cover it with a test.
- Skill-name uniqueness already errors, but it is now load-bearing twice over (flat `skills/` in both
  plugins); keep it and test it.
- `check_docs` README sync: add `plugin.name` to the names that must appear in backticks.

## Ordered steps

1. `catalog.json`: add the `plugin` block from decision 1 after `marketplace`, and set
   `"renames": {"dev-pipeline": "dev-team", "dev-team": "gaisser-agents"}`.
2. `teams/dev-team/team.json`: add `"agentPrefix": "dev-"`, delete `"version"`. Keep `name`,
   `displayName`, `description`, `category`, `keywords`, `color`, `targets`.
3. Rename the three agent folders (`git mv`) to `dev-architect`, `dev-coder`, `dev-tester` and set
   the matching `name` in each `agent.json`. Do not touch `prompt.md`: the prompts use role words
   ("the coder", "the architect"), never addressable names.
4. `teams/dev-team/skills/dev-team/skill.json`: `"agents": ["dev-architect", "dev-coder",
   "dev-tester"]`. `instructions.md`: update the three `{{agent:...}}` tokens in the Agents table and
   nothing else.
5. `scripts/build.py`, constants: `CATALOG_KEYS = {"marketplace", "plugin", "teams", "renames"}`,
   `CATALOG_REQUIRED = {"marketplace", "plugin", "teams"}`, new
   `PLUGIN_KEYS = {"name", "displayName", "version", "description", "category", "keywords"}`,
   `TEAM_KEYS` loses `version` and `TEAM_REQUIRED = TEAM_KEYS` (so `agentPrefix` is required).
   Update the module docstring: the generated layout lines become `dist/<tool>/<plugin>/...`, one
   plugin per tool for every team.
6. `scripts/build.py`, validation:
   - New `_validate_plugin(plugin, findings) -> str | None`, path `catalog.json`: object,
     `check_keys(..., PLUGIN_KEYS)`, `name` kebab-case <=64, free of `claude`/`anthropic`, not
     starting with `cc-plugin-`; `displayName` and `description` single-line; `version` semver;
     `category` kebab-case; `keywords` a non-empty list of kebab-case strings. Returns the name.
   - `_validate_catalog` calls it and passes `{plugin_name}` into
     `_validate_renames(renames, plugin_names, findings)`; keep the chain logic otherwise verbatim.
   - `_validate_team`: `agentPrefix` missing is an ERROR; drop the semver check with `version`.
   - `load_sources`: collect `prefix -> [teams]` and ERROR on `catalog.json` when two teams share a
     prefix; keep the agent and skill duplicate-name errors unchanged; WARN on `catalog.json` for
     each tool in `TARGETS` that no team targets.
7. `scripts/build.py`, `render_outputs`: compute `plugin = catalog["plugin"]`, `pname =
   plugin["name"]`, and the three bases once, before the team loop: `cbase =
   "dist/claude-code/%s" % pname`, `xbase = "dist/codex/%s" % pname`, `pbase =
   "dist/codex-plugin/%s" % pname`. Write, each at most once and only when some team targets that
   tool: `cbase + "/.claude-plugin/plugin.json"` and the single `claude_entries` entry (`name`,
   `source` `"./" + cbase`, `description`, `category`, `tags`; no `version`, so `plugin.json` stays
   authoritative); `pbase + "/plugin.json"` and the single `codex_entries` entry (same shape as
   today, `source` `{"source": "local", "path": "./" + pbase}`). Both manifests take `name`,
   `version`, `description`, `keywords` from `plugin`, plus the marketplace `owner`, `repository`,
   `license`, and `homepage = repo + "#" + pname`; the Claude one also takes `displayName`. Inside
   the team loop keep every per-agent and per-skill write exactly as it is, only with the shared
   bases, the per-team `targets` gate unchanged, `color` still from `team.json`, and `pname` passed
   to `_render_skill_body`. The Codex TOML header comment keeps naming the source team folder.
8. `scripts/build.py`, `check_version_bumps`: replace the per-team logic. If `git diff --name-only
   <base>...HEAD -- dist/` is non-empty, read `plugin.version` from `git show <base>:catalog.json`
   and from the working `catalog.json`; equal -> ERROR on `catalog.json` ("dist/ changed but
   plugin.version was not bumped (<v>)"), lower -> ERROR ("plugin.version went down (<old> -> <new>)"),
   base without a `plugin` key -> skip. Keep `semver_tuple` and the existing BuildFailure paths.
9. `scripts/build.py`, `check_docs`: add `catalog["plugin"]["name"]` to the names that must appear in
   the README wrapped in backticks.
10. Run `py -3 scripts/build.py`. Confirm AC1 (13 files; the three `dev-team` folders under `dist/`
    are gone, including their empty parents).
11. `scripts/tests/test_build.py`: update and extend.
    - Path and name updates: `OutputsTest.test_generated_file_set`, `test_architect_*` (now
      `dev-architect`; the Codex header comment still says `teams/dev-team/agents/dev-architect/`),
      `test_coder_and_tester_mappings`, `test_token_rendering_differs_per_tool`,
      `test_skill_frontmatter_fields`, `test_marketplace_and_plugin_json` (one entry, source
      `./dist/claude-code/gaisser-agents`, homepage ends `#gaisser-agents`), all of
      `CodexPluginTest` (paths under `dist/codex-plugin/gaisser-agents/`, `name` and entry name
      `gaisser-agents`, version from `catalog.json`), `Part1Test.test_t1` (the 13 paths),
      `test_t2_marketplaces_and_renames` (two-entry map), `test_t4_rendered_claude_skill`,
      `SyncTest` fixtures, `VersionBumpTest` (now drives `catalog.json` `plugin.version`),
      `InstallBase.*` and both `run_install` builders (`--plugin gaisser-agents` for every target),
      `test_t20_installers_hints`, `Part2*` fixtures and their dist paths.
    - `TeamFixture.add_team`: no `version` key, an `agentPrefix` per fixture team, and an agent named
      with that prefix (for example prefix `x-`, agent `x-helper`).
    - New tests: (a) cross-team agent-name collision is an ERROR, and so is a skill-name collision
      (AC5); (b) missing `agentPrefix` is an ERROR, duplicate prefix across teams is an ERROR (AC6);
      (c) two teams targeting both tools produce one `plugin.json` per tool, one entry per
      marketplace, and both teams' components under the shared folders; (d) `targets` filtering with
      a claude-only and a codex-only team (AC12), including the WARN when no team targets a tool;
      (e) a renames chain that ends at a team name is an ERROR while `{"dev-team":
      "gaisser-agents"}` is valid; (f) `plugin.version` not bumped after a `dist/` change is an
      ERROR, a bump passes, a decrease errors (AC9); (g) a `team.json` that still carries `version`
      is an unknown-key ERROR.
12. `install.sh` and `install.ps1`: no logic change. Update the `-p/--plugin` help text (the catalog
    ships one plugin, `gaisser-agents`, for every target) and the closing hints to
    `Claude manual installs are not namespaced: use 'dev-architect', not
    'gaisser-agents:dev-architect', and call a team with its skill, for example /dev-team.` plus the
    existing Codex line. ASCII only.
13. `.github/workflows/ci.yml`: the smoke-test assertions become `.claude/agents/dev-architect.md`
    and `.codex/agents/dev-architect.toml`; the skill paths and the `dist/claude-code/*/` validator
    loop are unchanged.
14. `README.md`: Teams table (`/gaisser-agents:dev-team`, `$dev-team`, agents `dev-architect`,
    `dev-coder`, `dev-tester`), the Claude install block
    (`/plugin install gaisser-agents@gaisser-agents`, `claude plugin details gaisser-agents`,
    uninstall, `enabledPlugins` `"gaisser-agents@gaisser-agents": true`), the Codex install block
    (install the `gaisser-agents` plugin; `bash install.sh --target codex --plugin gaisser-agents
    --agents-only`), "Call a team" (`/gaisser-agents:dev-team`, with the short `/dev-team` while no
    other skill claims it), the router tip, the catalog table rows, "Manual install details",
    "Customize, and name collisions", and Troubleshooting
    (`teams/dev-team/agents/dev-architect/agent.json`). Add a "Migrating from dev-team 2.0.0"
    section: marketplace update, then one `/plugin install gaisser-agents@gaisser-agents`; renames
    rewrites `enabledPlugins`; older Claude Code uninstalls first; in Codex uninstall the `dev-team`
    plugin and install `gaisser-agents`; installer users re-run with `--force` and delete the stale
    unprefixed agent files by hand. Keep the dev-pipeline table and add the new rows. State that one
    plugin now carries every team, so installing it installs all of them.
15. `CONTRIBUTING.md`: section 2 (the `plugin` block; `dist/<tool>/<plugin>/` is one plugin per tool
    for every team), section 3 (one plugin for all teams, one entry skill per team, invoked
    `/<plugin>:<team>` or `$<team>`), section 4 (bump `plugin.version` in `catalog.json`, not
    `team.json`; MAJOR for removing or renaming an agent or skill, MINOR for adding a team, agent, or
    skill, PATCH for wording), section 5 (agent names are flat inside the plugin), section 6
    (`agentPrefix` required and unique, no `version` in `team.json`, no start-at-1.0.0 step),
    section 7 (renames target the plugin name), sections 8 and 9 (token rendering uses the plugin
    name; `targets` filters components inside the shared plugin), section 11
    (`claude plugin validate dist/claude-code/gaisser-agents --strict`,
    `claude --plugin-dir ./dist/claude-code/gaisser-agents`), and the section 12 checklist.
16. `docs/decisions/0006-one-plugin-for-all-teams.md` (new), five-line format: Decision = every
    team's agents and skills ship in one plugin per tool, named after `catalog.json` `plugin.name`
    (`gaisser-agents`) and versioned by `plugin.version`; sources stay one folder per team; agent
    names carry a required unique team prefix; each team keeps one entry skill named like the team
    (`/gaisser-agents:dev-team`, `$dev-team`); `targets` filters a team's components inside the
    shared plugins. Reason = the Claude Code slash menu nests only plugin -> skill, so one plugin per
    team means one top-level row per team, and at 20 teams one tidy plugin per tool beats per-team
    install granularity; Codex invokes skills by their own name, so collapsing costs no invocation
    change. Add `- Supersedes: 0001, 0003, 0004` and set those three Status lines to
    `superseded by 0006`, changing nothing else in them. Add one line to `docs/lessons-learned.md`
    dated 2026-10-05 about the two-level menu constraint driving the packaging.
17. Re-run `py -3 scripts/build.py`, then `py -3 scripts/build.py --check`,
    `py -3 -m unittest discover -s scripts/tests`, and the two `claude plugin validate` commands
    (AC2, AC7, AC8). Commit sources and generated files together. AC11 is a manual check in Codex
    after the commit.

## Open questions

- None blocking. The one unsettled fact (whether Codex prefixes a plugin's skills) is assumed to be
  "no prefix", isolated to README wording, and verified by AC11.

## Revisions

- R1 (2026-10-05): Codex now collapses into the same single `gaisser-agents` plugin
  (`dist/codex/gaisser-agents/`, `dist/codex-plugin/gaisser-agents/`, one entry in
  `.agents/plugins/marketplace.json`), `team.json` loses `version` in favour of `plugin.version`,
  `check_version_bumps` becomes a single catalog-level rule, the installers take one plugin name for
  every target, and ADR 0004 is superseded too. The earlier revision kept Codex per team for install
  granularity; the owner's priority is tidiness at ~20 teams.

## Memory

- Decision records: `docs/decisions/0006-one-plugin-for-all-teams.md`, plus the Status lines of
  `0001`, `0003`, and `0004`.
- Lessons learned: `docs/lessons-learned.md`, one line about the plugin -> skill menu nesting
  deciding the packaging.
