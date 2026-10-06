# Content team design system proposal

Date: 2026-10-03. Status: design hypotheses for review and testing; no style has been accepted by the user.

The team should make a clear promise, show credible material, and deliver a satisfying payoff. Visual polish supports that sequence. A production chooses one coherent recipe, then tests hook and pacing variants against its own audience; aesthetics alone cannot establish virality. Vendor availability and platform limits belong in the dated integration matrix, not in permanent visual tokens.

Evidence anchors supplied by the integration research: [TikTok Creative Accelerator](https://ads.tiktok.com/business/creativecenter/quicktok/online/tiktok_creative_accelerator/pc/en) provides platform-native creative and safe-zone guidance in an advertising context; it is not proof of organic performance. [YouTube Shorts analytics guidance](https://support.google.com/youtube/answer/12942217?co=YOUTUBE._YTVideoType%3Dshorts&hl=en) grounds platform-defined metrics. The numeric layout, timing, typography, and pilot thresholds below are proposed team defaults, not vendor-endorsed performance guarantees.

## Format profiles and deliverables

These are proposed production canvases, not claims about every platform's current upload API. Validate the requested distribution path before selecting a profile. Export separate derivatives instead of stretching one finished layout into every ratio.

| Profile | Canvas | Proposed use | Deliverable |
|---|---|---|---|
| `carousel-portrait` | 1080x1350, 4:5 | Default feed carousel pilot | Ordered PNGs, JPEG derivatives, ZIP, contact sheet, alt text, copy |
| `carousel-square` | 1080x1080, 1:1 | Alternate feed destination | Reflowed pages with own QA |
| `carousel-tall` | 1080x1440, 3:4 | Only if chosen app/destination path supports it | Separate derivative; never assume API compatibility |
| `short-portrait` | 1080x1920, 9:16, 30 fps | Default short-video pilot | H.264 MP4 with AAC audio, cover, captions SRT, full render |
| `landscape-video` | 1920x1080, 16:9 | Explainers, presentations, editor handoff | Reframed timeline and landscape title layout |

Keep lossless still masters before JPEG encoding. Keep editable source, font references/licenses, input hashes, color-space choice, and backend lock beside exports in the private project. A flattened MP4 or PNG is delivery, not a promise of editable layers in Canva, Adobe, or another editor. Platform-specific file-size/codec requirements are dated adapter constraints. Default sRGB stills; video color conversion is explicitly declared and visually reviewed.

## Visual token contract

`composition.json` uses semantic values: `canvas`, `grid`, `safeRegions`, `palette`, `type`, `spacing`, `shape`, `imageTreatment`, and `motion`. The private visual-system context maps these roles to the user's palette and licensed local fonts. Public recipes carry role names and neutral fallbacks, never personal font files or brand data.

| Token or rule | Proposed starting value at 1080-pixel width | Measurable check |
|---|---|---|
| Carousel safe content | 72 px left/right; 80 px top/bottom | All required text/subjects inside the rectangle |
| Video safe content | x 90-930; y 240-1500 | Simulate destination overlays; override with verified profile |
| Grid | 12 columns, 24 px gaps; spacing multiples of 8 px | Layout bounds and alignment inspection |
| Display text | 80-120 px, weight 600-800, line-height 0.95-1.10 | Maximum three title lines; no clipping |
| Body text | 44-56 px, line-height 1.15-1.35 | Read at a 360 px-wide preview without zoom |
| Supporting labels | 32-40 px; nonessential material only | Never shrink essential claims into a footnote |
| Video captions | 48-64 px, maximum two lines | Word timing and full-playback review |
| Font families | Maximum two families; default system sans | Record resolved font, glyph coverage, license/source |
| Palette | Background, surface, primary text, secondary text, one accent | Required text contrast at least 4.5:1 on final local background |
| Text budget | Hook 5-12 words; page body 20-45 words | Word count; split into another page rather than shrink |
| Density | One dominant element and one primary takeaway per page/scene | Reviewer can state the takeaway in one sentence |
| Imagery | Real crop, clear focal subject, evidence where useful | No accidental PII, false provenance, or stretched image |

Thresholds are production hypotheses, not a claim of full accessibility certification. Measure contrast at the actual composited text/background, including photographed regions and animation frames. Meaningful footage is not assessed by forcing all pixels into a UI contrast ratio. Labels with insufficient room move to a larger page or caption; alt text and a transcript carry equivalent information. Distinguish annotations from the underlying evidence image.

At export, test a full-resolution render and a 360 px-wide preview. Scan every required text box for overflow, missing glyphs and truncation. Long languages get an alternate layout with equivalent hierarchy. Never use a lower type size merely to preserve an arbitrary page count. Keep source screenshots readable or crop/annotate the relevant area.

## Carousel story and recipes

Starting length: 6-8 pages. Page 1 states one specific promise and creates interest without inventing a result. Page 2 supplies proof or identifies the viewer's situation. Middle pages each deliver one insight, ordered as a progression. Penultimate page synthesizes the result; final page gives one concrete action appropriate to the content. Six-page fixture: promise, evidence, problem, explanation, outcome, CTA. Numbers, arrows, diagrams, and page indicators are optional semantic tools, not inherited bans.

| Recipe | Visual direction | Page structure | Best initial hypothesis | Failure to avoid |
|---|---|---|---|---|
| `evidence-editorial` | Quiet background, bold sans headline, one authentic image/crop, restrained annotation | Hook with evidence image; annotated detail; insight; comparison; result; useful CTA | Credible project progress and explainers produce saves/shares | Decorative marks obscure proof or tiny screenshot text |
| `swiss-explainer` | Strong grid, large typography, solid accent, diagrams with consistent line weight | Claim; setup; three progressive explanations; takeaway; optional CTA | Complex ideas become easier to understand and save | Poster aesthetics exceed the page's reading budget |
| `cinematic-story` | Large own-media crop, controlled gradient, minimal overlay, repeated caption placement | Situation; tension; attempt; turning point; payoff; reflective action | A real human/process narrative encourages continuation | Dark images swallow text or suspense delays all value |

Recipe controls: anchor `title`, `evidence`, `body`, and `footer` positions; vary image scale/crop and emphasis while retaining the grid. Use a recurring accent to connect the sequence. Start with 2-3 layout variants per recipe, not eight unrelated posters. A brand may choose maximalist color or texture by overriding tokens, but required content remains readable. Raster effects stay behind semantic text and evidence.

Render canonical pages independently. Every page has `pageId`, `purpose`, `copy`, `assetIds`, `layoutId`, `altText`, and `sourceClaims`. Ordered filenames such as `01-hook.png` preserve sequence. A contact sheet helps sequence review but does not replace full-resolution privacy/readability checks. Publish-ready stills are individual PNG/JPEG files and a ZIP; a slide deck is optional editor interchange.

## Short-video story and recipes

Start with 15-45 seconds. Duration follows the promise and available footage, not a fixed algorithm. The standard fixture is 30 seconds: hook 0-2 s, evidence/context 2-6 s, three story beats 6-22 s, payoff 22-27 s, CTA or clean ending 27-30 s. An honest result can appear immediately and be explained afterward. Never manufacture a suspense loop that withholds the promised outcome.

| Recipe | Composition and editing | Suggested beat rhythm | Initial metric hypothesis |
|---|---|---|---|
| `proof-first-demo` | Show real output in opening; cut to process/detail; concise labels and captions; final result comparison | 1-3 s evidence shots; hold complex detail 3-5 s | Strong first-second proof improves early retention |
| `kinetic-explainer` | Typography/diagram animation over neutral background; one emphasized word or concept; meaningful own footage insert | 2-4 s conceptual beats; timed build instead of random transitions | Clear mental progression improves completion and saves |
| `cinematic-process` | Own footage, wide/detail/action shot variety; controlled color; restrained titles; use real sound texture | 2-5 s shots; longer 4-6 s payoff where useful | Authentic process and sensory detail improve watch time and shares |

Each scene specifies `sceneId`, `startFrame`, `durationFrames`, `assetIds`, `crop`, `text`, `captionCueIds`, `transition`, and optional `audioEvents`. All timings are integer frames in the master frame rate; the last scene ends on the intended duration. Video cuts use actual source in/out timestamps and audio synchronization, not invented clip lengths. An AI-generated take, if permitted, is indexed as generated and never represented as documentary footage.

## Optional long-form and thumbnail derivatives

Long-form uses the same script, scene, caption and asset contracts, adding chapter IDs, chapter promises, scene ranges and source claims. Agree the requested duration from the topic and footage before rendering. Each chapter supplies context, evidence and a payoff, with a meaningful transition; do not stretch the short-form cut rhythm over an entire explainer. Review the full video and chapter boundaries for continuity, pacing, audio and caption consistency. This is a future extension beyond the initial short-form fixture.

A thumbnail or cover is a separate composition profile with its own canvas, crop/safe area, essential subject and short truthful title. Propose two variations differing in one main element; inspect legibility at a 180 px-wide preview and verify that image/title match the actual video. Record each export hash and selected variant in the render/delivery reports. Thumbnail performance follows the destination's own impression/click definitions and actual available experiments; an attractive design does not prove higher click-through. A cover crop and a landscape thumbnail may need different layouts.

Repurposing selects a self-contained chapter or argument, gives it a native short/carousel hook and payoff, and writes a new brief referencing the source run, asset IDs and scene ranges. It gets independent layout, QA and approval rather than merely cropping the long-form export.

## Motion, sound, and captions

Use motion to direct attention, explain a relationship, or join scenes. Static shots are valid; constant motion is not mandatory. Most emphasis is a simple scale, translate, opacity, or reveal with an eased end. Reserve high-energy motion for recipes whose footage and audience support it.

| Property | Proposed default | QA condition |
|---|---|---|
| Title entrance | 8-14 frames at 30 fps; translate no more than 24 px | Title settles before its main reading interval |
| Emphasis | One focal animation at a time; scale 1.00 to at most 1.05 | No simultaneous competing essential text |
| Transition | Cut or 6-10 frame dissolve; directional reveal only for a relationship | No transition hides evidence or chops spoken words |
| Text hold | At least `max(2, words / 3)` seconds once stable | Every essential overlay has a measurable reading interval |
| Captions | Speech-synchronized groups, usually 3-6 words, two lines at most | Transcript checked against audio and technical glossary |
| Motion comfort | No flashing recipe; reduced-motion still variant where suitable | Full-playback review for unintended flicker and discomfort |
| Audio | Speech clear; music ducked; default target -16 LUFS integrated, true peak at most -1 dBTP | Measured loudness; listening on phone/headphones, adjust to destination |

Overlay reading intervals may overlap narration but do not force the viewer to read one idea while listening to a different essential idea. Captions obey actual speech timing rather than the overlay formula. If narration is too fast, shorten copy or extend the scene. Music has recorded rights and permitted destinations; trending app audio may require a manual in-app finishing step. No musical track or synthetic voice is selected merely because an app can generate it.

Review the complete audio track for cut words, silence, clipping, pronunciation, sync, and licensed usage. Loudness measurements cannot prove intelligibility. Caption transcription is a draft until verified; mark low-confidence terms for correction. Silent viewing should preserve the main message; an equivalent transcript remains available for information conveyed in audio.

## Coded rendering and editor handoff

The canonical script and composition are shared across backends. Deterministic code can create still layouts, charts, annotations, masks, typographic animation, subtitles, motion diagrams, and 3D scenes. It can crop or compose real photos and cut real footage. Generative pixels are a separate optional input class with distinct rights/disclosure review.

| Backend family | Recommended responsibility | What the contract must expose |
|---|---|---|
| SVG/HTML + configured rasterizer/browser | Carousels, covers, diagram stills | Font resolution, asset loading, canvas/color, screenshot bounds |
| FFmpeg | Own-footage montage, compositing, captions, audio, delivery codec | In/out points, frame rate, scaling, filter settings, audio mix |
| Remotion | Parameterized React compositions and reusable motion | Dependency lock, scene props, fonts, frame schedule |
| Manim | Mathematical/technical explanatory animation | Scene parameters, seeds, renderer/version, text support |
| Blender | Optional 3D diagram or product animation | Scene assets, camera/light settings, render engine/version |
| Supported editor adapter/manual package | Final polish or editable vendor master | Imported elements, lost features, editability, export procedure |

Do not implement all backends initially. Pilot SVG/HTML stills plus FFmpeg montage; add Remotion when shared motion templates justify the dependency. An adapter may rasterize a label or flatten a timeline; state that loss in the delivery report. Give a manual editor package ordered assets, captions, copy, scene timing, source provenance, and preview so the user can finish in an editor whose automation is unavailable.

## Quality gates

1. Editorial: promise/payoff match, one main takeaway, claims have sources where needed, copy fits audience/language, one suitable CTA.
2. Visual: no essential overflow, glyph loss, stretched imagery, unreadable contrast, blocked evidence, or overlay collision. Every still and video overlay meets its specified safe-region and reading checks.
3. Temporal: full playback checks all cuts, captions, transitions, continuity and audio; frame sampling is supplementary. Inspect every scene boundary and caption-change frame at full resolution.
4. Privacy and provenance: full-resolution PII review; remove secrets before upload; record rights and generated/synthetic classes. Missing metadata is not proof of non-generated media or license validity.
5. Technical: dimensions, page sequence, duration, frame rate, codec, audio peaks, file limits, hashes and export completeness match the target adapter's current validated profile.
6. Delivery: local files and any editable reference match the approved revision; changed files invalidate approval. Human taste review checks whether the chosen recipe serves the story.

QA records `pass`, `fail`, or `limited` per check with evidence and artifact owner. Automatic pixel checks cannot certify all privacy, factual truth, storytelling, or music rights. A missing full-duration review is `limited`, never silently `pass`. Design mistakes return to the designer; copy/claim/caption mistakes to writer; corrupted export and timing implementation defects to renderer.

## Measuring performance without a viral promise

Define one primary objective per piece and record a baseline from comparable recent content. Start with three hook hypotheses, then choose a concept using audience relevance, truthful evidence, production effort, and the promised payoff. A beautiful design and a high-retention hook are separate hypotheses.

Organic recommendation evidence supports measuring viewer response rather than declaring a universal aesthetic. TikTok describes personalized ranking using interactions such as watching or skipping, likes and shares, alongside content and user information; these signals vary by person and surface. The inference for this team is to test retention and relevance within a defined audience, not assume one recipe wins everywhere. [TikTok recommendation explanation](https://support.tiktok.com/en/using-tiktok/exploring-videos/how-tiktok-recommends-content).

Metric definitions also matter: Meta's April 2023 Reels announcement defined total watch time as including replays and average watch time as watch time divided by total plays. This is historical documentary evidence, not confirmation of the current account UI/API definition. Refresh the actual current analytics/export definitions before calculating rates or comparing platforms, and retain the dated definition with each result. [Meta's 2023 Reels metrics announcement](https://about.fb.com/news/2023/04/instagram-reels-trending-audio-and-gifts-updates/).

| Format | Primary candidate metric | Secondary checks | Availability caution |
|---|---|---|---|
| Carousel | Saves or shares / reach | Profile visits, qualified actions, feedback on readability | Swipe depth/completion may be unavailable; never infer from total views |
| Short video | Completion rate or mean watch time / duration | Early retention, shares/reach, qualified actions | Use platform-defined denominators and distinguish repeats/plays from unique reach |
| Conversion-oriented piece | Qualified actions / attributed exposure | Saves/shares and audience relevance | Attribution is often partial; record method and missing data |

Capture metrics at consistent 48-hour and 7-day windows where available, with platform timezone, collection timestamp, definitions, source and denominator. Run sequential organic variants on comparable topics/times and describe them as directional; they are not randomized experiments. Genuine paid/randomized tests require equivalent distribution and a predeclared sample/stopping rule. Avoid changing hook, visual recipe, audio, and posting time together when isolating a cause.

First pilot: six carousels and six short videos, using the three recipes twice within each format. This is a feasibility and taste sample; do not label small differences statistically proven. Record production minutes, cost, human revisions, content defects, accessibility feedback, and normalized performance alongside raw views. Review medians and outliers against the account baseline; keep valuable low-reach content when it fulfills the intended objective.

After the pilot, recommend one recipe to keep, one hypothesis to revise, and one new controlled variation. Trends come from dated platform-native observation and primary creator/platform material; log trend expiry and origin. No fixed template, external view-count ranking, or generic "viral score" substitutes for audience evidence.
