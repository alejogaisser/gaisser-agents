# Content team: Claude collaboration handoff

- Date: 2026-10-03.
- State: proposal, architecture only. The user is working on architecture until they explicitly approve moving beyond it.
- This is a handoff document for the user to give Claude. No message was sent to another chat or external service.
- Read first: [architecture](plan-content-team.md), [integration survey](content-team-integrations.md), [design system](content-team-design-system.md).
- Historical inputs: [earlier research](research-content-team.md), [existing repository plan](plan.md), [contribution contracts](../CONTRIBUTING.md), [per-team targets ADR](decisions/0004-per-team-tool-targets.md).

## 1. User request and authority

Research possible app connections, especially Canva, CapCut, Adobe and Higgsfield, and the ability to code videos and photos. Design a content-creation team and an aesthetic/performance architecture for videos and carousels. Claude also works on the project, so the output must support joint review.

Authorized now: research and architecture documents. Not authorized by this request: implementing team prompts, changing the catalog/build/installer, installing plugins/runtimes, connecting accounts, generating paid media, scheduling/publishing, committing or pushing.

Approval of a style recipe or architecture section is not permission to publish content. Approval to implement must produce a separate concrete implementation handoff with files and acceptance criteria.

## 2. Ownership and collision protocol

Codex created these four NEW files for this planning phase:
- docs/plan-content-team.md: architect-owned plan and proposed contracts.
- docs/content-team-design-system.md: architect-owned visual recipes and measurement design.
- docs/content-team-integrations.md: primary-source integration research and availability boundaries.
- docs/content-team-claude-handoff.md: this joint-review map.

Existing docs/plan.md and docs/research-content-team.md were preserved. Existing accepted ADRs and lessons were preserved. There is no new accepted ADR from this phase.

Claude should first check git status and read the current versions; do not assume the baseline remained unchanged while Codex worked. Put the first review in a separate new docs/content-team-review.md, or in a file the user chooses, instead of overwriting active work. Record disagreements by decision ID, source, consequence and alternative.

After the user selects a decision, one owner edits the canonical document. The other reviews the diff. Never reset, checkout, clean, overwrite or delete another contributor's work to make a review tidy. Keep proposed decisions visibly proposed until the user accepts them.

For later production runs, use unique content/run IDs, explicit file owners and immutable artifact revisions. Two agents or clients must not mutate the same remote editing transaction or publishing job concurrently.

## 3. Proposed direction

A vendor-neutral content-team, with shared briefs/assets/storyboards and local rendering, plus optional app-specific adapters. Reusable brand context stays outside the public plugin. Research-backed recommendations remain separate from hypotheses about aesthetic or reach.

Proposed six roles:
- content-researcher: sourced observations and trend/reference evidence.
- content-strategist: audience, objective, format and experiment selection.
- content-writer: script, exact copy, hooks, captions and claims.
- content-designer: layout/motion specifications and style tokens.
- content-renderer: approved local assets and export builds.
- content-qa: independent technical, visual, factual and rights review.

The main conversation runs orchestration and user interaction. It resolves client-specific tools and performs authorized external operations. Roles emit artifacts without hard-coded provider names. Missing apps should produce a documented capability gap/fallback, not a hidden substitute.

The proposed plan targets both Claude Code and Codex, subject to user approval. Existing contribution docs forecast a Claude-only content-team; accepted ADR 0004 supplies the per-team targets mechanism. Expanding content scope needs an explicit reviewed decision, not silently rewriting repository history.

## 4. Decision ledger for review

These are review subjects, not accepted decisions. The architecture plan supplies its own detailed proposed decision records.

| ID | Proposal | Why / what Claude should challenge |
|---|---|---|
| R1 | Use content-team as plugin/entry name and content- agent prefix | Fits repository rules; historical content-studio proposal does not match current -team naming contract. |
| R2 | Portable neutral core with optional Claude/Codex adapters | Both can author local files/code; actual connectors/auth remain client-specific. |
| R3 | Local specification + asset manifest is source of truth | Easier reproducibility/vendor switching; quantify migration costs when editor-only features are required. |
| R4 | Start with SVG/HTML stills and FFmpeg montage; choose one richer motion renderer when needed | Remotion is a candidate for React/shared stills; HyperFrames is a documented alternative. Inspect runtime/license/preview/export before choosing; backend selection remains open. |
| R5 | Canva is first editable-design adapter | Installed tools visible in Codex; determine Claude tool exposure separately. |
| R6 | Generative media is a per-brand option | Historical personal workflow forbids AI images. Keep it strict there unless the user changes it; do not make that personal rule universal or override it by installing Higgsfield. |
| R7 | External actions owned by main-session broker | Avoid all-tools subagents; prompt instructions alone are not security enforcement. |
| R8 | Style recipes are configurable hypotheses | User-approved brand identity plus hook/pace experiments; no virality claim without observed evidence. |
| R9 | Publishing is optional and separate | Account scopes, approval, destination and visibility form a different workflow. |
| R10 | Document/file handoffs before proprietary project generation | Preserve source/exports; promise native editability only after an import/export fixture proves it. |

## 5. Differences from the older research

| Earlier position | Current evidence or proposed correction | Architecture consequence |
|---|---|---|
| Content mainly for Claude Code / Chrome | Canva/Figma/Higgsfield tools exposed to current Codex session; no account round-trip tested | Core should not require Chrome. Preserve per-client capabilities and historical target decision until reviewed. |
| Canva Autofill reserved for Enterprise | Official Sep 23 2026 announcement/current reference says eligible Pro+; directory text still says Enterprise | Resolve actual entitlement via later probe and record date. |
| Descript only mainstream editor with official agent path | Adobe Premiere has desktop UXP; Figma/Canva have native authoring; VEED has model API/OpenEdit route | Distinguish editor automation, generation and cloud transformations. Descript's transcript workflow is still useful. |
| No AI images as team-wide default | Documented personal brand constraint, not an explicit generic team requirement in this request | Brand policy can forbid it. Optional generator adapter must honor that policy. |
| Browser automation or desktop control assumed | Current session native computer APIs disabled; client's browser/desktop integration differs | Use documented SDK/CLI or file fallback; no parity assumptions. |
| Plugin hooks/MCP packaging needed | Existing neutral build supports agents, entry skill and text assets/references; broker can resolve session tools | Avoid build changes unless a later concrete requirement and approved plan justify them. |
| Old API/pricing/model inventory | API surfaces change: Buffer current API, Sora retired, Adobe migrations, Luma current docs | Use dated capability profiles; no fixed price/model guarantees. |

See [integration research](content-team-integrations.md) for the vendor sources. Old research remains useful evidence, but a copied claim is not fresh verification.

## 6. Review checklist

- Does each artifact have a producer, consumer, schema/version, owner and invalidation rule?
- Does changing script copy invalidate only dependent layout/render/QA revisions?
- Can a denied API entitlement finish as a local export or clearly marked manual handoff?
- Are paid submission, retry, timeout, resume and unknown job outcome distinct?
- Does publishing bind approval to destination, content revision/hash, visibility and time?
- Is remote export/publication in Descript explicitly distinguished from social publishing?
- Can strict real-media brands prevent generator invocation while allowing diagrams/transcription?
- Are exact text/font/layout exports checked at full resolution and phone size?
- Are video QA frame checks paired with audio/playback review instead of falsely proving temporal quality?
- Is “viral” evaluation format/platform/audience-specific with baselines and missing-data handling?
- Do proposed prompts/tool capabilities satisfy CONTRIBUTING and preserve dev-team output?
- Are personal assets, secrets, channel IDs and font files excluded from the public catalog?
- Are Claude and Codex tool differences resolved by adapters without duplicated brand rules?

Report each issue as design, evidence, implementation feasibility, or preference. There is no implementation to test yet.

## 7. Copyable request to Claude

> Review the content-team architecture only. Read docs/plan-content-team.md, docs/content-team-integrations.md, docs/content-team-design-system.md and docs/content-team-claude-handoff.md, then compare them with CONTRIBUTING.md, docs/plan.md, docs/research-content-team.md and the accepted ADRs. Preserve all existing documents and code. Write your first findings in a new docs/content-team-review.md, checking that it does not already belong to someone else. Identify unsupported integration claims, client/OS limitations, unnecessary roles, missing artifact or failure contracts, aesthetic weaknesses and risks in performance measurement. Propose concrete alternatives with sources and decision IDs. Do not implement, install, connect accounts, generate media, publish, commit or push. Distinguish what is documented from what has been executed. Return recommendations and the few decisions that would materially change the architecture.

## 8. Next architecture iteration

The user can refine reusable versus personal scope, real/AI media policy, target channels, editor preference, monthly provider budget and desired cadence. These choices customize the proposal; they do not block a generic architecture.

After review, revise the plan and design system, keep decision IDs stable, and record unresolved disagreements. Implementation starts only after the user explicitly authorizes it. At that time, define a small vertical slice with real exports and failure tests before adding the remaining adapters.

