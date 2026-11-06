# Kinetic typography

Read this when text moves on screen, which in short-form video is almost always. Text is the main actor of most social videos: it must look designed while it moves and be easy to read once it lands.

## Split the text

Split each string from `copy.md` into lines, words, or characters with the `SplitText` plugin from GSAP (free), never by retyping it. Keep the original string as the element's accessible text and keep line breaks from the copy. Choose the unit by the string's role:

| Role | Unit | Why |
|---|---|---|
| Hook or title, 1 to 6 words | characters or words | big, punchy, worth the detail |
| A sentence on screen | words | readable as it builds |
| Several lines | lines | the eye reads line by line |
| Caption synced to voice | words, highlighted as spoken | karaoke-style follow-along |

## Reveal patterns

Use these as building blocks. Combine at most two in one string.

- **Mask rise:** each line sits in a container with `overflow: hidden`; words rise from `yPercent: 110` to `0` with `expo.out`, staggered 0.06 s. The default for titles.
- **Blur in:** words go from `filter: blur(12px)`, `opacity: 0`, `y: 20` to sharp, staggered 0.05 s. Soft, premium.
- **Scale punch:** one word goes from `scale: 1.4`, `opacity: 0` to `scale: 1` with `power4.out` in 0.3 s. For the single most important word.
- **Typewriter with caret:** characters appear at 25 to 40 per second with a blinking caret. Only for code, chat, or search themes.
- **Slot or rolling numbers:** digits roll vertically to their value. For any number on screen.
- **Track in:** `letter-spacing` goes from 0.4em to the type level's value while the opacity fades in. Elegant for short labels.
- **Draw on:** the outline of display text is stroked with an SVG path (`stroke-dashoffset`), then filled. For a logo or a single word.

## Emphasis

- Highlight one word per line at most: the accent colour, a heavier weight, a marker sweep behind it (a rectangle scaling `scaleX` from 0 to 1 from the left), or an underline drawn on.
- Time the emphasis 0.1 to 0.2 s after the word lands, not at the same moment.
- When there is a voiceover, the emphasis lands on the spoken stress.

## Exits

Text leaves before the next text arrives, or the new text pushes it out. Patterns: mask fall (words drop out of the mask), blur out, or the whole block moves with the camera. Exits use the `exit` ease and are shorter than entrances.

## Captions

- Place them inside the platform's safe zone (see `video-pipeline.md`), usually the lower middle third above the app's caption area.
- At most 2 lines and 32 characters per line; one idea per caption.
- Change captions on phrase boundaries, never mid-phrase.
- The active word is highlighted while it is spoken; the others stay at the secondary text colour.
- Take timings from the voiceover file or the writer's beats, and list every caption change in the spec's checkpoints.

## Readability rules

- Text holds still for at least 0.25 s per word, plus 0.5 s, after it lands.
- Contrast is measured on the settled frame and must meet the floor in `visual-system.md`, including over moving backgrounds; use a scrim or a surface behind text on busy footage.
- The minimum on-screen size is the smallest type level in `visual-system.md`. Never shrink a long title below it; apply the visual system's rule for a title too long for its level.
- No more than one moving text block at a time.
- Never rotate or skew body text; display text may tilt up to 8 degrees.

## Fonts

Load fonts only from the project path in `visual-system.md` with `@font-face`, and wait for `document.fonts.ready` before the first frame is captured. Variable fonts may animate their weight or width axes for emphasis.
