# QA checks

The QA role records `pass`, `fail`, or `limited` per check, with page, frame, or checkpoint evidence and the owning role. `limited` means the check could not be completed and never counts as a pass. A failure routes to the owning role, and the run cannot reach `delivered` until it is fixed or the user records a scoped exception that marks delivery `limited`.

| Check | What is verified | Owner of a failure |
|---|---|---|
| 1. Text integrity | Spelling and grammar in the profile's language, and every string in the render matching `copy.md` exactly | writer or designer |
| 2. Clipping and legibility | No overflow, clipped glyph, overlap, or margin violation; contrast at or above the floor in `visual-system.md`, on composited pixels at every page and every checkpoint | designer |
| 3. Claims | Every factual claim traces to a dated source in `scout.md`; a performance claim about the user's own audience traces to `## Worked for you`, and without that section any such claim is a defect; no invented metric, no guarantee wording | writer |
| 4. Privacy | No addresses, private handles, message threads, tokens, file paths, notifications, faces without consent, or location in any still or frame | designer |
| 5. Provenance and policy | Each asset class matches `assets.md`, nothing denied or unresolved appears, no `reference-only` image from `scout-refs/` appears, required labels are present | main session or designer |
| 6. Technical and prohibitions | Dimensions, page count and order, duration, frame rate, codec, and file size against the target profile, plus each hard prohibition in `visual-system.md` | designer |
| 7. Motion quality | For video: motion in the first 1.5 s, no static stretch over the limit, the spec's transitions and pacing present, scenes visibly different, motion rules in `visual-system.md` or `motion-design.md` respected | designer |

## Method: cheapest evidence first

Never review a video frame by frame. Work in three tiers and stop a check at the first tier that settles it.

1. **Machine checks (no images).**
   - Technical: `ffprobe -v error -show_entries stream=width,height,r_frame_rate,codec_name:format=duration,size -of json <file>`.
   - Text integrity: compare every `innerText` in `layout-report.json` with its string in `copy.md` by id, with a short script; then spell-check the strings in `copy.md` once, as text.
   - Clipping and margins: read the overflow and inside-margins flags in `layout-report.json` at every checkpoint.
   - Contrast: compute it with a short script from the composited checkpoint PNG, sampling the pixels inside each text box against the text colour in the layout report.
   - Provenance: compare the files the render sources load in `code/` against `assets.md`.
2. **Contact sheets (a few images).** Review the contact sheets in `out/<piece>/`, which hold every checkpoint downscaled, for overall composition, privacy of coded content, motion quality, and the hard prohibitions. One sheet covers 24 checkpoints.
3. **Full-resolution frames (only where needed).** Open a full-resolution checkpoint only when tier 1 flags it, when a tile on the sheet looks wrong, or when it contains footage, a screenshot, or own media, which may hide private details a script cannot see.

## Coverage rules

- Coded graphics are fully known from their source and `layout-report.json`; a checkpoint review covers them.
- Footage, screenshots, and own media need a privacy sweep at 2 frames per second across the time they are on screen: extract them into a contact sheet with `ffmpeg -ss <start> -to <end> -i <file> -vf "fps=2,scale=360:-1,tile=6x4" <sheet>.png` and open full-resolution frames only where text or faces appear.
- A video with machine checks, every contact sheet reviewed, and the footage sweep done is fully covered and may `pass`. A missing `layout-report.json` or missing checkpoints makes checks 1, 2, and 7 `limited` and is itself a designer failure under check 6.
