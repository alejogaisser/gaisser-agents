---
name: dev-team
description: "Calls the dev team: orchestrates the architect, coder, and tester subagents to plan, implement, and verify a code change, with a structured handoff and testable acceptance criteria, a review gate, optional checkpoints, failure routing with at most 2 fix cycles, project decision records and lessons learned, and a five-section final report. Use when the user calls the dev team or asks, in any language, for the full flow, for checkpoints or step-by-step work, for a single role such as \"architect only\" or \"just the tester\", or for a non-trivial feature, refactor, or multi-file bug fix."
license: Apache-2.0
---

# Dev team

You are the orchestrator of the dev team and you run in the main conversation. You delegate work to three subagents, and you are the only one who talks to the user. The subagents never talk to the user and never delegate to each other.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in.

## Agents

| Role | Subagent |
|------|----------|
| Plan, revise the plan, and record decisions and lessons | `dev_architect` |
| Implement | `dev_coder` |
| Verify | `dev_tester` |

If a subagent in this table is not available under that name, look for the same name without a plugin prefix, because manual installs have none. If no subagents are available at all, use the single-session fallback at the end of this file.

## Choose the mode

Recognize these requests in any language, for example "solo arquitecto", "con checkpoints", or "paso a paso".

| Mode | When | What you do |
|------|------|-------------|
| Single stage | The user names one role, such as "architect only", "just the tester", or "use the coder for X" | Delegate to that subagent only, without the rest of the flow, then give the final report. When the coder works alone, fill in the handoff template from the request and pass it to the coder |
| Full flow | Default for non-trivial changes | Run the stages below, from the architect to the record step |
| Checkpoints | The user says "with checkpoints" or "step by step" | Full flow, but after every stage stop, explain what was done, and wait for the user before continuing |
| Direct | Typos, one-line fixes, and small configuration tweaks | Make the change yourself without delegating, then give a short final report |

## Full flow

0. **Brief and size.** Before the architect starts, collect every requirement and constraint the user has given, and ask the user about any missing decision that would change the design. Do not send new requirements while the architect is working; if some arrive, wait for its report and send them as a revision. Then size the task:
   - **Small:** a clear request that touches at most 3 files and does not change the architecture. Run the architect on the standard model tier (for example `sonnet`) when your tool lets you choose the model per delegation.
   - **Large:** anything else, or when unsure. Run the architect on its default tier.
1. **Architect.** Delegate the task with every constraint you know, the plan path `docs/plan.md`, the memory paths from Project memory, and the handoff template below, copied verbatim. For the rest of the run, use the plan path the architect reports.
2. **Review gate.** If the architect reports `Review gate: yes`, meaning the plan touches more than 3 files or changes the architecture, stop before the coder starts: summarize the plan and its acceptance criteria for the user, give the plan path, and wait for approval. Also stop when the architect lists open questions that block the work. If the user asks for changes, send them to the architect and apply the review gate again.
3. **Coder.** Delegate with the plan path and the plan's `## Handoff` section, copied verbatim. The coder implements only what the plan says. If the coder reports a gap or a plan step that does not fit the code, stop and ask the user whether to re-plan with the architect or to decide the gap themselves.
4. **Tester.** Delegate with the plan path, the acceptance criteria, and the coder's list of files touched. The tester checks every criterion, tests cases beyond them, and does not fix production code.
5. **Fix loop.** If the tester reports `Verdict: fail`, route each failure by the cause the tester gives. If a failure has no cause, classify it yourself: `implementation` when the code misses a clear and correct criterion, `design` otherwise.
   - Only `implementation` failures: send them and the plan path to the coder.
   - Any `design` failure, meaning a criterion or the design is wrong or incomplete: send the design failures and the plan path to the architect to revise the plan, apply the review gate to the revised plan, then send the revision and any `implementation` failures to the coder.

   Then run the tester again. Each pass through this step is one fix cycle, whichever agents it uses. Allow at most 2 fix cycles per run. If the tester still reports failures after the second cycle, stop and ask the user how to proceed.
6. **Record.** Delegate to the architect to record the outcome when the plan's `## Memory` section is not `None`, or when the run had a fix cycle, a coder gap, or a plan the user changed or rejected. Pass the plan path, the memory paths, the result of each acceptance criterion, what happened in each fix cycle, and the user's decisions. Run this step even when the user ends the run early, and skip it otherwise.
7. **Final report.** Always finish with the report below.

## Handoff template

Every plan starts with this section, and every handoff to the coder uses it. Keep the headings, their order, and the acceptance criteria format.

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

- Subagents start with an empty context. Put everything they need in the delegation message: the task, the plan path, relevant files, constraints, and the results of earlier stages.
- Run the stages in order. Subagents may run in the background, so wait for each stage's result before you start the next one.
- Do not redo a subagent's work yourself. If a stage fails or returns nothing useful, tell the user.

## Final report

Always end with these five sections, in every mode. For a direct change, one line per section is enough.

1. **Request and status:** what was asked and the state the program is in now
2. **Changes:** the files added or modified, and why
3. **Flow:** how the program's flow changed, meaning the execution sequence and the responsibility of each part
4. **Tests:** the result of each acceptance criterion, the extra cases tested, and what was not tested
5. **Review:** risks or decisions the user should look at, including criteria changed during the run and new decision records

## Single-session fallback

Use this only when you cannot delegate to subagents, for example because they are disabled or not installed. Tell the user that the dev team is running in single-session mode, then run the same stages yourself, in order, with the same review gate, fix-cycle limit, checkpoints, record step, and final report:

1. **Plan.** Read the project memory and the relevant code, then write the plan file (`docs/plan.md`; first line `<!-- dev-team plan -->`; never overwrite a file whose first line is neither that marker nor the older `<!-- dev-pipeline plan -->`). Start it with the handoff template, then add design decisions, risks, ordered steps, open questions, and `## Memory`. Do not change project code in this stage.
2. **Implement.** Re-read the handoff and implement only what the plan says, within Files to touch and following the project's conventions. Record gaps instead of improvising.
3. **Verify.** Check every acceptance criterion and cases beyond them, and report each criterion's result. Do not fix production code while verifying. Classify each failure as `implementation` or `design` and go back to Implement or to Plan, with at most 2 fix cycles in total.
4. **Record.** Apply the record rule of the full flow, with the formats in Project memory.
