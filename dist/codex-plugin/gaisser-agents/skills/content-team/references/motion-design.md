# Motion design

Read this before you design any video or animated piece. It gives the defaults for every motion value. Slot `## 10. Motion` in `visual-system.md` wins wherever it is filled; where it is empty, use the defaults here and mark each one `default: motion-design.md` in the spec. Brand values (palette, type, fonts) still come only from the visual system.

## The bar

Every frame is designed, not just the first. A viewer who pauses at any moment should see a composed image. Motion carries meaning: it shows what comes first, what belongs together, and where to look next. Things that only slide in and sit still are not motion design; they are a slideshow.

Before you build, write one sentence for the piece's motion idea, for example "everything is pulled toward the centre like a magnet" or "the layout is a sheet of paper that folds into the next scene". Every scene and transition must serve that idea.

## Duration scale

Use these steps; never an arbitrary number.

| Token | Seconds | Use for |
|---|---|---|
| `instant` | 0.10 | colour or opacity flicker, cursor blink |
| `quick` | 0.20 | small UI elements, icons, a single word |
| `base` | 0.40 | a text line, a card, most entrances |
| `slow` | 0.70 | a large shape, an image, a camera move inside a scene |
| `scene` | 1.00 | a full-frame transition |
| `drift` | 3.00 and up | ambient movement that never stops: background gradients, slow parallax, grain |

Larger and heavier things move slower. Exits are about 25 percent shorter than entrances.

## Easing

Never use linear easing for anything except ambient drift and continuous rotation. GSAP names:

| Token | GSAP ease | Use for |
|---|---|---|
| `enter` | `expo.out` | most entrances: fast start, soft landing |
| `exit` | `power3.in` | exits: they accelerate away |
| `move` | `power3.inOut` | an element moving from one place to another on screen |
| `snap` | `back.out(1.6)` | playful emphasis, stickers, icons, small badges; at most once per scene |
| `spring` | `elastic.out(1, 0.5)` | rare; one accent per piece at most |
| `drift` | `sine.inOut` | ambient loops, with `yoyo: true, repeat: -1` |

## Choreography

- Stagger related elements: 0.04 to 0.08 s between letters, 0.06 to 0.12 s between words, 0.10 to 0.18 s between lines or cards.
- Overlap the steps. The next element starts before the previous one lands (GSAP position `"-=0.25"` or `"<0.1"`). A timeline where each step waits for the last feels robotic.
- Lead with the most important element, then the supporting ones, then the decoration.
- Move from the direction the eye is already travelling. If the last scene exited left, the next one enters from the right.
- Animate several properties together: position plus opacity plus a little scale or blur reads as one confident move. Opacity alone looks cheap.
- Keep at most 3 independent motions on screen at once, ambient drift excluded.
- Give everything a layer depth (background, middle, foreground). Deeper layers move less and slower, which creates parallax.

## Pacing for short-form video

- The first 1.5 s must show motion and the hook. No logo intro, no fade from black.
- Something visibly changes every 1.5 to 3 s: a new line, a camera move, a colour shift, a cut.
- No static stretch longer than 2 s, except a final call to action, which may hold up to 3 s while ambient motion continues.
- Hold a text line on screen for at least 0.25 s per word, plus 0.5 s, before it leaves.
- Build to a peak around 70 to 85 percent of the duration, then resolve.
- When the piece has music, cut and land key moves on the beat; list the beat times in the spec.

## Transitions between scenes

Pick from this set and vary them; never use the same transition three times in a row.

| Transition | How it is built |
|---|---|
| Match cut | An element of scene A becomes an element of scene B: same position, shape, or colour, then it morphs |
| Push | Scene B pushes A out of frame along one axis, both moving together with `move` easing |
| Mask wipe | A shape (circle, diagonal bar, text glyph) grows to reveal B underneath, using `clip-path` |
| Zoom through | Scale into a detail of A until it fills the frame and becomes B's background |
| Whip | Fast motion blur sideways (0.25 s) hiding the cut |
| Colour flood | The accent colour floods the frame, then recedes to reveal B |
| Hard cut on the beat | A plain cut, but only on a music beat or a spoken stress |

A plain crossfade is the last resort and must be justified in the spec.

## Camera

Treat the frame as a camera, not a page. Use a slow push-in (scale 1.00 to 1.06 over the scene), a drift (8 to 20 px over the scene), or a rack focus (blur the background from 0 to 6 px while the foreground enters). A completely still camera is a choice you state in the spec, not a default.

## Never

- Bounce or elastic easing on body text.
- Moving text while it must be read: it settles first, then holds.
- Flashing faster than 3 times per second.
- Spinning text, rainbow cycles, or stock "PowerPoint" effects such as fly-in from a corner with no easing.
- Animating everything at once with the same duration and ease.

## Spec format

The timeline section of `design-spec.md` lists, per scene: start and end time, the camera move, and one row per element with the element id, the property, from and to values, start time, duration token, and ease token. List the transition into the next scene by name. Add a `## Checkpoints` list: the time of every scene's settled state, every transition midpoint, and every caption change. QA reviews the piece at those times.
