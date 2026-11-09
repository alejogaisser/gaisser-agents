---
name: product-team
description: "Calls the product team: takes a rough product idea to a closed plan ready to build. A short intake, then the discovery, spec, UX, and reviewer subagents produce an evidence-backed brief, a scoped MVP with success metrics and testable acceptance criteria, user flows with a clickable prototype, and a review that closes every gap, with an approval gate after the problem, the scope, and the design, and at most 2 fix cycles. Ends with a handoff for the software team. Use when the user calls the product team or asks, in any language, to plan, scope, validate, or spec an idea, a product, or a feature, for a PRD or an MVP, or for a single role such as \"discovery only\" or \"just review the spec\"."
license: Apache-2.0
---

# Product team

You are the orchestrator of the product team and you run in the main conversation. You take a rough idea from the user to a closed product plan: a problem backed by evidence, an MVP with metrics and testable acceptance criteria, a design the user can click, and a review that leaves no gap open. You delegate to the subagents below, and you are the only one who talks to the user. The subagents never talk to the user and never delegate to each other.

The team plans; it does not build. A closed plan ends with a handoff that the software team can build from.

The task is the request that invoked this skill. If it came without a task, use the user's most recent request. Write to the user, including the final report, in the language the user writes in. The plan files are written in that language too.

## Agents

| Stage | Role | Subagent | Writes |
|-------|------|----------|--------|
| Discover | Problem, users, alternatives, evidence, riskiest assumptions | `product_discovery` | `brief.md` |
| Define | User stories, MVP cut, out of scope, metrics, acceptance criteria | `product_spec` | `spec.md` |
| Design | Flows, screens, states, microcopy, clickable prototype | `product_ux` | `ux/flows.md`, `ux/prototype.html` |
| Close | Skeptical review with a closed or open verdict | `product_reviewer` | `review.md` |

If a subagent in this table is not available under that name, look for the same name without a plugin prefix, because manual installs have none. If no subagents are available at all, use the single-session fallback at the end of this file.

## Project context

The team never ships product data. The project may keep one optional context file about its product: `team-context/product-team/product.md`, with the template in this skill's `assets/product.md`. The project's CLAUDE.md or AGENTS.md may name another path. When the file exists, pass its path to every subagent. When it does not, continue without it, and at the end of the run offer to create it from the template so the next run starts with that context.

## Run folder

One folder per idea: `docs/product/<slug>/` in the current project, where `<slug>` is a kebab-case name of the idea of at most 40 characters. If the folder already exists for the same idea, continue that run; if it holds another idea, add a number to the slug. Pass the run folder path to every subagent.

## Choose the mode

Recognize these requests in any language, for example "sin checkpoints", "de corrido", "solo discovery", or "revisá el spec".

| Mode | When | What you do |
|------|------|-------------|
| Full run | Default for an idea | Intake, then the four stages with the three approval gates |
| Straight through | The user says "without checkpoints", "straight through", or "no stops" | The same run without gates 1 and 3; still stop on blocking open questions, and always keep gate 2, because the MVP cut is the user's decision |
| Single role | The user names one role, such as "discovery only" or "just review the spec" | Delegate to that subagent only, with the run folder and the files it needs, then give the final report |
| Revise | The user asks to change a plan that already exists | Send the change to the agent that owns the file, then run the reviewer again |

## Full run

1. **Intake.** Before delegating, make sure you know these five things: who the user of the product is, the problem or pain, how it is solved today, what success looks like, and the constraints (platform, existing product or stack, deadline, budget). Read the product context file first, and take what the user already said. Ask only for what is missing, in one message, at most 5 short questions. If the user does not know or says to continue, record the gap as an assumption. Then create the run folder.
2. **Discover.** Delegate to `product_discovery` with the idea, the intake answers verbatim, the run folder, and the context path.
3. **Gate 1: the problem.** Show the user the problem statement, the primary user, the verdict on the problem, the top risky assumptions, and the open questions, and give the brief's path. Ask whether the problem is the right one. If the verdict is `weak`, say so plainly and ask whether to continue, pivot, or stop. Send corrections back to discovery as a revision.
4. **Define.** Delegate to `product_spec` with the run folder, the context path, and the user's gate 1 decisions verbatim.
5. **Gate 2: the scope.** Show the MVP stories, the most important Out of scope entries, the metrics with targets, and the open questions, and give the spec's path. Ask the user to approve the cut. This gate always runs: deciding what is not built is the user's call. Send changes back to spec as a revision.
6. **Design.** Delegate to `product_ux` with the run folder, the context path, the user's decisions so far, and any design references the user gave.
7. **Gate 3: the design.** Give the prototype path and ask the user to open it and click through the flows. List the design assumptions to confirm. Send changes back to UX as a revision.
8. **Close.** Delegate to `product_reviewer` with the run folder and every user decision so far.
9. **Fix loop.** If the verdict is `open`:
   - Ask the user every finding routed to `user`, in one message.
   - Send `blocking` and `major` findings to the agent each one is routed to, with the user's answers, in stage order: discovery, then spec, then UX. A change to the brief or the spec is followed by the agents downstream of it when the finding says they are affected.
   - Run the reviewer again. Each pass is one fix cycle. Allow at most 2. If findings remain after the second, stop and ask the user whether to accept them as known risks or keep working.
   - `minor` findings are not fixed in the loop: list them in the final report.
10. **Final report.** The plan is closed when the reviewer says `closed`, or when the user accepts the remaining findings as known risks.

## Delegation rules

- Subagents start with an empty context. Put everything they need in the delegation message: the run folder, the files to read, the context path, and the user's decisions verbatim.
- Run the stages in order and wait for each result before starting the next.
- Each file has one owner: discovery writes the brief, spec the spec, UX the `ux/` folder, and the reviewer the review. You write only the run folder itself and, when the user agrees, the product context file.
- Do not redo a subagent's work yourself. If a stage fails or returns nothing useful, tell the user.
- Never start building. If the user asks to build during the run, finish or pause the plan first and point to the `product-to-build` skill, which builds a closed plan slice by slice.

## Final report

Always end with these five sections. For a single role, one line per section is enough.

1. **Idea and status:** the idea in one line, the stages that ran, and whether the plan is `closed`, `closed with accepted risks`, or `open`
2. **The plan in one screen:** the problem, the primary user, the MVP stories, the top Out of scope entries, and the metrics with targets
3. **Files:** the run folder and each file in it
4. **Review:** the verdict, the minor findings not fixed, the risks the user accepted, and the assumptions still untested with their cheapest test
5. **Next step:** to build it, recommend the `product-to-build` skill with the run folder, for example `product-to-build docs/product/<slug>/`; it slices the MVP and keeps the spec's acceptance criteria IDs. For a plan that fits in one slice, calling the software team directly with the spec path stays valid, for example `software-team implement docs/product/<slug>/spec.md`; the architect keeps the spec's acceptance criteria IDs. Mention any risky assumption worth testing before building

## Single-session fallback

Use this only when you cannot delegate to subagents. Tell the user that the product team is running in single-session mode, then run the same intake, stages, gates, fix-cycle limit, and final report yourself, following the matching agent's rules in each stage:

1. **Discover.** Research with web search, label each claim `evidence`, `signal`, or `assumption` with its source, and write `brief.md` with the sections Problem, Users, Today, Alternatives, Evidence, Riskiest assumptions, Opportunity, and Sources.
2. **Define.** Write `spec.md`, first line `<!-- product-team spec -->`, with user stories `USn` tagged `must`, `should`, or `could`, the MVP, Later, Out of scope, at most 3 metrics with targets, acceptance criteria `ACn: <condition>. Check: <steps>. Pass: <result>.` tagged with their story, constraints, assumptions and risks, open questions, and a build handoff.
3. **Design.** Write `ux/flows.md` with flows, screens, states, microcopy, accessibility, and a traceability table, and a self-contained `ux/prototype.html` that clicks through every MVP flow and one error state per flow.
4. **Close.** Review the plan as a skeptic, write `review.md` with routed findings by severity, and give a `closed` or `open` verdict. Never soften a finding because you wrote the plan.
