# QA checks

The QA role records `pass`, `fail`, or `limited` per check, with page, frame, or checkpoint evidence and the owning role. `limited` means the check could not be completed and never counts as a pass. A failure routes to the owning role, and the run cannot reach `delivered` until it is fixed or the user records a scoped exception that marks delivery `limited`.

| Check | What is verified | Owner of a failure |
|---|---|---|
| 1. Text integrity | Spelling and grammar in the profile's language, and every string in the render matching `copy.md` exactly | writer or designer |
| 2. Clipping and legibility | No overflow, clipped glyph, overlap, or margin violation; contrast at or above the floor in `visual-system.md`, on composited pixels at every page and every checkpoint | designer |
| 3. Claims | Every factual claim traces to a dated source in `scout.md` (when the run has `ship.md`, a claim about the user's shipped work may trace to one of its evidence lines); a performance claim about the user's own audience traces to `## Worked for you`, and without that section any such claim is a defect; no invented metric, no guarantee wording | writer |
| 4. Privacy | No addresses, private handles, message threads, tokens, file paths, notifications, faces without consent, or location in any still or frame | designer |
| 5. Provenance and policy | Each asset class matches `assets.md`, nothing denied or unresolved appears, no `reference-only` image from `scout-refs/` appears, required labels are present | main session or designer |
| 6. Technical and prohibitions | Dimensions, page count and order, duration, frame rate, codec, and file size against the target profile, plus each hard prohibition in `visual-system.md`; the `determinism` entries in `layout-report.json` all zero | designer |
| 7. Motion quality | For video: motion in the first 1.5 s, no static stretch over the limit, the spec's transitions and pacing present, scenes visibly different, motion rules in `visual-system.md` or `motion-design.md` respected | designer |
| 8. Audio licence and beat sync | Every audio file the render or mix uses has an `assets.md` row with class `stock-audio` or `own-media`, licence `cc0`, `pdm`, or `by`, a landing URL, a credit line, and an allowed resolution; one aac stream at 48000 Hz within 0.1 s of the video; integrated loudness -16 to -12 LUFS and true peak at most -1 dBTP; every `on-beat` event within 1 frame of a `beats.json` frame; no voice: until `approvals.audioAudition` exists in `run.json` this part is `limited` with the reason "vocals not auditioned", `no vocals` lets it `pass`, and `has vocals` fails it, owned by the main session | main session for licence, designer otherwise |
| 9. Pre-rendered scenes | Each scene in the Pre-rendered scenes section has a clean check file, exactly `round(duration * fps)` frames, no blank frame, no words of its own, no third-party mark, and the palette or image treatment respected | designer |
| 10. Craft sources | Every scene, named transition, coded graphic, spring or overshoot ease, and page in the spec has a `## Craft sources` row; every ID exists in `craft-digest.md`; the coverage rules of `design-skills.md` are met for each installed skill; each row is marked `seen` or `not seen` at its checkpoint or page, and any `not seen` fails; for at least 3 used IDs from different skills, read the source file named in the digest (from the `designSkills` paths) and confirm the rule; a missing digest or mapping is a failure | designer |
| 11. Layout craft | The `## Thresholds` of `layout-craft.md` met on every still page and every settled checkpoint, computed from `layout-report.json`; the key phrase is the largest text; every sticker has a named anchor visible on the page; `## Critique` exists with every major marked fixed; no carousel repeats an archetype on consecutive pages in `## Layout list`; no file under the piece's `code/` has the sha256 of a CSS or HTML file in the prior run's `code/` (the prior run is the `priorRun` path in `run.json`); the archetype sequence differs from the prior run's `## Layout list` when it has one; the spec's `Brand mode` equals `brief.md`'s and fits the subject, and in `product` mode `## Product direction` exists, its palette is not the visual system's palette, and the personal brand shows only as the signature element | designer |
| 12. Creative process | `material.md` has at least 8 `M-` facts with sources; `angles.md` has at least 12 candidates from at least 4 families, a `K` code on each killed one, and 3 scored finalists; the chosen angle equals `approvals.angle`, and `scout.md` `## Angle` names it; `copy.md` `## Hook bank` has at least 10 hooks across at least 5 mechanisms; `drafts.md` has 3 drafts and `## Punch-up log`; the final strings contain 0 `banned` phrases (from `creative-process.md` and the profile) and cite at least 2 `M-` IDs; a run without `angles.md` records `pass` with "not applicable" | writer (scout for `material.md`) |

In a single-piece spec the Beats, Pre-rendered scenes, Craft sources, Layout list, and Critique sections are `##`; in a multi-piece spec each is `###` under the piece's heading (for example `## Reel` then `### Beats`). Checks 8 to 11 and their scripts look for either level, under the piece's heading.

## Method: cheapest evidence first

Never review a video frame by frame. Work in three tiers and stop a check at the first tier that settles it.

1. **Machine checks (no images).**
   - Technical: `ffprobe -v error -show_entries stream=width,height,r_frame_rate,codec_name:format=duration,size -of json <file>`.
   - Text integrity: compare every `innerText` in `layout-report.json` with its string in `copy.md` by id, with a short script; then spell-check the strings in `copy.md` once, as text.
   - Clipping and margins: read the overflow and inside-margins flags in `layout-report.json` at every checkpoint.
   - Contrast: compute it with a short script from the composited checkpoint PNG, sampling the pixels inside each text box against the text colour in the layout report.
   - Provenance: compare the files the render sources load in `code/` against `assets.md`.
   - Audio: `ffmpeg -i <file> -af ebur128=peak=true -f null -` for loudness and true peak, and a short script that compares every `on-beat` row of the spec's `## Beats` table with `beats.json`.
   - Craft sources: a script for row coverage and ID existence against `craft-digest.md`. The source spot-check reads only the cited section: search the source file for the rule's key term and read about 20 lines around it, not the whole file.
   - Layout: a script over `layout-report.json` for the thresholds of `layout-craft.md`, a sha256 comparison of `code/` CSS and HTML files against the prior run's, and the archetype check over `## Layout list`.
   - Creative process: a short script over `material.md`, `angles.md`, `copy.md`, `drafts.md`, and `run.json`.
   - Blank frames: on a 2 fps sample, `magick <frame> -format "%[fx:standard_deviation]" info:`; below 0.01 is blank.
2. **Contact sheets (a few images).** Review the contact sheets in `out/<piece>/`, which hold every checkpoint downscaled, for each `## Craft sources` row (open a full-resolution checkpoint only when a tile cannot settle it), sticker anchors and the first read, overall composition, privacy of coded content, motion quality, and the hard prohibitions. One sheet covers 24 checkpoints.
3. **Full-resolution frames (only where needed).** Open a full-resolution checkpoint only when tier 1 flags it, when a tile on the sheet looks wrong, or when it contains footage, a screenshot, or own media, which may hide private details a script cannot see.

## Coverage rules

- Coded graphics are fully known from their source and `layout-report.json`; a checkpoint review covers them.
- Footage, screenshots, and own media need a privacy sweep at 2 frames per second across the time they are on screen: extract them into a contact sheet with `ffmpeg -ss <start> -to <end> -i <file> -vf "fps=2,scale=360:-1,tile=6x4" <sheet>.png` and open full-resolution frames only where text or faces appear.
- A pre-rendered scene gets the 2 fps sweep like footage. Checks 8 and 9 record `pass` with "not applicable" when the piece has no audio or no scene.
- With no design skill installed, check 10 passes when `Not installed` lists every skill and the rows cite only the team's references. A piece without text boxes records check 11 as `pass` with "not applicable".
- A video with machine checks, every contact sheet reviewed, and the footage sweep done is fully covered and may `pass`. A missing `layout-report.json` or missing checkpoints makes checks 1, 2, and 7 `limited` and is itself a designer failure under check 6.
