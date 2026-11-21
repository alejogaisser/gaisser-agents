# Creative process

Read this for the ideation and copy passes. The goal is a theme and a copy that come from the user's real material, survive hard kill criteria, and are chosen by the user before research, copy, or design is spent. The method is generic: the user's pillars, voice, and material stay in their project, never here.

## Material

Scout pass 1 (`material and signals`) writes `material.md` in the run folder. Sources are the paths in the tool preferences `## Material sources` and the ones named in the brief. Use read-only commands only:

- `git log --since=60.days --pretty=format:"%ad %s" --date=short` and `git log --stat -n 20` on each repository path.
- READMEs, notes files, footage inventories, and the EXIF dates of the photos the brief names.
- The `brief.md` and `copy.md` titles of the last 10 folders in `content-runs/`, as prior themes.

Format of `material.md`:

- `## Facts`: rows `M-1 | date | fact in one paraphrased line | source (command or file) | usable as (claim, detail, visual)`, numbered `M-1`, `M-2`, and onward.
- `## Prior themes`: the themes of the last runs, one line each.
- `## Off-limits`: what the user excluded.

Rules: never copy code, secrets, tokens, hostnames, absolute paths, or names of people other than the user. Skip anything listed off-limits. When no source is readable, write `No material` and the reason.

## Angle families

Candidates come from several families, so they diverge instead of varying one idea:

- Real moment: one concrete thing that happened, told as it happened.
- What broke: a failure, its cause, and what changed.
- Teardown of something real: take one real thing apart and show the parts.
- Contrarian take: a position against the default, backed by something the user did.
- Before and after: a measured change, with both states shown.
- Experiment or challenge: a bounded try with a result.
- POV or relatable situation: the viewer sees themselves in it.
- Behind the scenes: the unglamorous working detail.
- Number from real work: one count or duration that surprises.

## Kill criteria

Apply each code to every candidate and record the codes of the ones you drop:

- `K1` obvious: the first idea anyone has, or a top search headline.
- `K2` generic: fails the swap test (swap the user for any other creator and the piece still works).
- `K3` no named tension.
- `K4` no `M-` support; waived with a reason only when the run has `No material`.
- `K5` repeats a prior theme or a brief exclusion.
- `K6` needs an unverifiable or forbidden claim.
- `K7` cannot be told in the format.

## Scorecard

Write `angles.md` with at least 12 candidates. Table: `ID | Family | Premise | Tension | M-IDs | Kill codes | S | T | P | F | V | N | Score`. Score each of S (specificity), T (tension), P (payoff), F (fit to the format), V (voice fit), N (novelty) from 1 to 5; Score = 2S + 2T + P + F + V + N. Pick 3 finalists from at least 2 families. Each finalist block holds the premise, the tension, the stop-scroll line (why a stranger stops within 1.5 s), 3 hook drafts with different mechanisms, a structure outline, and the `M-` IDs.

## Angle gate

The orchestrator shows the user the 3 finalists, 3 lines each: premise, tension, best hook. Answers: pick 1 to 3; `otra tanda` (a second batch, at most once); or `elegí vos`, which takes the top score and is recorded as `delegated`. Record `approvals.angle` in `run.json` with the id, the time, and the user's words.

## Hook bank

Write `## Hook bank` in `copy.md`: at least 10 hooks across at least 5 mechanisms. Mechanisms:

- Open-loop question.
- Contrarian claim.
- Sourced number.
- In medias res.
- Mistake or confession.
- Before and after.
- POV.
- Experiment.
- "Nobody shows you".
- List promise, only with a real count.

Five tests for every hook: readable in 1.5 s (about 7 words on a first video frame, about 70 characters for an X first line); opens a gap; holds a specific noun from the material or the angle; not banned; in voice. Mark one pick and a backup, with reasons.

## Drafts and punch-up

Write 3 drafts in `drafts.md` with different structures (story arc, contrast, list or POV), choose one and say why. Then the cut pass: remove at least 20% of the words, or justify why not. Replace abstract nouns with material. Apply the delete test to each line (if it goes, does anything break?). The call to action asks something only this piece can ask. Captions add something the screen does not say. Keep a `## Punch-up log` of before and after.

## Voice check

Match the register in `profile.md`. For voseo profiles, flag `tú`, `puedes`, `tienes`, `quieres`, `eres`, `sabes`, `haz`, `mira`, and use `podés`, `tenés`, `querés`, `sos`, `sabés`, `hacé`, `mirá`. Keep English technical terms as the profile says.

## Banned clichés

Scan the final strings for these, and for any never-allowed wording the profile adds at run time:

- "en este video te muestro"
- "no vas a creer"
- "cambió mi vida"
- "el secreto de"
- "nadie te dice esto"
- "game changer"
- "level up"
- "spoiler:"
- "esto es oro"
- "abro hilo"
- "sin más preámbulos"
- "te explico"
- "no es magia"
- "mindset"
- "un paso a la vez"
- "in this video I'll show you"
- "you won't believe"
- "unlock your potential"

## Specificity

Each piece carries at least 2 sourced concrete details, each with its `M-` ID, and lists the IDs it used in the claims section of the writer's report. Numbers come only from `material.md` or a dated scout source. Never invent a name, a count, or a date.
