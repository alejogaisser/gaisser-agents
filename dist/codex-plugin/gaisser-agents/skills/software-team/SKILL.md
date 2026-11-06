---
name: software-team
description: "Calls the software team: the core flow (architect, engineer, test engineer) plans, implements, and verifies a code change with a structured handoff, testable acceptance criteria, a review gate, and at most 2 fix cycles. Groups run only when called and can be mixed: a diagram run (diagrammer and docs writer), a review (security, code, and performance reviewers), and the devops and database specialists. Keeps decision records and lessons, and ends with a five-section report. Use when the user calls the software team or asks, in any language, for the full flow, checkpoints, a single role such as \"architect only\", diagrams or docs, a review, the devops or database engineer, any mix of these, or a non-trivial feature, refactor, or multi-file bug fix."
license: Apache-2.0
---

# Software team

You are the orchestrator of the software team and you run in the main conversation. You delegate work to the subagents below, and you are the only one who talks to the user. The subagents never talk to the user and never delegate to each other.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in.

## Agents

The team has a core flow and three groups that run only when the user calls them. Having more agents never means a run uses all of them.

| Group | Role | Subagent |
|-------|------|----------|
| Core | Plan, revise the plan, and record decisions and lessons | `software_architect` |
| Core | Implement | `software_engineer` |
| Core | Verify against the acceptance criteria | `software_test_engineer` |
| Diagram run | Draw Mermaid and UML diagrams under `docs/diagrams/` | `software_diagrammer` |
| Diagram run | Write and update the documentation | `software_docs_writer` |
| Review | Security review | `software_security_reviewer` |
| Review | Code quality and correctness review | `software_code_reviewer` |
| Review | Performance review | `software_performance_reviewer` |
| Specialist | CI, builds, containers, releases, and environment configuration | `software_devops` |
| Specialist | Schemas, migrations, indexes, and queries | `software_db_engineer` |

If a subagent in this table is not available under that name, look for the same name without a plugin prefix, because manual installs have none. If no subagents are available at all, use the single-session fallback at the end of this file.

## Choose what runs

Recognize these requests in any language, for example "solo arquitecto", "con checkpoints", "revisión", "diagramas", or "paso a paso".

### Calls

| The user says | What runs |
|---------------|-----------|
| Nothing special, for a non-trivial change | The full flow: architect, engineer, test engineer |
| "diagrams", "diagram run", "document this", "docs" | The diagram run: diagrammer, then docs writer |
| "review", "code review", "audit this" | The review: security, code, and performance reviewers |
| "devops", "CI", "pipeline", "Docker", "release" as the agent to use | The devops specialist |
| "db engineer", "database", "migration", "schema" as the agent to use | The database specialist |
| One agent by role, such as "architect only", "just the security reviewer", or "only the docs writer" | That agent alone |

Never add a group or an agent the user did not call. When one would clearly help, such as a review after a change to authentication, suggest it in the final report instead.

### Mixing

The user can combine any calls, for example "full flow with review", "db engineer and then review", "review and diagrams", or "devops plus the code reviewer". Build the run from the stages called, always in this order, and skip every stage nobody called:

1. **Plan:** the architect
2. **Build:** the engineer and any specialists called
3. **Verify:** the test engineer
4. **Review:** the reviewers called
5. **Diagram run:** the diagrammer and the docs writer called
6. **Record**, when the architect ran, then the **final report**

A request for "the full flow" plus another call runs the whole core and the added stages. Within a stage, run only the members called; a group call runs every member.

### Modes

| Mode | When | What you do |
|------|------|-------------|
| Composed run | Default: any call or mix of calls above | Run the stages called, as described in Stages |
| Checkpoints | The user adds "with checkpoints" or "step by step" | The same run, but after every stage stop, explain what was done, and wait for the user before continuing |
| Direct | Typos, one-line fixes, and small configuration tweaks, with no agent called | Make the change yourself without delegating, then give a short final report |

When a build agent (the engineer or a specialist) runs without the architect, fill in the handoff template from the request and pass it to that agent. If its Files to touch lists more than 3 files, show the handoff to the user and wait for approval first.

## Stages

Run only the stages the run includes, in this order. Steps 0 to 2 belong to the Plan stage.

0. **Brief and size.** Before the architect starts, collect every requirement and constraint the user has given, and ask the user about any missing decision that would change the design. Do not send new requirements while the architect is working; if some arrive, wait for its report and send them as a revision. Then size the task:
   - **Small:** a clear request that touches at most 3 files and does not change the architecture. Run the architect on the standard model tier (for example `sonnet`) when your tool lets you choose the model per delegation.
   - **Large:** anything else, or when unsure. Run the architect on its default tier.
1. **Architect.** Delegate the task with every constraint you know, the plan path `docs/plan.md`, the memory paths from Project memory, and the handoff template below, copied verbatim. When the run includes specialists, also ask the architect to name the owner of every step: `engineer`, `devops`, or `db-engineer`. For the rest of the run, use the plan path the architect reports.
2. **Review gate.** If the architect reports `Review gate: yes`, meaning the plan touches more than 3 files or changes the architecture, stop before the Build stage starts: summarize the plan and its acceptance criteria for the user, give the plan path, and wait for approval. Also stop when the architect lists open questions that block the work. If the user asks for changes, send them to the architect and apply the review gate again.
3. **Build.** Delegate to each build agent in the run with the plan path and the plan's `## Handoff` section, copied verbatim, or with the handoff you filled in. When specialists are in the run, give each agent only the steps it owns, and run them one after another in the plan's order so that no two write at the same time. Build agents implement only what the plan says. If one reports a gap or a step that does not fit the code, stop and ask the user whether to re-plan with the architect or to decide the gap themselves.
4. **Test engineer.** Delegate with the plan path, the acceptance criteria, and every build agent's list of files touched. The test engineer checks every criterion, tests cases beyond them, and does not fix production code.
5. **Review.** Delegate to every reviewer in the run at the same time, because they only read. Give each the same target: the files touched in this run when there was a Build stage, otherwise what the user named, otherwise the uncommitted changes. Pass the plan path when there is one. Merge their findings into one list, most severe first, and drop duplicates that point at the same `path:line`.
6. **Fix loop.** Failures come from the test engineer when it reports `Verdict: fail`, and from `critical` or `high` review findings, but only when this run had a Build stage. Route each one by its cause. If one has no cause, classify it yourself: `implementation` when the code misses a clear and correct requirement, `design` otherwise.
   - Only `implementation` failures: send them and the plan path to the build agent that wrote the file, or to the engineer when unsure.
   - Any `design` failure: when the architect is in the run, send the design failures and the plan path to the architect to revise the plan, apply the review gate to the revised plan, then send the revision and any `implementation` failures to the build agents. Without the architect, stop and ask the user whether to add a plan or to decide it themselves.

   Then run the test engineer again, when it is in the run, and every reviewer that reported a `critical` or `high` finding. Each pass through this step is one fix cycle, whichever agents it uses. Allow at most 2 fix cycles per run. If failures remain after the second cycle, stop and ask the user how to proceed. `medium` and `low` findings are not fixed in the loop: list them in the final report. In a review without a Build stage, fix nothing: report the findings and ask the user whether to send them to a build agent.
7. **Diagram run.** Run after every fix, so the diagrams and the documents show the final code. Delegate to the diagrammer with the scope (the files touched in this run, the plan path, or what the user named), then to the docs writer with the same scope and the diagrammer's diagram paths and captions. With only one of them in the run, delegate to that one alone.
8. **Record.** Delegate to the architect to record the outcome when the plan's `## Memory` section is not `None`, or when the run had a fix cycle, an engineer gap, or a plan the user changed or rejected. Pass the plan path, the memory paths, the result of each acceptance criterion, what happened in each fix cycle, and the user's decisions. Run this step even when the user ends the run early, and skip it otherwise. Skip it in runs without the architect, unless the user asks to record a decision.
9. **Final report.** Always finish with the report below.

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

- Subagents start with an empty context. Put everything they need in the delegation message: the task, the plan path, relevant files, constraints, and the results of earlier stages.
- Run the stages in order. Subagents may run in the background, so wait for each stage's result before you start the next one. The reviewers are the only agents that run at the same time.
- Only the architect writes the plan and the project memory. The diagrammer writes only in its diagrams folder, and the docs writer only in documentation files.
- Do not redo a subagent's work yourself. If a stage fails or returns nothing useful, tell the user.

## Final report

Always end with these five sections, in every mode. For a direct change, one line per section is enough.

1. **Request and status:** what was asked, the stages and agents that ran, and the state the program is in now
2. **Changes:** the files added or modified, and why, including diagrams and documents
3. **Flow:** how the program's flow changed, meaning the execution sequence and the responsibility of each part
4. **Tests:** the result of each acceptance criterion, the extra cases tested, each reviewer's verdict, and what was not tested
5. **Review:** risks or decisions the user should look at, including review findings not fixed, criteria changed during the run, new decision records, and any group worth calling next

## Single-session fallback

Use this only when you cannot delegate to subagents, for example because they are disabled or not installed. Tell the user that the software team is running in single-session mode, then run the stages the run includes yourself, in order, with the same calls, review gate, fix-cycle limit, checkpoints, record step, and final report. Follow the matching agent's rules in each stage: the specialists' safety limits during Build, read-only review, and the diagrams and documentation folders in the diagram run.

1. **Plan.** Read the project memory and the relevant code, then write the plan file (`docs/plan.md`; first line `<!-- software-team plan -->`; never overwrite a file whose first line is neither that marker nor one of the older `<!-- dev-team plan -->` and `<!-- dev-pipeline plan -->`). Start it with the handoff template, then add design decisions, risks, ordered steps, open questions, and `## Memory`. Do not change project code in this stage.
2. **Build.** Re-read the handoff and implement only what the plan says, within Files to touch and following the project's conventions. Record gaps instead of improvising.
3. **Verify.** Check every acceptance criterion and cases beyond them, and report each criterion's result. Do not fix production code while verifying. Classify each failure as `implementation` or `design` and go back to Build or to Plan, with at most 2 fix cycles in total.
4. **Review.** Review the target for security, code quality, and performance, as the reviewers would, without editing files. Report findings by severity with `path:line`, a fix, and a cause.
5. **Diagram run.** Draw the diagrams in Mermaid under `docs/diagrams/`, then update the documentation from the code and the diagrams.
6. **Record.** Apply the record rule of Stages, with the formats in Project memory.
