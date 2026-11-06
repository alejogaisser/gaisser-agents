# Code-to-video pipeline

Read this before you render any video locally. The video is a web page animated with GSAP, captured frame by frame by a headless browser, and encoded with ffmpeg. Every frame is computed from time, so a render is exact and repeatable.

## Setup

- Needs Node.js 18 or later and ffmpeg on the path. Check with `node --version` and `ffmpeg -version`; if either is missing, stop and report it.
- In the run's `code/` folder: `npm init -y`, then `npm install gsap playwright`, then `npx playwright install chromium`. These come from the official registries and are the only downloads allowed.
- Load GSAP and its plugins from `node_modules`, never from a CDN, so a render works offline and never changes.
- Record the versions you used in the spec.

## Page structure

One HTML file per video, `code/<piece>/index.html`:

- The `body` is exactly the canvas size from `visual-system.md` (for example 1080 by 1920), with `overflow: hidden` and no scrollbars.
- Every element that shows a string from `copy.md` carries `data-copy-id="<string id>"`. QA matches strings by this id.
- Every element carries a `data-layer` of `bg`, `mid`, or `fg`.
- Build one master `gsap.timeline({ paused: true })` from the spec's timeline, with child timelines per scene.
- Expose two functions on `window`:
  - `window.__duration`: the total duration in seconds.
  - `window.__seek(t)`: calls `master.seek(t, false)`, then redraws anything time-driven (canvas, three.js, particles) for time `t`, and returns a promise that resolves after two `requestAnimationFrame` ticks.
- Nothing may depend on the wall clock: no CSS `@keyframes` or `transition`, no `setTimeout`, no `Date.now()`, no unseeded `Math.random()`. Use a seeded random generator (for example mulberry32 with a fixed seed in the spec).
- A `<video>` element is driven by setting `currentTime = t` and awaiting its `seeked` event inside `__seek`.
- Await `document.fonts.ready` and every image's `decode()` before the first frame.

## Capture

Write `code/<piece>/render.mjs` that:

1. Launches Chromium with Playwright, opens the page at the canvas size with `deviceScaleFactor: 1`, and waits for a `window.__ready` flag.
2. For each frame `i` from 0 to `ceil(duration * fps) - 1`: calls `__seek(i / fps)`, takes a PNG screenshot, and writes it to `out/<piece>/frames/00000.png` and onward.
3. At each time in the spec's `## Checkpoints` list: saves the full-resolution frame as `out/<piece>/checkpoints/001.png` and onward, and collects a layout entry for every `[data-copy-id]` element: the id, its `innerText`, its bounding box, whether it overflows (`scrollWidth > clientWidth` or `scrollHeight > clientHeight`), whether the box lies inside the safe margins, its computed colour, and its opacity.
4. Writes `out/<piece>/layout-report.json` with the canvas size, fps, duration, the checkpoint times, and the layout entries per checkpoint.

## Encode

```
ffmpeg -y -framerate 30 -i out/<piece>/frames/%05d.png -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -movflags +faststart out/<piece>/<piece>.mp4
```

- Use 30 fps by default and 60 fps for fast motion; state it in the spec.
- With music or voice: add `-i <audio file> -c:a aac -b:a 192k -shortest`. Audio files come only from assets allowed in `assets.md`.
- Then build the contact sheet QA reviews: `ffmpeg -y -i out/<piece>/checkpoints/%03d.png -vf "scale=270:-1,tile=6x4:padding=8:color=white" out/<piece>/contact-sheet-%02d.png`. One sheet holds 24 checkpoints; more checkpoints make more sheets.
- Delete `frames/` after a successful encode unless the caller asks to keep it.

## Platform profile

The canvas and margins in `visual-system.md` win. When a slot is empty, use these vertical-video defaults and mark them in the spec:

| Value | Default |
|---|---|
| Canvas | 1080 by 1920, 9:16 |
| Frame rate | 30 fps |
| Length | 7 to 30 s; hook inside the first 1.5 s |
| Top zone kept clear of key content | 220 px (app header) |
| Bottom zone kept clear of key content | 420 px (caption and buttons) |
| Right zone kept clear of key content | 140 px (like and share buttons) |
| Cover frame | the checkpoint the spec names as cover, exported as `cover.png` |

## Self-check before you report

1. Open each contact sheet and each checkpoint where the layout report shows an overflow or a box outside the margins, and fix what you find.
2. Watch the motion in sequence on the contact sheet: every scene must differ visibly from the one before, and no checkpoint pair may look identical unless the spec says it holds.
3. Confirm with `ffprobe` that the size, fps, duration, and codec match the spec.
