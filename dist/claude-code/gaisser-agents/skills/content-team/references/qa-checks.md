# QA checks

The QA role records `pass`, `fail`, or `limited` per check, with page or frame evidence and the owning role. `limited` means the check could not be completed and never counts as a pass. A failure routes to the owning role, and the run cannot reach `delivered` until it is fixed or the user records a scoped exception that marks delivery `limited`.

| Check | What is verified | Owner of a failure |
|---|---|---|
| 1. Text integrity | Spelling and grammar in the profile's language, and every string in the render matching `copy.md` exactly | writer or designer |
| 2. Clipping and legibility | No overflow, clipped glyph, overlap, or margin violation; contrast at or above the floor in `visual-system.md`, measured on composited pixels at full resolution on every page and every caption-change frame | designer |
| 3. Claims | Every factual claim traces to a dated source in `scout.md`; a performance claim about the user's own audience traces to `## Worked for you`, and without that section any such claim is a defect; no invented metric, no guarantee wording | writer |
| 4. Privacy | Full-resolution sweep of every still and frame for addresses, private handles, message threads, tokens, file paths, notifications, faces without consent, and location | designer |
| 5. Provenance and policy | Each asset class matches `assets.md`, nothing denied or unresolved appears, required labels are present | main session or designer |
| 6. Technical and prohibitions | Dimensions, page count and order, duration, frame rate, and file size against the target profile, plus each hard prohibition in `visual-system.md` | designer |

Sampled frames cannot prove a video is private or readable. A video without a full-duration review is `limited`, not `pass`.
