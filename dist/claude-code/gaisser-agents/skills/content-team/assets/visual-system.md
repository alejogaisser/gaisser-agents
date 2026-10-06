# Visual system

Fill every slot in your own project. Leave nothing here as an example value. Every rule must be checkable against a rendered pixel. Mark any value that was not taken from a design original or a written specification as `needs-confirmation` and write the evidence beside it.

## 1. Canvas and safe margins
One row per format.

| Format | Width in px | Height in px | Margin top | Margin right | Margin bottom | Margin left |
|---|---|---|---|---|---|---|
| (format) | | | | | | |

Required text and subjects must sit inside the margins.

## 2. Palette by named role
Roles are fixed; values are yours.

| Role | Value | Contrast floor against |
|---|---|---|
| background | | |
| surface | | |
| primary text | | |
| secondary text | | |
| accent | | |

## 3. Type scale
One row per level. A level without a when-to-use rule is incomplete.

| Level name | Size in px at canvas width | Weight | Line height | Case | Italic | Max lines | When this level is used |
|---|---|---|---|---|---|---|---|
| (level) | | | | | | | |

## 4. Image treatment
- Bleed or inset:
- Gradient or scrim (direction, extent, opacity):
- Focal-point rule:
- Rule for a vertical source:
- Rule for a horizontal source:
- Rule for a missing image:
- Rule for a dark image:

## 5. Decorative elements
- Taxonomy of elements:
- Maximum count per page:
- Zones they may occupy:
- Rotation range:
- May cover:
- May never cover:

## 6. Hard prohibitions
Each ban must be checkable by QA.
- Prohibition 1:
- Prohibition 2:

## 7. Per-format overrides
Overrides to canvas, type scale, or margins, by format and by page position where needed.

| Format | Page position | Overrides |
|---|---|---|
| (format) | | |

## 8. Fonts
Font files stay in your project and are never committed to a shared repository.

| Family | Weights | Source | Licence | Fallback family | Project-local path |
|---|---|---|---|---|---|
| | | | | | |

## 9. Precedence
- What wins when a per-format override conflicts with a global rule:

## Open list
Cases the sources do not settle. Always include a title too long for its level, a photo that is dark or missing, and a page with no suitable decorative element.
- Case:
