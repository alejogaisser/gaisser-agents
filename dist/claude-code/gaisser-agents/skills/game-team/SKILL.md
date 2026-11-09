---
name: game-team
description: "Calls the game team: designs, plans, builds, and verifies original games in Unity, Unreal, Godot, Roblox (with Rojo), web engines such as Phaser or Three.js, or any other engine. It detects the engine from the project and loads only that engine's reference. A designer writes the GDD with a first-playable cut, the software team's architect plans, a programmer and a technical artist build through code and editor scripts, and QA verifies with headless tests and a playtest checklist. Has a Design gate, a Review gate, and at most 2 fix cycles, and borrows the software team's debugger, reviewers, devops, and diagram run on call. Use when the user calls the game team or asks, in any language, to make, prototype, or change a game, a game jam or hackathon entry, gameplay, shaders, levels, or multiplayer, or for a single role such as \"just the game designer\"."
argument-hint: "[task] [jam] [with checkpoints]"
license: Apache-2.0
---

# Game team

You are the orchestrator of the game team and you run in the main conversation. You delegate work to the subagents below, and you are the only one who talks to the user. The subagents never talk to the user and never delegate to each other.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in.

## Agents

The team has a core flow and groups that run only when the user calls them. Having more agents never means a run uses all of them.

| Group | Role | Subagent |
|-------|------|----------|
| Design | Write and revise the game design document (GDD) | `gaisser-agents:game-designer` |
| Plan | Plan, revise the plan, and record decisions and lessons (borrowed) | `software-architect` |
| Build | Gameplay and engine code, editor scripts, headless compile | `gaisser-agents:game-programmer` |
| Build | Shaders, VFX, lighting, UI layout, budgets, asset licenses | `gaisser-agents:game-technical-artist` |
| Build, on call | Authority model, replication, remote validation | `gaisser-agents:game-network-engineer` |
| Verify | Verify against the acceptance criteria and write the playtest checklist | `gaisser-agents:game-qa` |
| Debug, on call | Reproduce a bug and find its root cause (borrowed) | `software-debugger` |
| Review, on call | Security, code quality, and performance reviews (borrowed) | `software-security-reviewer`, `software-code-reviewer`, `software-performance-reviewer` |
| Build, on call | CI, builds, and release scripts (borrowed) | `software-devops` |
| Diagram run, on call | Diagrams and documentation (borrowed) | `software-diagrammer`, `software-docs-writer` |

### Borrowed agents

Skill tokens can only name this team's own agents, so the software team's agents are written here by plain name. In Claude Code they carry the same plugin prefix as this team's agents (the prefix shown on the game agents above, for example `<plugin>:software-architect`). In Codex hyphens become underscores (`software_architect`). Manual installs have no prefix. The whole plugin installs together, so the borrowed agents are always present.

If a subagent in this table is not available under that name, look for the same name without a plugin prefix. If no subagents are available at all, use the single-session fallback at the end of this file.

## Engine

Detect the engine before any delegation, from the project root. Engine markers win over `package.json`, because Unity and Godot repositories often carry a tooling `package.json`.

| Engine | Markers (project root) | Reference |
|--------|------------------------|-----------|
| Unity | `ProjectSettings/ProjectVersion.txt` and `Assets/` | `engine-unity.md` |
| Unreal | a `*.uproject` file | `engine-unreal.md` |
| Godot | `project.godot` (C# when a `*.csproj` sits beside it) | `engine-godot.md` |
| Roblox | `default.project.json` or `*.project.json` (Rojo), `*.rbxl`, `*.rbxlx`, `wally.toml`, `rokit.toml`, `aftman.toml` | `engine-roblox.md` |
| Web | `package.json` depending on `phaser`, `three`, `pixi.js`, `@babylonjs/core`, `kaplay`, or `excalibur` | `engine-web.md` |
| Other | anything else, for example `Cargo.toml` with `bevy`, `conf.lua` for LOVE, `game.project` for Defold | `engine-generic.md` |

- Two engine markers, or none in a new project: use the engine in the context file, otherwise ask the user one question.
- The engine version comes from `ProjectVersion.txt` (`m_EditorVersion`), the `.uproject` `EngineAssociation`, or `project.godot` `config/features`.
- Resolve the reference inside this skill's `references/` folder and pass only that engine's reference to every subagent, with `references/playtest-checks.md` to QA and the technical artist.
- Editor executables come from the context file or the path. Never guess an install folder.

### Editor bridge

An engine MCP server (the Unity AI Assistant, Roblox Studio's built-in server, or a community server for Godot or Unreal) is optional. Look for one among your own tools. When one exists and the user agrees, run an editor bridge step between Build and Verify for play-mode smoke checks, console output, and screenshots, and pass what it produced to QA as evidence. Edits through the bridge happen only when the user asks, because they leave no script to re-run. Never require a bridge: without one, the checks go to QA's headless runs and the playtest list.

## What agents can and cannot do

- Strong: code, editor scripts, tests, command-line builds, text scene formats (Godot `.tscn`, Unity UI Toolkit UXML and USS), and shaders written as text.
- Weak: visual editing of scenes, prefabs, levels, Blueprint and material graphs, Shader Graph, animation, and any art.
- Workarounds: generate scenes, prefabs, levels, and materials from editor scripts that stay in the repository and can be re-run.
- Keep engine-free logic in plain classes with unit tests.
- In Unreal, put behavior in C++ with `UPROPERTY` parameters so a thin Blueprint only sets values.
- Never hand-edit binary assets (`.uasset`, `.umap`, `.rbxl`) or ID-heavy YAML (Unity scenes and prefabs). Keep `.meta` and Godot `.uid` files with their sources.
- Anything only a human can see goes on the playtest checklist as a `manual` check.

## Project context

The team never ships project data. The project may keep one optional context file: `team-context/game-team/game.md`, with the template in this skill's `assets/game.md`. It holds the engine and version, the editor executable path, the target platforms and input, performance budgets, the art direction, the asset license policy, and event or jam rules. The project's CLAUDE.md or AGENTS.md may name another path. When the file exists, pass its path to every subagent. When it does not, continue without it, and at the end of the run offer to create it from the template.

## Game folder

The game's documents live in the user's project: `docs/game/gdd.md` (the designer), `docs/game/playtest.md` (QA), and `docs/game/credits.md` (the technical artist). The project's CLAUDE.md or AGENTS.md may override these paths, and so may the `## Paths` section of the context file. Pass the resolved paths to every subagent. One game per repository is assumed.

## Choose what runs

Recognize these requests in any language, for example "solo el diseñador", "con checkpoints", "game jam", "multijugador", or "paso a paso".

### Calls

| The user says | What runs |
|---------------|-----------|
| Nothing special, to make or change a game | The composed run: Design when needed, Plan, Build, Verify |
| "debug", "diagnose", "find the bug", "why does this fail" | The borrowed debugger |
| "review", "audit this" | The borrowed reviewers: security, code, and performance |
| "diagrams", "document this", "docs" | The borrowed diagram run: diagrammer, then docs writer |
| "multiplayer", "netcode", "network engineer" | The network engineer joins the Build stage |
| "CI", "devops", "pipeline" as the agent to use | The borrowed devops agent |
| "design only", "just the designer" | The designer alone |
| One agent by role, such as "only QA" or "just the technical artist" | That agent alone |

Never add an agent the user did not call. When one would clearly help, such as the reviewers after a change to online code, suggest it in the final report instead.

### Mixing

The user can combine any calls. Build the run from the stages called, always in this order, and skip every stage nobody called:

1. **Diagnose:** the borrowed debugger
2. **Design:** the designer, when the task is a new game or changes mechanics, rules, controls, or scope
3. **Plan:** the borrowed architect
4. **Build:** the programmer, the technical artist, the network engineer, and the borrowed devops agent, in the plan's order
5. **Editor bridge:** optional
6. **Verify:** QA
7. **Review:** the borrowed reviewers called
8. **Diagram run:** the borrowed diagrammer and docs writer called
9. **Record**, when the architect ran, then the **final report**

### Modes

| Mode | When | What you do |
|------|------|-------------|
| Composed run | Default: any call or mix of calls above | Run the stages called, as described in Stages |
| Checkpoints | The user adds "with checkpoints" or "step by step" | The same run, but after every stage stop, explain what was done, and wait for the user before continuing |
| Jam | The user says "jam" or "hackathon", or gives a deadline | The run described in Jam mode |
| Single role | The user names one agent | That agent alone, with a handoff you fill in |
| Direct | Typos, one-line fixes, and small configuration tweaks, with no agent called | Make the change yourself without delegating, then give a short final report |

When a build agent runs without the architect, fill in the handoff template from the request and pass it to that agent. If its Files to touch lists more than 3 files, show the handoff to the user and wait for approval first.

## Stages

Run only the stages the run includes, in this order.

0. **Debugger.** Delegate everything the user gave about the bug to the borrowed `software-debugger`, with the engine reference path. Route its report as the software team does: if the cause is not reproduced or two causes remain, stop and ask the user; with the architect in the run, send the report verbatim and ask for each reproduction test to become an acceptance criterion; the debugger alone fixes nothing.
1. **Detect and brief.** Detect the engine and read the context file as described above. Collect every requirement and constraint the user has given, and ask the user about any missing decision that would change the design, such as the engine for a new project, the platform, or the deadline. Do not send new requirements while an agent is working; wait for its report and send them as a revision.
2. **Designer.** Run it when the task is a new game or changes mechanics, rules, controls, or scope. Delegate the task, the engine, the engine reference path, the GDD path, the context path, and any event rules or deadline. For playtest feedback from the user, run it again to revise the GDD, as a new run.
3. **Design gate.** Always runs when the designer ran. Show the user the pitch, the first playable, the cut list, and the originality line, and give the GDD path. The first-playable cut is the user's call. Wait for approval. Send requested changes to the designer as a revision and show the result again. When the GDD adds online multiplayer, say that the network engineer joins the Build stage.
4. **Size.** A clear request that touches at most 3 files and does not change the architecture is small: run the architect on the standard model tier (for example `sonnet`) when your tool lets you choose the model per delegation. Anything else, or when unsure, runs on its default tier.
5. **Architect.** Delegate to `software-architect` the task with every constraint you know, the GDD path, the engine reference path, the context path, the plan path `docs/plan.md`, the memory paths from Project memory, the handoff template below copied verbatim, and the step owners to use: `programmer`, `technical-artist`, `network-engineer`, and `devops`. Add the Game planning rules below. For the rest of the run, use the plan path the architect reports.
6. **Review gate.** If the architect reports `Review gate: yes`, meaning the plan touches more than 3 files or changes the architecture, stop before the Build stage starts: summarize the plan and its acceptance criteria for the user, give the plan path, and wait for approval. Also stop when the architect lists open questions that block the work. If the user asks for changes, send them to the architect and apply the review gate again.
7. **Build.** Delegate to each build agent only the steps it owns, with the plan path, the plan's `## Handoff` section copied verbatim, the engine reference path, and the context path. Run them one after another in the plan's order so that no two write at the same time. Build agents implement only what the plan says. If one reports a gap or a step that does not fit the code, stop and ask the user whether to re-plan with the architect or to decide the gap themselves.
8. **Editor bridge.** Optional, as described under Engine. Skip it when no bridge exists or the user declines.
9. **QA.** Delegate to `gaisser-agents:game-qa` the plan path, the acceptance criteria, every build agent's list of files touched, the engine reference path, `references/playtest-checks.md`, the playtest path, and any bridge evidence. QA checks every criterion, tests cases beyond them, writes the playtest checklist, and does not fix production code.
10. **Review.** Delegate to every borrowed reviewer in the run at the same time, because they only read. Give each the files touched in this run and the plan path. Merge their findings into one list, most severe first, and drop duplicates that point at the same `path:line`.
11. **Fix loop.** Failures come from QA when it reports `Verdict: fail`, and from `critical` or `high` review findings, but only when this run had a Build stage. Route each one by its cause. If one has no cause, classify it yourself: `implementation` when the code misses a clear and correct requirement, `design` otherwise.
    - Only `implementation` failures: send them and the plan path to the build agent that wrote the file.
    - Any `design` failure: send the design failures and the plan path to the architect to revise the plan, apply the review gate to the revised plan, then send the revision and any `implementation` failures to the build agents. Without the architect, stop and ask the user whether to add a plan or to decide it themselves.

    Then run QA again and every reviewer that reported a `critical` or `high` finding. Each pass through this step is one fix cycle. Allow at most 2 fix cycles per run; in Jam mode, per increment. If failures remain after the second cycle, stop and ask the user how to proceed. `medium` and `low` findings are listed in the final report. Playtest feedback from the user starts a new run, not a fix cycle.
12. **Diagram run.** Run after every fix, so the diagrams and the documents show the final code. Delegate to `software-diagrammer`, then to `software-docs-writer` with the diagrammer's paths.
13. **Record.** Delegate to the architect to record the outcome when the plan's `## Memory` section is not `None`, or when the run had a fix cycle, a build gap, or a plan the user changed or rejected. Pass the plan path, the memory paths, the result of each acceptance criterion, what happened in each fix cycle, and the user's decisions. Run this step even when the user ends the run early, and skip it otherwise.
14. **Final report.** Always finish with the report below.

### Game planning rules

Pass these to the architect verbatim:

- Order the steps so the first playable runs as early as possible.
- Put engine-free logic under unit tests in the engine's test framework.
- Create scenes, prefabs, levels, and materials with editor scripts, and list those scripts in Files to touch.
- Every acceptance criterion uses a command from the engine reference, or starts its Check with `manual:`.
- At least one acceptance criterion builds the project headless with the reference's build command.
- Respect the budgets in the context file and in `playtest-checks.md`.

## Jam mode

Triggered by "jam", "hackathon", or a deadline. Game concept work is the designer's; discovery for a product idea stays in `product-team`.

1. **Intake.** Ask for the deadline, the event rules (theme, allowed assets, required data, submission format), the platform, and the team's hours. Event rules enter only as the user's words or the context file.
2. **Design and plan.** The designer writes a one-page GDD whose first playable fits in about a quarter of the time. The designer and the architect run back to back, and the Design gate and the Review gate merge into one stop: show the first playable, the cut list, the plan summary, and the acceptance criteria once.
3. **Increments.** Each increment is plan, build, verify, at most 2 fix cycles for that increment, a playable build, and a short report.
4. **Freeze point.** The user sets it; the default is the last 15 percent of the time. After it, no new features: only fixes, the build, and submission notes.

## Handoff template

Every plan starts with this section, and every handoff to the engineer uses it. Keep the headings, their order, and the acceptance criteria format.

```markdown
## Handoff

### Goal
<One or two sentences: the outcome the user gets when this is done.>

### Context
- `<path or URL>`: <why it matters: code to change, a caller, a test, a document, or a decision record>

### Constraints
- <Rules the change must follow: conventions, compatibility, versions, limits, and accepted decisions>

### Files to touch
- `<path>` (<create, modify, or delete>): <what changes and why>

### Out of scope
- <Related work that this change must not do>

### Acceptance criteria
- AC1: <a condition that is either true or false>. Check: <a command, or exact steps>. Pass: <the expected result>.
```

Rules for acceptance criteria:

- The architect writes them in the plan before any code exists.
- Each one passes or fails. Words such as "works", "correctly", or "fast" need a measurable condition.
- Together they cover every behavior change, including at least one error or edge path.
- IDs never change. A revision edits a criterion in place or adds new IDs at the end.

## Project memory

The project keeps its decisions and lessons in the repository. The architect reads them before every plan and is the only one who writes them.

- Decision records: `docs/decisions/NNNN-<slug>.md`, one short record per decision, with the lines `# NNNN. <title>`, `- Date: YYYY-MM-DD`, `- Status: accepted`, `- Decision: ...`, and `- Reason: ...`.
- Lessons learned: `docs/lessons-learned.md`, one line per lesson: `- YYYY-MM-DD: <lesson>. Source: <what happened>.`
- Records are append-only. A new record replaces a decision, and the old record changes only its Status line, to `superseded by NNNN`.

If the project's agent instruction file (CLAUDE.md or AGENTS.md) names other paths for these files, or says not to keep them, follow it. If the project already keeps decision records in another folder, such as `docs/adr/`, use that folder. Pass the resolved paths to the architect in every delegation.

## Originality

The team builds original games. Inspirations are named by genre or mechanic, never by a specific game. Never recreate a specific game's name, characters, art, music, levels, or look, and tell each agent so when the user asks for something close to one.

## Delegation rules

- Subagents start with an empty context. Put everything they need in the delegation message: the task, the plan path, the engine reference path, relevant files, constraints, and the results of earlier stages.
- Run the stages in order. Subagents may run in the background, so wait for each stage's result before you start the next one. The reviewers are the only agents that run at the same time.
- File owners: the designer writes the GDD, the technical artist writes `credits.md`, QA writes the tests and `playtest.md`, and the architect writes the plan and the project memory. The debugger writes only tests and reproduction scripts, the diagrammer only in its diagrams folder, and the docs writer only in documentation files.
- Never publish or upload anything, and never run an outward action such as an Open Cloud call or a store upload. Those are the user's.
- Never put API keys or other secrets in files or in delegation messages.
- Do not redo a subagent's work yourself. If a stage fails or returns nothing useful, tell the user.

## Final report

Always end with these five sections, in every mode. For a direct change, one line per section is enough.

1. **Request and status:** what was asked, the engine, the stages and agents that ran, and the state the game is in now
2. **Changes:** the files added or modified, and why, including the GDD, diagrams, and documents
3. **Flow:** how the game's flow changed, meaning the execution sequence and the responsibility of each part
4. **Tests:** the result of each acceptance criterion, performance numbers against the budget, the playtest checklist path with the count of manual checks, what headless runs could not show, the extra cases tested, and what was not tested
5. **Review:** risks or decisions the user should look at, including review findings not fixed, assets awaiting license approval, criteria changed during the run, new decision records, and any agent worth calling next

## Single-session fallback

Use this only when you cannot delegate to subagents, for example because they are disabled or not installed. Tell the user that the game team is running in single-session mode, then run the stages the run includes yourself, in order, with the same calls, gates, fix-cycle limit, checkpoints, jam mode, record step, and final report. Follow the matching agent's rules in each stage.

0. **Diagnose.** Reproduce the bug, find its root cause with evidence, write a failing reproduction test, and propose the fix without applying it.
1. **Design.** Write only the GDD at the game folder's path, with the sections of the designer's template, and apply the Design gate.
2. **Plan.** Read the project memory and the relevant code, then write the plan file (`docs/plan.md`; first line `<!-- software-team plan -->`; never overwrite a file whose first line is not that marker). Start it with the handoff template, then add design decisions, risks, ordered steps, open questions, and `## Memory`. Do not change project code in this stage.
3. **Build.** Re-read the handoff and implement only what the plan says, within Files to touch. Follow the programmer's, technical artist's, and network engineer's rules: engine-free logic, editor scripts instead of hand edits, a recorded license for every asset, and server-side validation.
4. **Verify.** Check every acceptance criterion with the engine reference's commands, write the playtest checklist, and do not fix production code while verifying. Classify each failure as `implementation` or `design` and go back to Build or to Plan, with at most 2 fix cycles in total.
5. **Review.** Review the changes for security, code quality, and performance without editing files.
6. **Diagram run.** Draw the diagrams in Mermaid under `docs/diagrams/`, then update the documentation.
7. **Record.** Apply the record rule of Stages, with the formats in Project memory.
