# Visual effects and depth

Read this when a piece needs to look premium rather than flat. Effects serve the motion idea and the brand; they never replace a clear composition. Colours come only from the palette roles in `visual-system.md`; effects may vary their opacity, lightness, and blend, never introduce a new hue.

## Build depth with layers

Every scene has at least three layers:

| Layer | Contents | Motion |
|---|---|---|
| `bg` | gradient field, texture, blurred image | slowest: ambient drift only |
| `mid` | shapes, images, cards, footage | medium: entrances and camera moves |
| `fg` | text, highlights, small accents, particles | fastest and most precise |

Parallax: during a camera move, `bg` moves 20 to 30 percent of the `mid` distance and `fg` 120 percent. A slight scale-up on `bg` (1.00 to 1.08 over the scene) keeps it alive.

## Effect library

Use 2 to 4 per piece, chosen to fit the motion idea. More than that becomes noise.

- **Living gradient:** two or three radial gradients from the palette roles, each drifting in a slow loop (`drift`). Draw them on a canvas or as large blurred `div`s (`filter: blur(80px)`).
- **Grain:** a seeded noise texture at 4 to 8 percent opacity over everything, with its offset changed each frame. It removes the flat digital look.
- **Glow:** a duplicate of a shape or text, blurred 20 to 40 px, at 30 to 60 percent opacity behind the original. For the accent element only.
- **Light sweep:** a soft diagonal white gradient band crossing text or a card once, with `mix-blend-mode: overlay`, in 0.6 to 0.9 s.
- **Masks and reveals:** `clip-path` circles, polygons, or inset rectangles animated to reveal images and scenes.
- **Shape morph:** an SVG path that morphs between two shapes (GSAP `MorphSVGPlugin`, free), used as a transition or a background motif.
- **Line drawing:** SVG strokes drawn on with `stroke-dashoffset` for arrows, underlines, diagrams, and outlines.
- **Glass surface:** a card with a translucent surface colour, `backdrop-filter: blur(16px)`, and a 1 px light border. Needs a moving background behind it to read.
- **Particles:** 30 to 150 small dots or shapes from a seeded generator, moving along slow curves, at most 40 percent opacity. Never behind body text.
- **Chromatic offset:** red and blue copies of an element offset by 2 to 4 px for a few frames on a hard cut. Once per piece at most.
- **Depth of field:** blur `bg` from 0 to 6 px while `fg` enters, to pull focus.
- **3D tilt:** `perspective: 1200px` with `rotateX` and `rotateY` up to 12 degrees on cards and images, eased with `move`.
- **Real 3D:** a three.js scene rendered to a canvas for a hero object, logo, or abstract form. Render its frame for time `t` inside `__seek`, never with its own animation loop. Install it with `npm install three` beside GSAP. Postprocessing and particles follow the next sections.

## three.js postprocessing

Use the add-ons from `three/addons/postprocessing/`: `EffectComposer`, `RenderPass`, then the passes below, with `OutputPass` always last. Create the renderer with `preserveDrawingBuffer: true` and pixel ratio 1.

- `UnrealBloomPass` (bloom): strength 0.4 to 1.2, radius 0.2 to 0.6, threshold 0.6 to 0.9. For the accent only.
- `BokehPass` (depth of field): animate the focus with a GSAP tween on a plain object; keep aperture and maxblur small.
- `FilmPass` (grain): intensity 0.15 to 0.35. Never stack it on the CSS grain over the same pixels.

In `__seek(t)` set every time uniform from `t` (for example `filmPass.uniforms.time.value = t`) and call `composer.render(0)`. Rendering without a delta reads the wall clock, and `FilmPass` accumulates time.

## Particles with three.quarks

Install with `npm install three.quarks`. Add one `BatchedRenderer` to the scene and build the systems in code. Replace `Math.random` with the seeded generator before any system exists. Keep a `simTime`; when `t < simTime`, rebuild from the seed; then step `batchRenderer.update(1 / fps)` until `simTime` reaches `t`. At most 2000 particles.

## Determinism check

When a piece uses three.js or particles, render the first and last checkpoints twice in two fresh page loads and run `magick compare -metric AE a.png b.png null:`. Record `determinism` entries (checkpoint, differing pixels) in `layout-report.json`. Any non-zero value is fixed by removing the cause, never by dropping the check; if the cause is the GPU, drop the effect.

## Images and footage

- Ken Burns is the floor, not the ceiling: combine a slow push-in with a mask reveal or a parallax split (foreground cut-out moving faster than its background) where the asset allows it.
- Apply the image treatment rules in `visual-system.md` (scrim, focal point, dark image rule) on every frame, not just the settled one.
- Duotone or colour grade an image with the palette roles through a CSS filter or an SVG `feColorMatrix` when the visual system allows it.

## Performance

Heavy effects slow the capture, not the result. Keep each frame under about 500 ms to render: prefer canvas over many DOM nodes for particles, and cap blur radius at 80 px. If a render would take more than 10 minutes, simplify the effect, not the frame rate.

## Never

- A new colour outside the palette roles.
- Effects over a face, or over text while it is being read, except a light sweep after it has settled.
- Lens flares, stock glitch packs, or any effect that is copied from a recognizable template.
- Hiding an empty composition under effects. Remove the effects: if the frame no longer works, fix the composition first.
- A `requestAnimationFrame` loop, `renderer.setAnimationLoop`, `THREE.Clock`, or `getDelta` driving any state.
