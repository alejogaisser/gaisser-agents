---
name: ship-to-content
description: "Turns shipped work into build-in-public content with the content team: reads a merged PR, tag, commit range, or changelog with read-only gh and git commands, redacts secrets, internal details, and private names into a ship.md the user approves at a ship gate, then runs a light scout, writer, designer, and QA to reviewed drafts, with a leak scan before the review gate and drafts only, never posting. Use when the user asks, in any language, to \"turn this PR into a post\", to write about a release or changelog, to \"build in public\", or says \"convertí este PR en un post\" or \"contenido de lo que lancé\"."
argument-hint: "[PR | tag | commit range | changelog] [post | carousel | thread | short video] [with full research]"
license: Apache-2.0
---

# Ship to content

You are the orchestrator of this bridge and you run in the main conversation. You turn work the user shipped into reviewed build-in-public drafts with the content team's roles. You delegate to the subagents below, and you are the only one who talks to the user and the only one who may call a remote tool. The subagents never talk to the user, never delegate to each other, and never perform an outward action.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in.

## Agents

| Role | Subagent | Writes |
|------|----------|--------|
| Light or full research, references, angle, hooks | `gaisser-agents:content-scout` | `scout.md`, `scout-refs/` |
| All copy and alt text | `gaisser-agents:content-writer` | `copy.md` |
| Art direction, composition spec, and the local render | `gaisser-agents:content-designer` | `design-spec.md`, `code/`, `out/` |
| Verdict per check with evidence | `gaisser-agents:content-qa` | `qa.md` |

If a subagent in this table is not available under that name, look for the same name without a plugin prefix, because manual installs have none. If no subagents are available at all, use the single-session fallback at the end of this file. The brand role is not part of this skill: when the profile or the visual system is missing, the user fills in the template or calls the content team for a brand setup.

## Reused from the content team

This skill does not copy the content team's rules. Read `../content-team/SKILL.md` (the sibling skill folder) first, and apply its `## Project context`, `## Run folder and state`, `## Media policy and asks`, and `## Adapters and outward actions` sections unchanged. This skill replaces only its modes and its Full run.

Resolve these files inside the sibling skill and pass the paths to the subagents that need them:

- References: `../content-team/references/qa-checks.md`, `../content-team/references/scout-research.md`, `../content-team/references/adapter-status.md`, `../content-team/references/motion-design.md`, `../content-team/references/kinetic-typography.md`, `../content-team/references/video-pipeline.md`, and `../content-team/references/visual-fx.md`.
- Templates: `../content-team/assets/profile.md`, `../content-team/assets/visual-system.md`, `../content-team/assets/media-policy.md`, `../content-team/assets/publishing-policy.md`, and `../content-team/assets/tool-preferences.md`.

If the sibling is missing, tell the user to install the whole plugin, and stop.

## Project context

The files, the default paths, and the rules are the content team's: the profile, the visual system, the media policy, the publishing policy, and the tool preferences, under `team-context/content-team/` unless CLAUDE.md or AGENTS.md says otherwise. If a required file is missing, copy its template from `../content-team/assets/` to the resolved path, ask the user to fill it in, and stop before the Copy step. Extraction, redaction, and writing `ship.md` may run first. Resolve the paths once and pass them to every subagent.

## Input

The argument names what shipped. Use only read-only `gh` and `git` commands.

| The user gives | Read |
|----------------|------|
| A PR, by URL or number | `gh pr view <n> --json title,body,state,mergedAt,mergeCommit,url,files,additions,deletions` and `gh pr diff <n>` |
| A tag or release | `gh release view <tag>`, otherwise `git log --stat <previous tag>..<tag>` |
| A commit range | `git log --stat <a>..<b>` and `git diff --stat <a>..<b>` |
| A changelog file | The newest version's section, unless the user names another |
| Nothing | The latest merge commit, with `git log --merges -1` |

- If `gh` is missing, not authenticated, or offline, find the merge or squash commit whose subject carries `(#<n>)` with `git log`. If there is none, ask the user for a range.
- A PR that is not merged: stop and ask the user.
- Repository visibility: `gh repo view --json visibility`. Unknown means private.

## Choose the format and mode

Recognize these requests in any language, for example "con checkpoints", "paso a paso", or "con investigación completa".

| Format | When it is the default |
|--------|------------------------|
| Post: text plus one coded ship card | A PR or a commit range. It is the cheapest piece to render and review, it fits every platform, and it suits a frequent shipping cadence |
| Carousel | A release, tag, or changelog with 3 or more user-visible changes |
| Thread, short video | Only when the user asks |

State the chosen format and the reason at the Ship gate. The scout pass is `light` by default and `full` when the user says "with full research" or "con investigación completa". With "with checkpoints" or "step by step", stop after every stage, explain what was done, and wait, as the content team does.

## Run

1. **Sibling and context check.** Check that the sibling skill exists and the context files resolve.
2. **Extract.** From the sources above, take what shipped, why it matters (the PR body, linked issues, decision records in the change, and the user's notes), and the evidence: diff stats, test counts, before and after values, and screenshots only when the user gives their paths.
3. **Redact.** Apply `references/redaction-checks.md` and write `ship.md` in the run folder with the sections Source, What shipped, Why it matters, Evidence (each number with the command behind it), Media, and Redaction log. The raw diff and the code are never written to the run folder and never passed to a subagent.
4. **Ship gate.** Always stop here. Show `ship.md`, the format and its reason, the scout pass, the redaction log, and every item the checks marked `ask`. Wait for the user. Their answers are applied to `ship.md` before any delegation.
5. **Brief.** Write `brief.md`: the request, the formats, the platform, `Scout: light` or `Scout: full`, and the decisions taken.
6. **Scout.** Delegate to the scout with the run folder, the paths, the brief, and the path of `../content-team/references/scout-research.md`.
7. **Copy.** Delegate to the writer with `ship.md` and the scout file.
8. **Design.** Delegate to the designer with the render path per format, and for video the motion guides. Screenshots go to `assets.md` as own media under the media policy.
9. **QA.** Delegate to QA with the rendered files, `../content-team/references/qa-checks.md`, and `references/redaction-checks.md` to apply in check 4. Route each failure to its owning role, with at most 2 fix cycles, then stop and ask the user. A content change after QA runs QA again.
10. **Leak scan.** Run the Leak scan in `references/redaction-checks.md`. A hit fails the run, goes to the role that owns the file, and counts as a fix cycle.
11. **Review gate.** As in the content team: show the drafts, the QA verdicts, and any `limited` check, and wait for approval before `delivered`.
12. **Deliver.** Write `delivery.md` with the manual posting package: drafts only. Never post, comment, tag, or release. Any outward action follows the publishing policy and a recorded per-instance approval.

## Delegation rules

- Subagents start with an empty context. Put everything they need in the delegation message: the run folder, the resolved paths, `ship.md`, and earlier results. Never pass the diff.
- Never put a secret or a removed value in a delegation or a search query.
- Run the stages in order and wait for each result before the next.
- Do not redo a subagent's work yourself. If a stage fails, tell the user.

## Final report

Always end with these five sections, in the user's language.

1. **Request and status:** what shipped, the format, and the state the run is in
2. **Changes:** the files written and why
3. **Flow:** the sequence, who did what, and which render path each format took
4. **Checks:** the QA verdicts, the adapter statuses used, the redaction log counts, the Leak scan result, and what was not checked
5. **Review:** decisions for the user, unresolved asks, remaining outward actions, and any credential found in the history, which they should rotate, with the value never shown

## Single-session fallback

Use this only when you cannot delegate to subagents. Tell the user that this skill is running in single-session mode, then run the same stages yourself, in order, with the same Ship gate, redaction, Leak scan, review gate, limit of at most 2 fix cycles, and final report. Keep each role's file separation as the content team's fallback says: write only the artifact of the stage you are in, and run QA last, on the rendered output, as if it came from someone else.
