# UI craft for prototypes

Read this before you design screens or build `ux/prototype.html`. It gives the rules that make a prototype look designed, not defaulted, and the checks the reviewer runs on it. Each rule is `UI-nn`. The product context and the user's own design system win where they set a value.

Optional sources, read when found in the user's skills or plugin folders (`~/.claude/skills/`, `~/.agents/skills/`, `~/.claude/plugins/`): `frontend-design`, `design-critique`, `design-system`, `accessibility-review`, `ux-copy`. They are short; read their `SKILL.md` directly.

## Tokens

- UI-01: one `:root` block holds every token: a type scale with a ratio of 1.2 to 1.333, a 4 px spacing base, 2 to 3 radii by hierarchy, at most 3 elevations, and 4 to 6 named colours plus semantic ones (success, warning, danger).
- UI-02: every other rule uses `var(--...)`. Outside `:root` there is no raw colour and no raw `px` font size.
- UI-03: the prototype has exactly one `:root` block.

The reviewer finds breaks with these patterns, applied to the prototype text outside the `:root` block:

- Raw colour: `[:,(][ ]*#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(`
- Raw font size: `font-size:[ ]*[0-9.]+px`

### Token derivation

Each product derives its own tokens from its purpose, users, and function. Never reuse another product's tokens or the personal brand's palette or type families. `ux/flows.md` `## Visual design` has a `### Token derivation` subsection that gives, per token group (type, spacing, radii, elevation, colour), the reason it was derived from this product.

## Layout and hierarchy

- UI-04: one primary action per screen; secondary actions look weaker.
- UI-05: line length at most 75ch, and a maximum content width at desktop.
- UI-06: declare the alignment (left edge, centre axis) and keep it across screens.
- UI-07: group by proximity first; use borders and fills second.
- UI-08: the most important element on the screen is the largest or most contrasted one.

## States

- UI-09: empty, loading, and error states are designed, never plain text: an icon or illustration slot, a message with the next action, and a primary action.
- UI-10: loading shows the shape of what is coming (a skeleton), not only a spinner.
- UI-11: hover, active, disabled, and selected states exist for every control and use tokens.

## Accessibility floor

- UI-12: text contrast at least 4.5 to 1; non-text contrast at least 3 to 1.
- UI-13: touch targets at least 44 px by 44 px.
- UI-14: a visible `:focus-visible` style on every interactive element.
- UI-15: every input has a visible label; colour is never the only signal.

## Avoid defaults

Each item may stay when the product context calls for it, with the reason in `## Visual design`.

- UI-16: identical rounded cards with the same shadow everywhere.
- UI-17: decorative gradient washes behind content.
- UI-18: an eyebrow label above every heading.
- UI-19: an arrow appended to every button.
- UI-20: a generic icon set with no tie to the product's nouns.

## Screen links

- UI-21: every screen opens by `#screen=<id>`, where the id is the one listed in `## Screens`, so a screenshot or a reviewer reaches it directly.
- UI-22: opening the file with no hash shows the first screen of the main flow.

## Critique

- UI-23: screenshot the two most important screens at 390x844 and at 1280x800 with the installed Chrome or Edge: `--headless --screenshot=<png> --window-size=<w>,<h> <file url>`. Save them in `ux/shots/`. Edge headless clamps the window width to about 504 px, so a 390 px shot would be a crop: for it, screenshot a small harness page that holds `<iframe src="prototype.html#screen=<id>" width="390" height="844">` with a window at least 520 px wide, or use the Playwright device-metrics route of UI-24.
- UI-24: when the headless flags fail, use the Playwright route with `channel: 'msedge'` if it is installed; otherwise critique from the code and say so.
- UI-25: look at each shot and record the first read (what the eye hits first), hierarchy, consistency, and accessibility findings, each `major` or `minor`, with `UI-` IDs. Use the headings of `design-critique` when it is installed.
- UI-26: fix every major, render the two screens again, and write the result under `## Critique` in `ux/flows.md`. One round only.
