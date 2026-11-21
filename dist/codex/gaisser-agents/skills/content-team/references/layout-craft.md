# Layout craft

Read this for every format: stills, carousel pages, and the settled frames of a video. The visual system wins on every brand value (palette, type families, margins, safe zones, image rules). These rules act on the free axes: grid, rhythm, line breaks, framing, and the placement of graphics. Each rule is `LY-nn` with the evidence that proves it, so the spec and QA can cite it.

## Fixed core and variable layer

The fixed core comes only from the visual system and repeats on every piece: palette roles, type families and scale, one signature element or sticker style, voice, margins, and safe zones. The variable layer changes per page and per piece: composition and focal point, layout archetype, accent dominance, photo crop, and the motion and transition vocabulary.

Archetypes, a closed list: `full-bleed-low` (text low over a wide frame), `full-bleed-high` (text high), `detail-crop` (tight crop on one object), `split` (photo and a type field side by side or stacked), `inset-frame` (photo inset on a palette field), `type-led` (type dominant, photo secondary or absent), `collage` (2-3 framed crops). When the visual system fixes the title block, archetypes differ in crop, focal side, and graphic layer, never in the block.

- LY-01: a carousel never uses the same archetype on two consecutive pages. Evidence: the spec's `## Layout list`.
- LY-02: the spec carries `## Layout list` with `Page | Archetype | Focal point | Crop | Accent dominance | Sticker quadrant`.
- LY-03: the caller passes the latest prior run folder, if any. When its `design-spec.md` has `## Layout list`, read only that table: the new archetype sequence must differ from it, and so must page 1's archetype.
- LY-04: never copy a CSS or HTML file from a prior run's `code/`; write the piece's own. Evidence: no sha256 match.

## Brand mode

The spec states `Brand mode: personal` or `Brand mode: product`, copied from `brief.md`. In `personal` mode the fixed core applies. In `product` mode (the subject is a product the user built), the visual direction comes from the product itself: its UI, colours, type, and function, taken from own-media screenshots in `assets.md` or from `ship.md`. Record it in a `## Product direction` table `Token | Value | Source`. The personal brand appears only as one small signature element (at most about 5% of the canvas area), plus margins and safe zones.

- LY-05: in `product` mode use the product's fonts only when their files are in the project; otherwise use the closest open font in the project and record it as such.

## Grid and rhythm

- LY-06: declare a column grid per format in the spec (columns, gutter, margins from the visual system, else 6 columns with 64 px margins at 1080 wide).
- LY-07: use a baseline unit of 8 px; every box edge sits on a column line or a baseline multiple.
- LY-08: gaps between elements are baseline multiples. Evidence: `layout-report.json` boxes.

## Type and line breaks

- LY-09: adjacent hierarchy levels step at least 1.2x unless the visual system fixes the sizes; at most 4 sizes per page.
- LY-10: display leading 0.95-1.05, text leading 1.3-1.45.
- LY-11: `text-wrap: balance` on titles and `text-wrap: pretty` on subheads.
- LY-12: no widow: the last line is at least 30% of the longest line.
- LY-13: no line ends in a stranded short word. Spanish: `a, al, de, del, el, en, la, las, lo, los, un, una, y, o, con, por, para, que`. English: `a, an, the, of, to, in, on, and, or, for`. Other languages: any 1-2 letter word.
- LY-14: a forced break with `<br>` is layout only, never copy. QA normalises whitespace before it compares `innerText` with `copy.md`.

## Composition with the photo

- LY-15: find the focal subject and the quietest zone first; a short script ranks candidate text zones by luminance variance.
- LY-16: the key phrase is the largest and most contrasted element on the page.
- LY-17: choose framing and focal point inside the image treatment rules of the visual system.
- LY-18: never put text over a face or a readable screen.

## Graphics and stickers

- LY-19: each graphic anchors to a subject, a surface, an edge, or a grid line, and the spec names the anchor.
- LY-20: its content relates to the page's copy, not generic interface chrome.
- LY-21: one light direction and one shadow spec per piece; sizes come from one scale.
- LY-22: at least 24 px from any face box; at most one deliberate grid break per page.

## Sequence

- LY-23: give each page a role (hook, build, turn, payoff).
- LY-24: in a carousel of 5 or more pages use at least 2 framing variants.
- LY-25: no quadrant holds more than 60% of the stickers across pages.
- LY-26: when the visual system fixes the brand block, vary framing and the graphic layer, never the block.

## Polish

- LY-27: optical alignment of italic overhang to the margin.
- LY-28: no near-miss edges (2-8 px gaps that read as errors).
- LY-29: consistent stroke widths.

## Layout report

In a single-piece spec `## Layout list` and `## Critique` are `##`; in a multi-piece spec each is `###` under the piece's heading.

For every still page and every video checkpoint, write `out/<piece>/layout-report.json`. It lists the declared grid, and per element its id, layer, box, rotation, computed font size and line height, and per-line widths measured through `Range.getClientRects`, plus the spec's face boxes. Rotated stickers are measured by their unrotated box.

## Critique pass

After the draft render, build `out/<piece>/critique-board.png` with `magick montage` from the draft pages and the 3 scout references named in art direction. Write `## Critique` in the spec: per page, the first read (what the eye hits first and whether it is the key phrase) and up to 3 findings, each `major` or `minor`, with IDs and the fix. Fix every major, render again, and mark them fixed. One round only. References are compared, never copied.

## Thresholds

QA computes these from `layout-report.json` at every still page and settled state:

- Grid edges within 2 px for at least 90% of edges.
- Type step at least 1.2.
- Last line at least 30% of the longest line; stranded words 0.
- Sticker clearance at least 24 px.
- Quadrant share at most 60%.
- Consecutive repeated archetypes 0.
- CSS or HTML files identical to a prior run's `code/` files 0, compared by sha256.
- The archetype sequence differs from the prior run's `## Layout list` when one exists.
