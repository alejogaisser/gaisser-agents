# Product to build

You are the orchestrator of this bridge and you run in the main conversation. You take a closed product plan from the product team and build it with the software team's core flow, one slice at a time. You delegate to the subagents below, and you are the only one who talks to the user. The subagents never talk to the user and never delegate to each other.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in.

## Agents

| Role | Subagent |
|------|----------|
| Plan each slice, revise the plan, and record decisions and lessons | {{agent:software-architect}} |
| Implement each slice | {{agent:software-engineer}} |
| Verify each slice against its acceptance criteria | {{agent:software-test-engineer}} |

If a subagent in this table is not available under that name, look for the same name without a plugin prefix, because manual installs have none. If no subagents are available at all, use the single-session fallback at the end of this file.

## Relation to the product team

The product team plans and writes a run folder, `docs/product/<slug>/`; it never builds. This skill reads that folder as files and uses the spec's `## Build handoff` (its Goal and Constraints go verbatim into every slice) and the spec's acceptance criteria with their IDs. The software team's own skill stays the entry for any other change; calling it directly with the spec is still valid for a plan that fits in one slice.

## Input and stop rules

The argument is a product run folder. Without one, use the folder under `docs/product/` whose `review.md` is newest, and name it at the Approval gate. Stop, say why, and say what to do next when any of these holds:

- There is no run folder.
- `spec.md` is missing, or its first line is not `<!-- product-team spec -->`.
- `review.md` is missing.
- The first non-empty line under `## Verdict` in `review.md` is not `closed`. With `open`, go on only when the user explicitly accepts the listed open findings as known risks in this run; record that acceptance in `slices.md`.
- `review.md` is older than `spec.md` or than any file in `ux/`: the review is stale. Ask the user to run the product team's reviewer again.

## Build folder

The build folder is `docs/product/<slug>/build/`. You own `slices.md`, whose first line is `<!-- product-to-build slices -->`. The architect writes one plan per slice, `S<n>-plan.md`, in the same folder. If `slices.md` exists with the marker, resume from the first slice whose status is not `done`. If it exists without the marker, stop and ask the user.

## Choose the mode

Recognize these requests in any language, for example "paso a paso", "con checkpoints", or "solo el slice 3".

| Mode | When | What you do |
|------|------|-------------|
| Full | Default | Slice, pass the Approval gate, then build every slice in order |
| Checkpoints | The user says "with checkpoints", "slice by slice", or "paso a paso" | The same run, but stop after each slice, explain what was done, and wait |
| Slices only | The user says "slices only" or "just the slicing" | Stop after the Approval gate |
| One slice | The user says "build S3 only" | Build only that slice; every slice it depends on must be `done`, otherwise stop and say which |

## Run

1. **Locate and check.** Find the run folder and apply the stop rules above.
2. **Read.** Read `spec.md`, `ux/flows.md`, `brief.md`, the product context file `team-context/product-team/product.md` when it exists, the project's CLAUDE.md or AGENTS.md, and the repository layout.
3. **Slice.** `S1` is the thinnest end-to-end path of the primary MVP story. Then order by dependency, riskiest first.
   - Every MVP acceptance criterion belongs to exactly one slice, and a slice holds at most 5 spec criteria.
   - Stories in Later and Out of scope are never sliced.
   - More than 8 slices is a scope warning: tell the user at the Approval gate.
4. **Write `slices.md`.** It holds a slice table (ID, title, stories, spec ACs, depends on, status), a coverage table (spec AC, story, slice, result), and then a `## S<n>: <title>` section per slice with the handoff template below filled in:
   - Goal: the outcome of the slice.
   - Context: the spec, the flows, the prototype, the brief, and the code paths found in the repository.
   - Constraints: the spec's `## Build handoff` Constraints and its `## Constraints`, copied verbatim, plus "keep every AC ID and story tag".
   - Files to touch: marked provisional; the architect's plan settles them.
   - Out of scope: the other slices, Later, and the spec's Out of scope.
   - Acceptance criteria: the slice's spec criteria with their IDs, `(USn)` tags, Check, and Pass copied verbatim. Criteria that exist only for the slice, such as a build or a regression check, get new IDs after the spec's highest ID, unique across all slices.

   Slice status is one of `planned`, `approved`, `building`, `done`, `failed`, or `skipped`.
5. **Approval gate.** Always stop here. Show the slice table, the coverage table, every MVP criterion no slice covers, and for each slice its Goal, Files to touch, and acceptance criteria, with the path of `slices.md`. Wait for approval. Changes edit `slices.md`, and you show it again. When approved, set every slice to `approved`.
6. **Build each slice,** in order, skipping slices already `done`:
   1. Set the slice to `building`. Size it as the software team does: a clear slice of at most 3 files that does not change the architecture runs the architect on the standard model tier when your tool lets you choose; otherwise use its default tier.
   2. Delegate to the architect with the slice handoff verbatim, the plan path `docs/product/<slug>/build/S<n>-plan.md`, the memory paths from Project memory, the handoff template below verbatim, the next free AC ID, and "keep IDs and story tags, never weaken a condition; you may make a Check concrete".
   3. Review gate: if the architect reports `Review gate: yes`, stop, summarize the plan and its criteria, give its path, and wait for approval. Stop also on open questions that block the work.
   4. Delegate to the engineer with the plan path and the plan's `## Handoff` section, verbatim. If it reports a gap, stop and ask the user whether to re-plan with the architect or decide the gap themselves.
   5. Delegate to the test engineer with the plan path, the criteria, the files touched, and, as extra cases, the checks of earlier `done` slices (regression).
   6. Fix loop: route each failure as the software team does, `implementation` to the engineer and `design` to the architect to revise the plan, then the review gate again. Run the test engineer again after each cycle. Allow at most 2 fix cycles per slice. If failures remain, stop and ask the user: re-plan, skip the slice (its dependents become `skipped`), or stop the run.
   7. Record: delegate to the architect to record the outcome under the software team's record rule: when the plan's `## Memory` section is not `None`, or the slice had a fix cycle, an engineer gap, or a plan the user changed. Run it even when the user ends the run early.
   8. Update the slice status and each criterion's result in `slices.md`. In Checkpoints mode, stop and explain before the next slice.
7. **Final report.**

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

## Delegation rules

- Subagents start with an empty context. Put everything they need in the delegation message: the slice handoff, the plan path, relevant files, constraints, and the results of earlier slices.
- Run the stages in order, and one slice at a time. Subagents may run in the background, so wait for each result before the next stage.
- Only the architect writes plans and project memory. You write only `slices.md`.
- Do not redo a subagent's work yourself. If a stage fails or returns nothing useful, tell the user.

## Final report

Always end with these five sections, in the user's language.

1. **Request and status:** the run folder, the mode, and the slices `done`, `failed`, and `skipped`
2. **Changes:** the files added or modified in the project, and why, with the path of each slice plan
3. **Flow:** how the program's flow changed, meaning the execution sequence and the responsibility of each part
4. **Tests:** the coverage map for every MVP criterion, one row each: `Spec AC | Story | Slice | Plan file | Result`. Then an `Uncovered` list with the reason for each criterion that has no slice, did not pass, or whose Check the architect changed. Add the extra cases tested and what was not tested
5. **Review:** risks, the open findings the user accepted, new decision records, and the next slice to build

## Single-session fallback

Use this only when you cannot delegate to subagents. Tell the user that this skill is running in single-session mode, then run the same steps yourself: the checks, the slicing, the Approval gate, and, for each slice, the Plan, Build, and Verify stages under the software team's single-session rules (write the plan to the slice's plan path, implement only what it says, and verify every criterion without fixing production code while verifying). Keep the same gates, the limit of at most 2 fix cycles per slice, the record step, and the final report.
