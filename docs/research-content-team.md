# Research: a content-creator agent team for Claude Code (October 2026)

- Date: 2026-10-02. Author: architect subagent. Research only: no code, no implementation plan.
- Question: what should a content-creator agent team be able to do, and how far can it realistically go today?
- Inputs read: the user's existing Instagram carousel team (agents `ideas-carrusel`, `armador-slides`, `stickers-carrusel`, `qa-carrusel`, command `/carrusel`, style guide `estilo-carrusel.md`), the artifacts of its first real run, the user's installed plugins and skills (Postiz, Canva, marketing, design), and this repository's conventions (`CONTRIBUTING.md`, `catalog.json`, backlog in `docs/plan.md` section 17).
- External facts were checked on the web on 2026-10-02. Sources are numbered `[n]` and listed at the end. "(secondary)" marks facts taken from third-party sites rather than the vendor.
- Privacy: the repository is public and this file is not git-ignored, so it names no accounts, design IDs, or personal data.

## 0. Summary

1. The realistic target is a team that does the desk work: strategy, ideas drawn from real material, scripts and copy, code-rendered graphics, carousel assembly, code-based video editing with local captions, QA, scheduled drafts, and the metrics loop. Capturing photos, footage, and voice, taste decisions, in-app trending audio, and the final publish stay with the user.
2. Local-first beats browser-first. The first real carousel run went "curl + MCP, no browser": titles were rendered with Python/Pillow and uploaded to Canva through the MCP's single-use upload URL [2]. The browser (Claude in Chrome) should be a fallback.
3. Video works locally on Windows with free tools: FFmpeg, Remotion (free for individuals) or HyperFrames (Apache-2.0, built for agents), Manim for engineering explainers, and Whisper for captions [29][31][33][35]. Claude cannot watch video, so video QA must rely on frame sampling, ffprobe, and loudness measurement.
4. CapCut has no public editing API and its terms forbid automated interaction [4]. Midjourney forbids automation [20]. Sora is gone: the app closed on 2026-04-26 and the API on 2026-09-24 [18]. Descript (API, plus an MCP connector since June 2026) is the only mainstream editor with an official path for agents [8][9].
5. Generative video and image tools (Higgsfield, Runway, Kling, Veo) all have APIs or MCP servers and cost little per clip, but they conflict with the user's "no AI images" rule and with platform originality and disclosure rules. Keep them out by default.
6. Postiz (already installed) covers 28+ channels through API, CLI, and MCP, supports drafts, and reports analytics [40][42]. Platform limits still apply. The most important one for this user: the Instagram publishing API accepts only images between 4:5 and 1.91:1 [47], so the current 3:4 (1080x1440) carousels cannot be scheduled through any API. They must be posted by hand, or a 4:5 version must be rendered.
7. Human approval for anything public must be enforced by the permission system, not by prompt text. Agents create drafts only. A PreToolUse hook or an `ask` permission rule guards every publish or schedule call, and subagents can never publish [67].
8. Recommended roster: 5 agents (`content-strategist`, `scriptwriter`, `visual-builder`, `video-editor`, `content-qa`) plus workflow skills (`content-plan`, `carousel`, `short-video`, `social-post`, `repurpose`, `publish`, `content-report`). The 4 carousel agents map onto 3 of them.
9. Packaging this team in gaisser-agents needs build changes: a way to grant MCP tools whose names depend on the installation (claude.ai connectors appear with UUID prefixes on this machine), plugin-level hooks and possibly `.mcp.json`, skill assets, and a per-user brand kit that keeps personal style out of the public plugin.
10. Cost on top of the Claude plan: MVP $0 to $29 per month (Postiz Cloud is the only paid piece), video phase adds $0 to $6 per month (optional ElevenLabs Starter).

## 1. Starting point: the existing carousel team

### 1.1 What exists

| Piece | Role | Model | Notes |
|---|---|---|---|
| `/carrusel` command | Folder, then ideas, script, build and stickers in parallel, QA (at most 2 fix rounds), delivery. Canva commit only after the user's "ok" | main session | Spanish, user-specific |
| `ideas-carrusel` | Reads the photos (vision plus EXIF), transcribes visible text, proposes 3 ideas in `ideas.json` | opus | Read, Glob, Grep, Bash, Write |
| `armador-slides` | Uploads photos and title PNGs, composes pages in Canva, writes `build.json` | sonnet | Inherits all tools (Canva MCP, Chrome) |
| `stickers-carrusel` | Renders and uploads stickers, writes `stickers.json` | sonnet | Inherits all tools; own browser tab |
| `qa-carrusel` | Read-only checklist against the style guide, writes `qa-<n>.json` | haiku | Inherits all tools |
| `estilo-carrusel.md` | Look (3:4, palette, typography), copy rules, sticker catalog, technical flow | - | Bans AI images, slide counters, progress bars, "swipe" badges |

The workspace also has a `CLAUDE.md` with writing rules (hook in the first line, one idea per piece, a concrete CTA, every piece saved as a file), an unfilled brand profile template, an empty idea bank, and planned folders for scripts, X posts, a calendar, and published pieces with metrics.

### 1.2 Lessons from the first real run

- The run did not use the browser. `build.json` records a flow "via curl + MCP, without browser": titles were rendered locally with Pillow, a full-resolution composite preview was produced locally, and files reached Canva through `create-upload-url` plus a raw POST [2]. The style guide's browser-only upload rule describes cloud or VM sessions, where a proxy blocks canva.com. On the local Windows machine it is not needed.
- QA on the fast tier, looking at 450x600 Canva thumbnails, raised two false positives about privacy: it could not confirm that stickers covered personal data visible in the photos. The orchestrator overturned both with full-resolution crops. Lesson: visual QA needs full-resolution local renders and the standard tier. The fast tier is fine only for text or spec checks.
- Privacy is a first-class QA category. Screens in the photos showed an account email and a machine user name, and stickers were placed on purpose to hide them. Every visual workflow (photos, screenshots, screen recordings) needs a PII pass.
- The brand profile is still a template, so tone, audience, and pillars live only in the carousel style guide. The profile must be filled first. Subagents cannot ask the user questions [65], so the interview has to run in the main session.
- The two builder agents ran in parallel only because each needed its own browser tab. With local rendering, that parallelism is unnecessary and the "stickers not ready yet" handoff disappears.

### 1.3 What carries over

Reusable as is: the orchestration pattern (the main session talks to the user, subagents work in the background), per-piece file contracts (`ideas.json`, `guion.json`, `build.json`, `qa-<n>.json` with a `responsable` per problem), the 2-round fix limit, and the commit-only-after-OK rule. Not reusable as is in a public catalog: Spanish prompts, the user's palette, fonts and project names, and the browser-first technical flow.

## 2. What the team should be able to do

| Capability | Description | Owner (section 9) |
|---|---|---|
| Positioning | Fill and maintain the brand profile: audience, voice, pillars, banned phrases, AI policy | content-strategist (interview in the main session) |
| Planning | Weekly and monthly calendar with a format mix and cadence a student can sustain | content-strategist |
| Ideas from real material | Turn photos, footage, project repositories (git log, READMEs), and notes into ideas; keep the idea bank | scriptwriter |
| Scripts and copy | Hooks, carousel scripts, timed reel scripts, X threads, LinkedIn posts, newsletters, YouTube outlines, captions, alt text, hashtags, in Rioplatense Spanish | scriptwriter |
| Media curation | EXIF dates, visible text, faces and free zones, orientation; later a reusable media index | scriptwriter |
| Still graphics | Titles, stickers, diagrams, quote cards, thumbnails, all rendered by code | visual-builder |
| Layout and assembly | Carousel pages in Canva (editable) or local PNG, JPEG, PDF exports | visual-builder |
| Video editing | Cut lists from transcripts, motion graphics, captions, audio, exports per platform | video-editor |
| Screen recordings | Scripted captures of the user's projects | video-editor |
| Voice | Normally the user's own recording; optionally a clone of the user's own voice | user, video-editor |
| QA | Style, platform specs, PII, AI provenance, spelling and dialect, CTA | content-qa |
| Scheduling | Drafts in Postiz, scheduled only with the user's approval | main session (`publish` skill) |
| Repurposing | One pillar piece into native pieces per platform | content-strategist plus the others |
| Learning loop | Pull metrics, log them per piece, monthly review that updates pillars and hooks | content-strategist |
| Out of scope | Replies to comments and DMs, paid ads, autonomous posting | user |

## 3. Capability map (October 2026)

### 3.1 Feasible now (official APIs or local tools)

- Ideas, scripts, and copy for every format, grounded in the user's real material and brand profile.
- Photo curation with vision and EXIF (proven in the first run).
- Still graphics rendered by code: Pillow, or HTML and CSS captured with headless Chrome.
- Carousel assembly in Canva through the official MCP: upload URL, editing transactions, thumbnails, PNG and PDF export [1][2]. Fully local export is the alternative.
- Short-video editing by code on Windows with FFmpeg, Remotion or HyperFrames, and Manim [29][31][33].
- Local captions with Whisper (faster-whisper or whisper.cpp), as SRT or ASS, burned into the video [35][36].
- Scripted screen recordings with OBS (obs-websocket ships with OBS 28 and later) or FFmpeg `ddagrab` [38][39].
- Voice generation and cloning of the user's own voice through the ElevenLabs API or its hosted MCP; commercial use needs a paid plan [23][24].
- Transcript-based editing in Descript through its API and MCP: import, Underlord edits, transcripts, publishing to a web link [8][9].
- Drafts and scheduling to 28+ channels through Postiz (API, CLI, MCP), plus per-post and per-platform analytics [40][42].
- Calendar, idea bank, and metrics log as Markdown or CSV files in the workspace.

### 3.2 Partial: works, but limited or fragile

| Item | Limits |
|---|---|
| Browser automation (Claude in Chrome) | Works on Windows with Chrome or Edge. Needs a direct paid plan and `/login`, runs in a visible window, uploads at most 10 MB, pauses at logins and CAPTCHAs, and the extension can disconnect in long sessions [63] |
| Canva for video | MP4 export works; there is no timeline editing through the MCP [1] |
| Canva premium features | `resize-design` and brand templates need Pro; Connect API autofill needs Enterprise [1][3] |
| Canva uploads | Upload URLs are single-use and expire quickly; request one right before each upload [2] |
| Instagram via API | Professional account (Business or Creator) [48]. 100 API posts per rolling 24 h; carousels up to 10 items; no shopping tags or filters [46]. Images must be JPEG, at most 8 MB, aspect ratio 4:5 to 1.91:1; Reels 3 s to 15 min, at most 300 MB, 9:16 recommended [47]. Library music only as an account-dependent subset for single-video Reels (Postiz `audio` setting) [45] |
| TikTok via API | Unaudited apps can only post private videos [49]. Through Postiz you can direct-post, or upload to the TikTok app inbox so the user finishes the post by hand within 24 h [50] |
| LinkedIn PDF carousels | The Documents API takes PDF or PPT up to 100 MB and 300 pages [52]. Postiz builds the PDF from images (`post_as_images_carousel`) [44] |
| YouTube uploads | Uploads from unverified API projects stay private until an audit; uploads got a cheaper cost (December 2025) and their own quota bucket (June 2026) [53] |
| X | Pay per use only: $0.015 per post, $0.20 per post with a link, no free tier [51]. Relevant if Postiz is self-hosted |
| Word-level caption timing | whisper.cpp word timestamps are approximate; WhisperX alignment is better but heavier [36][37] |
| FFmpeg's built-in Whisper filter | Exists since FFmpeg 8.0 but needs `--enable-whisper`; common Windows builds do not enable it [34] |
| Motion Canvas | Rendering is driven from its editor; headless rendering is not first-class [32] |
| CapCut drafts | Unofficial projects write CapCut draft files (VectCutAPI and others); version-dependent and a terms-of-service gray zone [6] |
| Generative video and images | Technically easy through APIs or MCP; blocked by the style rule (section 8) |
| Analytics | Instagram insights through the API (views, reach, saves, shares; impressions were deprecated) (secondary) [57]. TikTok and X data are thinner; some numbers need manual exports |
| Desktop GUI control | Claude Code computer use is macOS-only in the CLI; on Windows only the Desktop app has it [64] |

### 3.3 Not feasible or not advisable

- Automating CapCut: no public editing API, no official MCP, and the terms forbid automated scripts that interact with the service [4][5].
- Automating Midjourney: no API, and the terms forbid automated tools [20].
- Sora: discontinued (app 2026-04-26, API 2026-09-24) [18][19].
- Posting by driving the Instagram, TikTok, or X websites: account risk. Use the official APIs through Postiz.
- Publishing to Substack by API: the official API only looks up public profiles [56].
- Scheduling the current 3:4 Instagram carousels through any API: rejected by the image aspect-ratio rule [47].
- Adding trending sounds programmatically: generally only possible in the apps.
- Autonomous publishing: excluded by policy (section 7.3).

## 4. Tools and integration paths

### 4.1 Design and editing apps

| Tool | Official API | Official MCP | CLI | Pricing and limits | Automation and terms risk | Fit with "no AI images" | Verdict |
|---|---|---|---|---|---|---|---|
| Canva | Connect API; autofill needs Enterprise [3] | Yes, `https://mcp.canva.com/mcp`, about 30 tools: search, designs, editing transactions, thumbnails, `create-upload-url`, export (PDF, JPG, PNG, PPTX, GIF, MP4). Per-tool limits of 20 to 100 requests per minute; resize and brand templates need Pro [1][2] | No | Free plan covers the carousel flow | Low (official) | `generate-design` and Canva's AI image features produce AI content; never use them | Keep as the editable assembly surface and upload local renders |
| CapCut | No public editing API; the developer offering covers plugins and a few AI endpoints (secondary) [5] | No; only unofficial draft writers [6] | No | Free, Standard, and Pro tiers (secondary) [7] | High: terms updated 2026-04-15 forbid automated interaction and grant CapCut a perpetual, sublicensable license over uploaded content [4] | Many features are AI | Manual use only, outside the automated pipeline |
| Descript | Yes: token per Drive; imports use media minutes, Underlord edits use AI credits, job history kept 30 days [8] | Yes, connector for Claude since June 2026; scoped to one Drive; no rendered-file download without publishing to a web link [9] | Yes [8] | Paid plans by minutes and credits | Low (official) | Transcription and audio cleanup are fine; its generative media tools are not | Optional for long-form transcript editing (Phase 3) |

### 4.2 Generative video and image (excluded by default, see section 8)

| Tool | API | MCP | Cost (checked September and October 2026) | Notes |
|---|---|---|---|---|
| Higgsfield | Pay-as-you-go API with 50+ models, from a $5 top-up; for example Kling 2.5 at $0.042 per second [10] | Hosted `https://mcp.higgsfield.ai/mcp` with OAuth; draws on subscription credits [11]; plans from about $19 per month (secondary) [12] | API and subscription billed separately | Aggregator of third-party models |
| Runway | Yes; $0.01 per credit: Gen-4 Turbo 5 credits per second, Gen-4.5 12, Aleph 2 28 [13] | Generation MCP for plan users and a developer-portal MCP [14] | Separate credit pools for app and API | |
| Kling | Prepaid packages from $700 for 5,000 units, valid 180 days; about $0.084 per second at 720p (secondary; the official page could not be read) [15] | Through aggregators | Much cheaper through aggregators | |
| Google Veo 3.1 | Gemini API: Lite $0.05 to $0.08 per second, Fast $0.10 to $0.30, Standard $0.40 to $0.60; no free tier [16] | Through aggregators | | Every output carries a SynthID watermark [17] |
| OpenAI Sora | Discontinued, API off since 2026-09-24 [18] | | | A lock-in lesson |
| Midjourney | None; automation forbidden [20] | | | Excluded |
| OpenAI GPT Image 2 | Yes; about $0.006 to $0.211 per 1024x1024 image (secondary) [21] | Through aggregators | | |
| Google Nano Banana (Gemini 3.1 Flash Image) | Yes; about $0.067 per 1K image [16] | Through aggregators | | |
| Replicate | Yes | Official remote MCP (Veo, Kling, FLUX, and more) [22] | Per-model pricing | |

### 4.3 Voice

| Tool | API | MCP | Pricing | Notes |
|---|---|---|---|---|
| ElevenLabs | Yes | Hosted `https://api.elevenlabs.io/v1/mcp` with OAuth; the local server repository was archived on 2026-08-20 [24] | Free: 10k credits, no commercial use. Starter $6: commercial license, instant voice clone. Creator $22: professional voice clone [23] | Cloning your own voice for your own overdubs needs no YouTube disclosure [59] |

### 4.4 Stock media

| Source | API | Limits | Rules | Fit |
|---|---|---|---|---|
| Unsplash | Yes; an Unsplash MCP is already connected in this environment | 50 requests per hour in demo mode, 1,000 in production [25] | Use the returned URLs, trigger the download endpoint, credit the photographer [25]; accepts no AI-generated content [26] | Not AI, but not "my photos": only if the user allows stock |
| Pexels | Yes, photos and videos | 200 requests per hour, 20,000 per month [27] | Link to Pexels and credit photographers [27]; no generative AI uploads [28] | Same as Unsplash; the videos are useful b-roll |

### 4.5 Claude Code features this team depends on

| Feature | Fact | Consequence |
|---|---|---|
| Claude in Chrome | Windows with Chrome or Edge; direct paid plan and `/login`; uploads up to 10 MB; pauses at logins and CAPTCHAs [63] | Fallback only; cannot carry video files over 10 MB |
| Computer use | CLI: macOS only. Windows: Desktop app only [64] | No driving of CapCut desktop from the CLI |
| Subagent tools | Omitting `tools` inherits every tool, MCP included; `tools` and `disallowedTools` accept `mcp__<server>` patterns; subagents cannot ask the user questions [65] | MCP-dependent agents need inheritance or known server names |
| Plugin agents | `mcpServers`, `hooks`, and `permissionMode` are ignored in plugin agents. A plugin can ship `.mcp.json` and `hooks/hooks.json`; its MCP tools are named `mcp__plugin_<plugin>_<server>__<tool>`; `userConfig` asks users for settings [66] | See section 9.5 |
| Hooks | PreToolUse can return `deny` or `ask`; inside a subagent the input carries `agent_id` and `agent_type`; matchers are regular expressions such as `mcp__.*__.*` [67] | The approval gate (section 7.3) |
| Connector names | On this machine, claude.ai-synced connectors appear as `mcp__<uuid>__<tool>` (seen in session transcripts) | Hardcoded MCP tool names are not portable |

## 5. Code-generated video and local media tools (Windows)

| Tool | Best for | License and cost | Local on Windows | Agent fit | Verdict |
|---|---|---|---|---|---|
| FFmpeg 8.x | Cuts, concatenation, scaling to 1080x1920, loudness, caption burn-in, audio mixing, frame sampling for QA | Free (LGPL/GPL) | Yes; the built-in Whisper filter is usually not compiled in [34] | Excellent, pure CLI | Core |
| Remotion | React timelines: animated captions, code and terminal animations, templates | Free for individuals and companies with up to 3 employees [29] | Yes (Node plus a bundled headless Chrome) | Official Agent Skills for Claude Code and Codex: `npx skills add remotion-dev/skills` [30] | Choose Remotion or HyperFrames |
| HyperFrames (HeyGen) | HTML, CSS, and JS compositions rendered frame by frame to MP4; GSAP, Lottie, Three.js | Apache-2.0, no usage caps or per-render fees [31] | Yes (Node 22+, FFmpeg, headless Chrome) [31] | Built for agents; Claude Code plugin from `heygen-com/hyperframes`. Its voice, music, and image add-ons go through a HeyGen sign-in and are AI [31] | Choose Remotion or HyperFrames |
| Motion Canvas | Hand-authored explainer animations | MIT | Yes, but rendering runs from its editor [32] | Weak for unattended runs | Skip (its fork Revideo adds headless rendering) |
| Manim Community | Engineering and math explainers: diagrams, kinematics, signals | MIT; v0.21.0 (2026-08-10); no external FFmpeg since 0.19; LaTeX optional [33] | Yes (`uv add manim`) | Excellent, Python CLI | Optional; very good for engineering topics |
| faster-whisper | Transcription with word timestamps and voice-activity filtering | MIT | Yes; CPU (int8), or an NVIDIA GPU with CUDA 12 and cuDNN 9 [35] | Python | Default for captions; `large-v3-turbo` is about 4 times faster than `large-v3` [35] |
| whisper.cpp | The same without Python | MIT | Yes; official Windows CPU and CUDA builds; SRT output; approximate word timestamps [36] | CLI | Alternative when Python or GPU setup is a problem |
| WhisperX | Precise word alignment | BSD-2 | Heavier setup | Python | Only if caption timing is poor |
| OBS with obs-websocket | Scripted screen recordings with scenes | GPL; websocket built in since OBS 28; Python client `obsws-python` [38] | Yes | Good | Project demos |
| FFmpeg `ddagrab` | Minimal desktop capture | Free | Yes [39] | CLI | Quick captures |

Recommended stack: FFmpeg, faster-whisper (or whisper.cpp), and one composition engine. HyperFrames fits an agent-first, HTML-native workflow with no license threshold; Remotion is more mature and has official Agent Skills. Manim is an optional add-on. CPU rendering is slow but acceptable for 15 to 60 second shorts.

Video QA without watching video. Claude reads images, not video files. The QA agent should:

1. Sample frames with FFmpeg every 1 to 2 seconds and at every cut, then look at them.
2. Check resolution, frame rate, duration, codec, and size with `ffprobe` against the platform specs [47].
3. Measure loudness with FFmpeg's `ebur128` or `loudnorm` analysis.
4. Compare the burned captions with a fresh transcript.
5. Check that captions and key text stay out of the areas covered by the platform's interface.
6. Scan frames and transcripts for PII and secrets.

Windows note: the content workspace lives in a OneDrive-synced folder. Raw footage and renders should go to a folder outside OneDrive, with only final files copied back, to avoid sync churn and file locks during renders.

## 6. Content types and workflows

Automation levels are estimates for this user with the recommended stack.

### 6.1 Carousel (Instagram, reused on LinkedIn)

1. The user drops photos into the piece folder.
2. scriptwriter curates the photos and proposes 3 ideas. The user picks one, or mixes them; the main session saves `guion.json`.
3. visual-builder renders titles, stickers, and the gradient locally, produces full-resolution previews, uploads to Canva with `create-upload-url` and a raw POST, and builds the pages in an editing transaction (or exports locally).
4. content-qa checks the full-resolution previews (at most 2 fix rounds).
5. The user says "ok". The transaction is committed and the slides exported: JPEG for Instagram, a PDF or image set for LinkedIn.
6. `publish`: Postiz drafts; LinkedIn uses `post_as_images_carousel` [44]. The user approves scheduling.

Constraint: the Instagram API accepts only JPEG images between 4:5 and 1.91:1 and at most 8 MB [47], so the current 1080x1440 (3:4) design must be posted by hand in the app, or the team must also render a 1080x1350 (4:5) version for scheduling (open decision 2). TikTok photo posts are another reuse path [49].

Automation: about 85 to 90 percent of the work. Human: photos, choice of idea, approvals.

### 6.2 Reel, Short, or TikTok (9:16)

1. scriptwriter writes a timed script (hook in the first 3 seconds, beats, on-screen text, b-roll list, CTA) and a shot list of what the user must film or record. The user approves it.
2. Capture: the user records voice and footage. The agent drives screen recordings through OBS following the shot list. Optionally, a clone of the user's own voice covers pickups.
3. video-editor transcribes (faster-whisper), aligns takes with the script, picks the best takes, and removes silences and fillers into a cut list (`edl.json`).
4. Composition: FFmpeg for the cuts; Remotion or HyperFrames for animated captions, code and terminal overlays, and title cards in the brand style; Manim for diagrams.
5. Audio: loudness normalization and either a royalty-free music bed baked into the file or nothing, leaving room for in-app trending audio.
6. content-qa checks frames, specs, captions, PII, loudness, and provenance (at most 2 fix rounds). The user reviews the MP4.
7. Export at 1080x1920 (H.264) with a cover frame. Postiz drafts for Instagram Reels (optionally as a trial reel [45]), TikTok (direct post, or upload to the inbox when the user wants to add a trending sound by hand [50]), and YouTube Shorts.

Automation: 60 to 75 percent with real footage. "Faceless" code-only videos reach about 90 percent but fit a personal brand worse, and templated mass production falls under YouTube's inauthentic-content rule [60].

### 6.3 X posts and threads (build in public)

Sources: commits and READMEs of the user's project repositories (read-only), notes, recent carousels and reels. The strategist picks weekly themes; scriptwriter drafts 3 to 5 posts or a thread; content-qa runs a text check (banned generic phrases, length, links, no secrets or private code); the user edits and approves; Postiz drafts. Automation: about 90 percent. If Postiz is self-hosted, X charges $0.015 per post and $0.20 per post with a link [51].

### 6.4 LinkedIn

A more professional angle on the same projects: a text post plus the carousel as a PDF document [44][52]. The brand profile currently marks LinkedIn as inactive (open decision 3).

### 6.5 Newsletter

A monthly digest built from the published log and project updates. Buttondown creates drafts through its API, free up to 100 subscribers [55]. beehiiv's create-post endpoint needs a Pro or Enterprise plan and, since 2026-08-06, creates drafts unless told otherwise [54]. Substack has no publishing API [56], so it means pasting by hand. Automation: about 80 percent of the drafting; sending stays manual.

### 6.6 YouTube long-form

The team can cover the outline, script or talking points, shot list, title and thumbnail options (the user's own photo plus rendered text, never AI), description, chapters from transcript timestamps, and a transcript-based rough cut (Whisper plus a cut list plus FFmpeg), or Descript through its MCP. Note that Descript only delivers a rendered file through a publish link [9]. Fine editing remains human. Uploads go as private drafts, and unverified API projects upload privately anyway [53]. Automation: 30 to 50 percent.

### 6.7 Repurposing one piece into many

A pillar is one real milestone, for example a project demo recorded once. The strategist writes an atomization map: 2 or 3 shorts (clips chosen from the transcript by hook and payoff), 1 carousel (key frames plus titles), 1 thread, 1 LinkedIn post, and a newsletter section. Each derivative is native to its platform: re-cut, with a new hook, and never carrying another platform's watermark, since Instagram reportedly ranks original content above reposts (secondary) [58]. The other skills do the fan-out, and the user approves the batch once.

## 7. Planning, distribution, and the feedback loop

### 7.1 Calendar and idea bank

- Files: `calendario/AAAA-MM.md` (date, platform, format, pillar, piece slug, status: idea, scripted, produced, approved, scheduled, published), the existing `ideas/banco-de-ideas.md`, and `publicado/<date>-<slug>.md` with links, the approval record, and metrics.
- Starting cadence for a student: 1 carousel, 1 or 2 short videos, and 3 to 5 X posts per week, adjusted after the first monthly review.
- Times always in ISO 8601 with the Buenos Aires offset (-03:00).

### 7.2 Scheduling and publishing through Postiz

| Fact | Detail |
|---|---|
| Plans | Cloud: Standard $29 per month (5 channels), Team $39, Pro $49, Ultimate $99; about 20 percent off yearly; 7-day trial; API, CLI, and MCP included in every plan. Self-hosting is free (AGPL) [40] |
| Limits | Public API create-post: 90 requests per hour; images up to 10 MB, videos up to 1 GB [41] |
| Agent paths | CLI `postiz` (OAuth device flow or API key) with drafts (`-t draft`), status changes, uploads, and analytics [42]; hosted MCP [43]; the `postiz:postiz` skill is already installed |
| Self-hosting cost | You register your own developer app on every platform: X charges per post [51], TikTok posts stay private until your app passes an audit [49], Meta requires app review |

Per platform: Instagram needs a Business or Creator account and inherits the API rules in section 3.2 [46][47][48]. TikTok can direct-post or upload to the app inbox [50]. LinkedIn personal profiles post through member permissions [52]. YouTube drafts upload as private [53].

### 7.3 The human approval gate (mandatory)

Rule: no agent publishes or schedules public content. Subagents may only create drafts. Only the main session, after the user's explicit approval in the conversation and a permission prompt, moves a draft into the schedule.

Mechanisms, from strongest to weakest:

1. Permission rules in the user's settings: `ask` for any Postiz command or MCP tool that publishes, schedules, or changes a post's status; `deny` for automating social-network websites in the browser.
2. A PreToolUse hook, which a plugin can ship [66]: `deny` any publish or schedule call when `agent_id` is present (meaning it comes from a subagent) and `ask` otherwise. Matchers are regular expressions, so they can cover both Bash commands and Postiz MCP tools whatever the server's name [67]. This must be tested against the actual Postiz tool names in the user's installation.
3. Draft-first defaults everywhere: `postiz posts:create ... -t draft` [42], beehiiv drafts by default [54], YouTube uploads as private.
4. An approval record in `publicado/<slug>.md`: time, approved text, channels, scheduled time.

A scheduled Postiz post can still be stopped by moving it back to draft before its time [42].

### 7.4 Analytics loop

- Pull: `postiz analytics:post` and `postiz analytics:platform` [42]; Instagram insights for views, reach, saves, and shares (secondary) [57]; whatever Postiz exposes for TikTok and X, plus manual exports.
- Store the numbers at 48 hours and 7 days in each piece's `publicado/` file.
- Monthly `content-report`: the strategist compares results by pillar, format, and hook type, and writes 3 things to keep, 3 to stop, and 3 to try, then updates the brand profile and the next calendar. Trial reels can test hooks with non-followers [45].
- The installed `marketing:performance-report` skill can serve as a report template.

## 8. The "no AI images" rule

### 8.1 Proposed wording

"No generative-AI pixels in published content: no images or video frames that an AI generated or edited. Graphics rendered by code (titles, stickers, diagrams, animations) are allowed because they are deterministic renders of my own design. AI is allowed for text (ideas, scripts, captions), transcription, and audio cleanup. AI voice: to be decided."

### 8.2 Tool-by-tool fit

| Category | Examples | Status under the rule |
|---|---|---|
| Own media | Photos, footage, screen recordings | Core of the brand |
| Rendered by code | Pillow titles and stickers; Remotion, HyperFrames, and Manim animations | Allowed |
| Stock | Unsplash, Pexels (both refuse AI uploads [26][28]) | Not AI, but not "my photos": decision |
| AI on text and audio analysis | Scripts, captions, Whisper transcripts | Allowed (not images) |
| AI audio | Text to speech, a clone of the user's own voice, generated music | Decision; own-voice overdubs need no YouTube disclosure [59] |
| Generative images | GPT Image, Nano Banana, Canva AI features, Midjourney | Forbidden |
| Generative video | Higgsfield, Runway, Kling, Veo, AI add-ons of HyperFrames or Canva | Forbidden in spirit; confirm explicitly |
| AI enhancement of own photos | Upscaling, phone "AI enhance" | Gray area: decide |

### 8.3 If the rule is ever relaxed

Platforms ask for disclosure of realistic synthetic media: Meta labels AI content detected through C2PA or IPTC metadata and requires self-disclosure for photorealistic video and realistic audio [61]; TikTok requires an AI-generated content label for realistic content and applies it automatically from C2PA Content Credentials [62] (Postiz exposes a `video_made_with_ai` flag [50]); YouTube requires disclosure for realistic altered or synthetic content, but not for help with scripts, captions, or one's own voice overdubs [59]; YouTube's inauthentic-content rule (2025-07-15) targets mass-produced, templated videos [60]; Veo outputs carry SynthID [17]. In every case content-qa should check provenance metadata (C2PA, for example with `c2patool`) on every asset, so AI material cannot slip in unnoticed, for instance through a stock clip or a Canva element.

## 9. Proposed team roster

### 9.1 Agents

| Agent | Role | Tier and effort | Capabilities and tools | Inputs | Outputs | Replaces |
|---|---|---|---|---|---|---|
| `content-strategist` | Brand profile (from the main-session interview), pillars, calendar, repurposing maps, monthly reviews | deep, high | read, write, web (platform rules, trends); no MCP | Brand profile, idea bank, published log with metrics, project updates | `marca/perfil-de-marca.md`, `calendario/AAAA-MM.md`, idea bank updates, `reportes/AAAA-MM.md` | New |
| `scriptwriter` | Ideas from real material; scripts and copy for every format; captions and alt text; media curation | deep, high | read, write, shell (exiftool or Pillow, ffprobe, frame extraction, read-only `git log` of project repositories); optional web for fact checks | Brief from the main session, media folder, brand kit | `ideas.json`, `guion.json` (carousel), `script.md` and `shotlist.md` (video), `post.md` (text formats) | `ideas-carrusel` |
| `visual-builder` | Code-rendered stills and layout: titles, stickers, diagrams, thumbnails, carousel pages; Canva assembly | standard, medium | read, write, shell (Python with Pillow, headless Chrome); Canva MCP (inherited); browser only as a fallback | `guion.json`, brand kit (fonts, palette, style file) | Renders, full-resolution `preview-*.png`, `build.json`, Canva link with the transaction left open | `armador-slides` and `stickers-carrusel` |
| `video-editor` | Cut list, cuts, motion graphics, captions, audio, exports; scripted screen recordings | standard, high | read, write, edit, shell (FFmpeg, Node with Remotion or HyperFrames, Python with faster-whisper, Manim, OBS websocket) | `script.md`, footage, voice takes, brand kit | `edl.json`, `captions.srt` or `.ass`, `render/<slug>-<platform>.mp4`, `cover.jpg`, `render-report.json` | New |
| `content-qa` | Checks every deliverable against the brand kit and platform specs; never edits deliverables | standard, medium | read; shell for read-only measurements (ffprobe, ebur128, frame sampling, metadata); writes only `qa-<n>.json`; Canva read tools (inherited) | Deliverables, brand kit, platform specs, script | `qa-<n>.json` with a `responsable` per problem, and a verdict | `qa-carrusel` |

Why these tiers: the strategist and the scriptwriter work at low volume with high leverage and need taste and vision, as `ideas-carrusel` does today on opus. The builders follow precise specs. QA needs dependable vision on full-resolution images; the fast tier produced false positives in the first run.

There is no publisher agent. Publishing stays in the main session through the `publish` skill, because subagents cannot ask the user [65] and approval has to pass through the permission system [67].

### 9.2 Skills (the workflows)

| Skill | Flow | Agents | Human gates |
|---|---|---|---|
| `content-plan` | Interview for the gaps in the brand profile (in the main session), then monthly calendar and idea bank | content-strategist | Calendar approval |
| `carousel` | Port of `/carrusel` (section 6.1) | scriptwriter, visual-builder, content-qa | Idea choice; "ok" before the Canva commit |
| `short-video` | Script and shot list, capture, edit, QA (section 6.2) | scriptwriter, video-editor, content-qa | Script approval; review of the final cut |
| `social-post` | X post or thread, LinkedIn text post | scriptwriter, content-qa | Text approval |
| `repurpose` | Pillar, atomization map, fan-out to the other skills | content-strategist, then the others | One batch approval |
| `publish` | Create drafts, show the preview, get approval, schedule, log | Main session only (Postiz skill or CLI) | Permission prompt plus explicit approval |
| `content-report` | Pull metrics, log them, review, update the plan | content-strategist | User reads the report |
| Later: `newsletter`, `youtube-long` | Sections 6.5 and 6.6 | | |

Every skill keeps a single-session fallback, as the repository's skills already do.

### 9.3 How the existing carousel agents fit

- `ideas-carrusel` becomes `scriptwriter` in carousel mode: same duties, same tier, same `ideas.json` contract.
- `armador-slides` and `stickers-carrusel` become `visual-builder`. Stickers turn into a render step before assembly, so separate browser tabs are no longer needed. If speed matters, the skill can launch two instances of the same agent in parallel instead of keeping two definitions.
- `qa-carrusel` becomes `content-qa`: full-resolution local previews, the standard tier, and new PII and provenance checks; the `qa-<n>.json` format stays.
- `/carrusel` becomes the `carousel` skill. `estilo-carrusel.md` moves into the brand kit and splits into "look" (brand) and "pipeline" (technical). The pipeline part becomes local-first (curl upload), with the browser kept for cloud or VM sessions.
- Migration: keep the private Spanish agents working while the generic version is built, and switch only after a side-by-side run on the same photos gives an equal or better result.

### 9.4 Reuse instead of rebuilding

- `postiz:postiz` for publishing and analytics.
- `canva:*` skills, for example `resize-for-social-media` (needs Pro).
- `marketing:brand-review` as an optional voice check, `marketing:performance-report` as a report template.
- Remotion Agent Skills [30] or the HyperFrames plugin [31], installed from their own repositories, never copied into the catalog.
- The Unsplash MCP, only if stock is allowed.

### 9.5 Packaging in gaisser-agents

- Plugin name: `content-studio`. It avoids the owner's `marketing` and `design` plugins and the `content-creation` skill. Agent names must be unique across the repository, and `content-writer` is already reserved by the `docs-writing` backlog, hence `scriptwriter`.
- Generic plugin, personal brand kit. Prompts stay in English and tool-neutral, following `CONTRIBUTING.md`. Output language, voice, palette, fonts, project names, AI policy, approval wording, and time zone live in the workspace brand kit (`marca/`), referenced by path or through `userConfig` [66]. The fonts in use today are open-licensed (SIL OFL), but they belong in the user's workspace, not in the catalog.
- Build changes, none of which exist in Phase 1:
  1. MCP access. Option A: a neutral capability that emits no `tools` line (so the agent inherits everything) plus `disallowedTools`. Option B: a plugin `.mcp.json` declaring the Canva and Postiz remote servers, which makes tool names predictable (`mcp__plugin_content-studio_canva__*`) at the cost of a second OAuth connection that duplicates the user's existing connectors [66].
  2. Plugin-level `hooks/hooks.json` for the publish guard. The Phase 1 plan excluded hooks.
  3. Skill assets (`scripts/`, `templates/`) copied into `dist/`: render scripts, a cut-list schema, caption styles.
  4. Prompt length: the 25 to 80 line limit pushes format details into skills, which fits "few agents, workflows as skills".
  5. Codex: MCP servers per agent (`mcp_servers`) or in the user's config; no Chrome integration; the local-first pipeline still works.
  6. A prerequisites section in the README: Python 3.11+ with Pillow, FFmpeg, Node 22+, OBS (optional), a Postiz account.

## 10. Phased roadmap

| Phase | Scope | Duration | Monthly cost | Main risks |
|---|---|---|---|---|
| 0. Foundations | Brand-profile interview; decisions on AI policy, stock, voice, and Instagram format; split the style guide into look and pipeline (local-first); calendar and published-log templates; Postiz account with channels connected in drafts-only mode; `ask` permission rules | 1 week | $0 | Low |
| 1. MVP: carousel, text posts, drafts | Agents: content-strategist, scriptwriter, visual-builder, content-qa. Skills: content-plan, carousel, social-post, publish (drafts), content-report (manual metrics). Exit criteria: 2 weeks of calendar executed, every published piece logged with its approval, zero publishes without approval | 2 to 3 weeks | $0 to $29 (Postiz Cloud) | Instagram 3:4 rejected by the API; Canva upload URL expiry; X costs if self-hosted |
| 2. Short video and repurposing | Agent: video-editor. Skills: short-video, repurpose. Install FFmpeg, faster-whisper or whisper.cpp, Node 22 with Remotion or HyperFrames, OBS. Start with a spike: one 30-second reel end to end, measuring render time and caption accuracy on Rioplatense speech and technical terms (with a glossary) | 4 to 6 weeks | $0 to $6 (optional voice clone) | CPU render time; caption errors; music licensing; OneDrive sync; Instagram audio limits |
| 3. Long-form, newsletter, automated analytics | Skills: youtube-long, newsletter; scheduled metric pulls through Postiz; monthly reviews; optional media index | Later | $0 to about $25 (optional Descript plan, price not checked here) | Private YouTube uploads; Descript delivers renders only through publish links |
| 4. Catalog release | Port to a `content-studio` plugin with the build changes of section 9.5, English and tool-neutral, with tests | After 4 to 6 weeks of real use | $0 | MCP name portability; hook testing; Codex parity |
| X. Generative media | Only if the user relaxes the rule: Veo 3.1 Fast or Lite, or Runway Gen-4 Turbo, for clearly non-realistic inserts, with disclosure and a monthly budget cap | Optional | For example 10 clips of 5 s at Veo 3.1 Fast 1080p: 50 s x $0.12 = $6 [16] | Authenticity, platform labels, vendor churn |

Cost scenarios on top of the Claude plan:

| Scenario | Monthly |
|---|---|
| Minimal: Canva Free, self-hosted Postiz, own voice | $0, but you maintain platform developer apps and pay X per post |
| Recommended MVP: Canva Free, Postiz Cloud Standard | $29 ($23 billed yearly) |
| Plus video with own voice | $29 |
| Plus an ElevenLabs Starter own-voice clone | $35 |
| Plus Canva Pro (resize, brand kits) | Add the Canva Pro price (not checked here) |

## 11. Risks and edge cases

1. Accidental publishing: section 7.3. Never give a subagent a path to publish, and never let a scheduler run with non-draft defaults.
2. Terms of service and bans: no browser automation of social networks, CapCut, or Midjourney [4][20].
3. PII leaks: emails, user names, host names, API keys, and addresses in photos, screenshots, screen recordings, and sticker text. Use a PII pass on full-resolution frames, a secrets scan over transcripts and visible text, OBS scenes that hide notifications, and a separate browser profile for recordings.
4. Instagram API format rules: JPEG only, 4:5 to 1.91:1, at most 8 MB; carousels up to 10 items; Reels 3 s to 15 min and at most 300 MB [46][47]. Canva PNG exports need conversion to JPEG.
5. Canva: single-use, expiring upload URLs; per-tool rate limits; transactions left open; Pro-only features [1][2].
6. Browser fallback: 10 MB upload cap, disconnects, CAPTCHAs [63].
7. Vendor churn: Sora closed within months of shipping new features [18][19]; X pricing changed several times between 2025 and 2026 [51]; Instagram deprecated metrics [57]. Keep the pipeline local and file-based, and put each vendor behind one skill.
8. CPU-only machines: long renders and large disk use. Render outside OneDrive.
9. Caption accuracy on Rioplatense slang and English technical terms: keep a glossary and have the user review.
10. Copy that sounds generated: brand voice document with real examples and banned phrases; the user edits before approval.
11. Music rights: royalty-free tracks baked into the file, or library audio added in the app; avoid copyrighted music in API uploads.
12. Cost creep if generative tools are ever enabled: a monthly cap in the brand kit and a spend log.
13. Subagent limits: they cannot ask questions and may run in the background. They must write everything to files, and the main session relays questions [65].
14. Time zones and scheduling mistakes: always ISO 8601 with offset.
15. Rate limits: Postiz create-post 90 per hour [41]; Canva 20 to 100 per minute per tool [1].
16. A public repository: never commit workspace content, design IDs, tokens, or personal data.

## 12. Open decisions for the user

1. AI policy: does "no AI images" also cover video? Is a clone of your own voice allowed? AI enhancement of your own photos? Stock photos and footage?
2. Instagram format: keep 3:4 (fills the grid, posted by hand in the app), move to 4:5 (1080x1350, can be scheduled by API), or render both?
3. Platforms: keep X, Instagram, and TikTok only, or add LinkedIn and YouTube Shorts now?
4. Postiz: Cloud ($29 per month, ready-made platform apps) or self-hosted (free, but your own developer apps, X per-post fees, TikTok audit)?
5. Canva's role: keep it as the editable assembly surface, or render everything locally and keep Canva optional?
6. Video engine: Remotion or HyperFrames, with Manim as an add-on?
7. Voice: always self-recorded, or ElevenLabs Starter ($6 per month) for own-voice pickups?
8. Merge `armador-slides` and `stickers-carrusel` into one `visual-builder`, or keep them separate?
9. Approval protocol: may agents create Postiz drafts without asking (drafts are invisible), with scheduling always gated? What exact wording counts as approval?
10. Hardware: is there an NVIDIA GPU? It changes Whisper and render speed.
11. Monthly budget ceiling.
12. Catalog: publish a generic `content-studio` plugin in gaisser-agents once the private version proves itself? What stays private?
13. Target weekly cadence.

## Sources

1. Canva MCP tools and rate limits: https://www.canva.dev/docs/apps/mcp/tools/
2. Canva `create-upload-url` tool description: https://glama.ai/mcp/connectors/com.canva.mcp/canva/tools/create-upload-url
3. Canva Connect autofill guide (Enterprise): https://www.canva.dev/docs/connect/autofill-guide/
4. CapCut Terms of Service, last updated 2026-04-15: https://www.capcut.com/clause/terms-of-service
5. CapCut API status (secondary): https://www.usecarly.com/blog/claude-capcut-integration/ and https://github.com/devin-cli/awesome-capcut-api
6. VectCutAPI, unofficial CapCut draft API: https://github.com/sun-guannan/VectCutAPI
7. CapCut pricing (secondary): https://www.agencyhandy.com/informative/capcut-pricing/
8. Descript API: https://help.descript.com/hc/en-us/articles/43370311322509-Descript-API
9. Descript MCP overview: https://help.descript.com/api-and-mcp/mcp
10. Higgsfield API (2026-09-16): https://higgsfield.ai/blog/higgsfield-api
11. Higgsfield MCP connection: https://higgsfield.ai/creator-hub/help-center/integrations/how-do-i-connect-higgsfield-to-ai-agent
12. Higgsfield plan pricing (secondary): https://www.blotato.com/blog/higgsfield-pricing
13. Runway API pricing: https://docs.dev.runwayml.com/guides/pricing/
14. Runway MCP: https://docs.dev.runwayml.com/guides/mcp/ and https://help.runwayml.com/hc/en-us/articles/51931843164691-Connecting-to-Runway-MCP
15. Kling API pricing (secondary, checked September 2026): https://aireiter.com/blog/kling-api-pricing (official page: https://kling.ai/dev/pricing)
16. Gemini API pricing, updated 2026-10-01: https://ai.google.dev/gemini-api/docs/pricing
17. Veo in the Gemini API: https://ai.google.dev/gemini-api/docs/veo
18. OpenAI Help Center, Sora discontinuation (blocked to automated reading; dates confirmed by [19] and other coverage): https://help.openai.com/en/articles/20001152-what-to-know-about-the-sora-discontinuation
19. Sora discontinuation analysis: https://futurumgroup.com/insights/openai-sora-discontinuation-what-the-end-of-a-platform-means-for-enterprise-ai-strategy/
20. Midjourney Terms of Service: https://docs.midjourney.com/hc/en-us/articles/32083055291277-Terms-of-Service
21. OpenAI image pricing calculator (secondary): https://costgoat.com/pricing/openai-images
22. Replicate remote MCP server: https://replicate.com/blog/remote-mcp-server
23. ElevenLabs pricing: https://elevenlabs.io/pricing
24. ElevenLabs MCP repository (archived, hosted server): https://github.com/elevenlabs/elevenlabs-mcp
25. Unsplash API documentation: https://unsplash.com/documentation
26. Unsplash AI content policy: https://help.unsplash.com/en/articles/14790544-do-you-have-ai-generated-content-on-the-site
27. Pexels API documentation: https://www.pexels.com/api/documentation/
28. Pexels generative AI uploads: https://help.pexels.com/hc/en-us/articles/27453505326873-Can-I-upload-generative-AI-photos-and-videos-to-Pexels
29. Remotion license: https://github.com/remotion-dev/remotion/blob/main/LICENSE.md and https://www.remotion.dev/docs/license/pricing
30. Remotion Agent Skills: https://www.remotion.dev/docs/ai/skills
31. HyperFrames: https://github.com/heygen-com/hyperframes and https://hyperframes.heygen.com/introduction
32. Motion Canvas headless rendering: https://github.com/motion-canvas/motion-canvas/issues/1218 and (secondary) https://www.pkgpulse.com/guides/remotion-vs-motion-canvas-vs-revideo-programmatic-video-2026
33. Manim installation, v0.21.0: https://docs.manim.community/en/stable/installation/uv.html
34. FFmpeg 8.0 Whisper filter: https://www.phoronix.com/news/FFmpeg-Lands-Whisper and https://ayosec.github.io/ffmpeg-filters-docs/8.0/Filters/Audio/whisper.html
35. faster-whisper setup (secondary): https://knightli.com/en/2026/05/01/faster-whisper-speech-to-text/ and the large-v3-turbo model card: https://huggingface.co/openai/whisper-large-v3-turbo
36. whisper.cpp: https://github.com/ggml-org/whisper.cpp
37. WhisperX guide (secondary): https://localaimaster.com/blog/whisperx-guide
38. obs-websocket: https://github.com/obsproject/obs-websocket and https://pypi.org/project/obsws-python/1.6.0
39. FFmpeg `ddagrab`: https://ayosec.github.io/ffmpeg-filters-docs/8.0/Sources/Video/ddagrab.html
40. Postiz pricing: https://postiz.com/pricing
41. Postiz Cloud limits: https://docs.postiz.com/cloud/limits
42. Postiz agent CLI: https://github.com/gitroomhq/postiz-agent
43. Postiz MCP setup: https://docs.postiz.com/mcp/setup
44. Postiz LinkedIn settings: https://docs.postiz.com/public-api/providers/linkedin
45. Postiz Instagram settings: https://docs.postiz.com/public-api/providers/instagram
46. Instagram content publishing: https://developers.facebook.com/docs/instagram-platform/content-publishing/
47. Instagram IG User Media reference (image and Reels specifications): https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media
48. Instagram Platform overview (Business and Creator accounts): https://developers.facebook.com/docs/instagram-platform/
49. TikTok Content Posting API: https://developers.tiktok.com/doc/content-posting-api-get-started and https://developers.tiktok.com/doc/content-posting-api-reference-photo-post
50. Postiz TikTok settings: https://docs.postiz.com/public-api/providers/tiktok
51. X API pricing: https://docs.x.com/x-api/getting-started/pricing
52. LinkedIn Documents API: https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/documents-api?view=li-lms-2026-09
53. YouTube Data API revision history: https://developers.google.com/youtube/v3/revision_history
54. beehiiv Send API and Create post endpoint: https://www.beehiiv.com/support/article/36759164012439-using-the-send-api-and-create-post-endpoint
55. Buttondown drafts through the API: https://docs.buttondown.com/drafting-emails-via-the-api
56. Substack Developer API terms: https://substack.com/api-tos and (secondary) https://dev.to/equinoxaifinancergb/does-substack-have-an-api-2026-and-what-you-can-actually-get-29il
57. Instagram insights metrics (secondary): https://elfsight.com/blog/instagram-graph-api-complete-developer-guide-for-2026/
58. Instagram ranking of original content (secondary): https://www.eclincher.com/articles/how-the-instagram-algorithm-works-in-2026
59. YouTube altered or synthetic content disclosure: https://support.google.com/youtube/answer/14328491
60. YouTube inauthentic content policy (2025-07-15): https://support.google.com/youtube/answer/1311392
61. Meta labeling of AI content: https://about.fb.com/news/2024/04/metas-approach-to-labeling-ai-generated-content-and-manipulated-media/
62. TikTok AI-generated content labels: https://newsroom.tiktok.com/more-ways-to-spot-shape-and-understand-ai-content?lang=en and https://www.tiktok.com/creator-academy/en/article/ai-generated-content-label
63. Claude Code with Chrome: https://code.claude.com/docs/en/chrome
64. Claude Code computer use: https://code.claude.com/docs/en/computer-use
65. Claude Code subagents: https://code.claude.com/docs/en/sub-agents
66. Claude Code plugin components: https://code.claude.com/docs/en/plugins/components
67. Claude Code hooks: https://code.claude.com/docs/en/hooks
