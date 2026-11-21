# Design skills: the craft foundation

The design skills the user has installed are the foundation of every piece (reel, carousel, still), not a menu. You read them with your read tool, never write to their folders, and never install them. The plugin still works without them: a missing skill is recorded and its coverage rule is waived.

## Find the skills

Look for each skill by name, in this order: the folder named under `## Optional design skills` in the tool preferences, then `~/.claude/skills/<name>/SKILL.md`, then `~/.agents/skills/<name>/SKILL.md`, then the plugin skill folders under `~/.claude/plugins/` (synced and marketplace plugins keep skills at `.../skills/<name>/SKILL.md`). A skill may exist in one folder only, so check all of them. The orchestrator records the paths it found in `run.json` as `designSkills` and passes them to you.

If a skill is not installed, skip it, record it in `## Craft sources` as not installed, and its coverage rule is waived.

`carrusel-aesthetic` is not digested: its rules already live in the user's `visual-system.md`, which wins.

## Craft digest

Reading every skill on every run is too heavy, so distil them once. The digest lives at `team-context/content-team/craft-digest.md` (overridable like the other context files); its template is `assets/craft-digest.md`.

Refresh rule: at run start compute each found skill's fingerprint with the script below (hashing only, no reading). Rebuild a skill's section when the digest is missing, its first line is not the v1 marker, the skill was added or removed, or the fingerprint changed. Otherwise read only the digest. Paraphrase each rule in one line, never copy code or long passages, and report `Digest: reused` or `Digest: rebuilt`.

| Skill | Prefix | Files to read (relative to the skill folder) | Minimum principles |
|---|---|---|---|
| `motion-design` | `MD-` | `SKILL.md`, `director/core-philosophy.md`, `director/disney-principles.md`, `director/motion-personality.md`, `director/choreography.md`, `director/narrative-structure.md`, `director/emotion-mapping.md`, `patterns/entrance-exit.md`, `patterns/multi-element.md`, `patterns/ambient-continuous.md`, `reference/timing-easing-tables.md`, `reference/quality-checklist.md`, `reference/troubleshooting.md` | 24 (the 12 principles, the 4 personalities, the 1/3 rules, stagger budgets, easing direction) |
| `motion` | `MO-` | `SKILL.md`, `css-spring/index.md`, `best-practices/index.md` | 3 (never reconstruct gated Motion+ content) |
| `anatomy` | `AN-` | `SKILL.md`, `references/craft.md`, `references/motion.md` | 10 |
| `hairline-create` (and `hairline-adopt`, `SKILL.md` only) | `HL-` | `SKILL.md`, `rules.md`, `concepts.md`, `look.md` | 10 (its ten rules) |
| `anatomy-reveal` | `AR-` | `SKILL.md`, `references/shots.md`, `references/look.md` | 6 |
| `remotion-markup` | `RM-` | `SKILL.md`, `timing.md`, `sequencing.md`, `transitions.md`, `motion-blur.md`, `text-highlights.md` | 5 |
| `frontend-design` | `FD-` | `SKILL.md` | 8 |
| `design-critique` | `DC-` | `SKILL.md` | 5 |
| `design-system` | `DS-` | `SKILL.md` | 4 |
| `accessibility-review` | `AX-` | `SKILL.md` | 5 |

```python
import hashlib, os, sys

root = sys.argv[1]
h = hashlib.sha256()
for rel in sys.argv[2:]:
    path = os.path.join(root, rel)
    if os.path.isfile(path):
        h.update((rel + "\n").encode("utf-8"))
        with open(path, "rb") as f:
            h.update(f.read())
print(h.hexdigest()[:12])
```

Run it as `fingerprint.py <skill folder> <relative file>...`. If a skill version names other files, read the listed files that exist and record the list used. A missing file lowers the minimum only when the skill's `SKILL.md` no longer names that topic.

## What each skill contributes

| Skill | Contributes to every piece | Renders an optional scene (time) |
|---|---|---|
| `motion-design` | principles, personality, choreography, timing and easing tables; below the team's `motion-design.md` and the visual system on conflict | no |
| `motion` | spring curves, converted from CSS `linear()` stops into a GSAP ease function, never CSS animation | no |
| `anatomy` | construction, shading, painter's order, motion of a system drawn as a machine | yes, a Figure (about 1 h) |
| `hairline-create` and `hairline-adopt` | one accent stroke, lines that resolve, a composed rest pose; adopt only for the user's own SVG, another company's mark only after an `ask` | yes (under an hour) |
| `anatomy-reveal` | the reveal vocabulary: tumble in, whip to macro, explode, snap back, hero hold | yes (2-4 h for the object, about 1 h for the film, about 2 min render per film second) |
| `remotion-markup` | sequencing, timing, transitions, motion blur on whips, text highlights; never renders unless the tool preferences say so | no |
| `frontend-design`, `design-system`, `design-critique`, `accessibility-review` | layout, token, critique and accessibility principles for stills and pages | no |

## Coverage rules

The visual system and the team's references win on conflict; record each conflict in the digest's `## Conflicts`. A rule for a skill that is not installed is waived.

1. Each scene has at least one Disney principle and one timing or choreography rule (`MD-`).
2. Each named transition has an ID, and every video has at least one transition from the reveal vocabulary (`AR-`): tumble in, whip to macro, explode, snap back, hero hold. This is at least one transition per video.
3. Every coded illustration, icon, diagram, or figure follows `AN-` or `HL-` rules (isometric construction, four-tone shading, painter's order, lines that resolve, one accent stroke, composed rest pose). Type, plain shapes, and gradients are exempt.
4. Every spring or overshoot ease is an `MO-` curve converted to a GSAP ease.
5. At least one `RM-` rule shapes the timeline structure of each video.
6. Stills apply `MD-` staging and hierarchy per page.
7. Every still page and every carousel page has at least two `LY-` IDs (from `layout-craft.md`) and one `FD-` or `DC-` ID when installed; the critique cites `DC-` when installed.

## Craft sources in the spec

`design-spec.md` carries `## Craft sources`. First line: `Digest: <path>, v1, <skill>=<fingerprint> ...`. Then a table `Item | Kind (piece, scene, transition, graphic, ease, page) | IDs | How it shows (property, value, time) | Where (checkpoint or page)`, with a row for every scene, named transition, coded graphic, spring or overshoot ease, and page. "How it shows" names a property, a value, and a time, never only an ID. Last line: `Not installed: <skills or None>`.

## Scene inside the GSAP pipeline

A pre-rendered scene is optional; the craft language applies with or without one. The skill's output is pre-rendered to a PNG sequence, and the GSAP page shows it with brand type and stickers on top.

- Keep the project under `code/<piece>/scenes/<scene>/`. Never edit a skill's kernel or bench.
- Render frames to `code/<piece>/scenes/<scene>/frames/00000.png` onward at the reel fps, for exactly the scene duration.
- `__seek(t)` shows frame `clamp(round((t - start) * fps))` in an `<img>` or canvas and awaits `decode()`.
- Set the skill's colour variables to palette roles with an injected style. The scene has no words of its own: hide read-outs and captions with the same style; every word comes from `copy.md`.
- Save the skill's own check output (hairline `look.mjs`, anatomy `--audit`, anatomy-reveal `motion/scan.mjs`) to `out/<piece>/scenes/<scene>-check.txt`.
- For an anatomy-reveal film, extract frames with `ffmpeg -y -i <film>.mp4 -vf fps=<fps> -start_number 0 <frames>/%05d.png`.
- Treat the paper look of anatomy-reveal as an image under the image treatment rules of the visual system.
- List each scene in the spec under `## Pre-rendered scenes`: `Scene | Skill | Mode | Start s | End s | Frames folder | Check file`.

## Own render path

Use it only when an anatomy-reveal film is the deliverable. Take the ratio from the format and `--duration` from the spec, add audio as `audio-beats.md` says, and build checkpoints and the contact sheet from its frames as `video-pipeline.md` says.

## Capture a live page

Hairline and anatomy pages animate with `requestAnimationFrame` and `performance.now`. Capture them on a virtual clock so frames repeat exactly:

1. `await page.clock.install({ time: 0 })` before `goto`.
2. Start the tour (hairline: `?play=1`).
3. For each frame `i`, call `page.clock.runFor(Math.round((i + 1) * 1000 / fps) - Math.round(i * 1000 / fps))`, then screenshot only the figure element.
4. Never record in real time. Without Chrome, use Edge through Playwright with `channel: 'msedge'` or the skill's `CHROME_PATH`.

## Remotion (optional)

Off by default. Remotion's licence is source-available: free for individuals, for-profit organisations of up to 3 employees, non-profits, and evaluation; others need a Company License. Check the licence page on the Remotion site before relying on it. Use it as a renderer only when the tool preferences name Remotion for a format and record licence eligibility; the same outputs contract then applies: `data-copy-id`, `layout-report.json`, checkpoints, and contact sheets. Its markup skill is still digested as craft guidance (`RM-`); it never renders unless the tool preferences say so. Never use its voice or caption features.
