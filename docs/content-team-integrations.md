# Content team: integration research and media-by-code options

- Research date: 2026-10-03 (America/Buenos_Aires).
- Status: architecture proposal; no integrations installed, accounts connected, media generated, or content published.
- Companion documents: [architecture](plan-content-team.md), [design system](content-team-design-system.md), [Claude handoff](content-team-claude-handoff.md).
- Scope: a broad survey of practical content-production routes, including unavailable and uncertain candidates. No finite survey can enumerate every app. New vendors should enter through the capability assessment below.
- Evidence: official vendor/project documentation and read-only plugin-directory discovery. Documentary support is not an account-access test or an export test. Prices, model catalogs, plan entitlements, regions, and tool surfaces can change.
- Existing research remains at [research-content-team.md](research-content-team.md). This supplement records differences without overwriting its narrower historical assumptions.

## 1. Recommended architecture and buying order

Use a local content specification and asset manifest as the durable source of truth. Begin with SVG/HTML coded stills, an FFmpeg montage, local transcription, and file delivery. Choose one richer motion renderer, Remotion or HyperFrames, when reusable animated templates justify it. Add Canva for editable designs. Add one generative gateway only when a brand allows generated media. Add Adobe or DaVinci for workflows that require their editing features. Evaluate publishing separately after content production is dependable.

An app connector is a conversational interface; REST APIs support custom integrations; desktop SDKs run inside an installed editor; CLI tools render local files; file exchange is a human handoff. These are different capabilities. A generation API does not imply a controllable editing timeline, and an MP4 does not imply an editable project.

Choose by required output, not by number of apps:
- Editable carousel: Canva or Figma native elements plus final PNG/JPG exports.
- Repeatable carousel and motion package: SVG/HTML composition and Remotion or HyperFrames.
- Real footage and precise cuts: FFmpeg initially; Premiere/Resolve adapter when advanced grading or editorial control is required.
- Generated B-roll/images: an explicitly enabled provider, followed by the same local layout, timeline, and QA.
- Transcript editing: Descript, with its export/publication constraint explicitly handled.
- Human CapCut finishing: source clips, caption files, audio stems, and rendered overlays in a handoff bundle.

These are proposed priorities, not subscriptions or tool installations.

## 2. What is visible in this session

Read-only directory queries: “CapCut”; “Adobe Descript Runway Canva Higgsfield Figma”; and “ElevenLabs HeyGen Synthesia Buffer Postiz video audio”. Directory results are not exhaustive; more entries may exist in the [plugin directory](https://chatgpt.com/plugins).

| Product | Discovery result | Evidence boundary |
|---|---|---|
| Canva | Installed; creative tools exposed to this session | Creation, editing transactions, upload, template/autofill and export tools are present. No account operation or export was exercised. |
| Higgsfield | Installed; media generation/editing tools exposed | Models, generation, costs, media handling and composition capabilities are present. No credit balance or generation tested. |
| Figma | Installed; design tools exposed | Design context and native design operations are present. No file access tested. |
| Google Drive | Tools exposed | Potential source/library/review store. No personal files inspected for this task. |
| Adobe | Found, not installed | Directory describes photo, Express, video reformat/stitch, Creative Cloud asset and PDF capabilities. Not a promise of Premiere timeline control. |
| Adobe Express | Found, not installed | Directory describes template customization. Separate from the Embed SDK or Firefly enterprise APIs. |
| Adobe Acrobat | Found, not installed | PDF work, not a video editor. |
| Descript | Found, not installed | Conversation-directed production; actual account entitlement untested. |
| Runway | Found, not installed | Generation, editing and workflow capabilities advertised by directory; access untested. |
| HeyGen | Found, not installed | Avatar, voice, translation and video capabilities advertised; access untested. |
| OpenArt | Found, not installed | Image/video generation advertised; custom API equivalence not established. |
| vidIQ | Found, not installed | Idea, competitor, transcript and analytics assistance advertised; scores are not guarantees of reach. |
| MagicPath, tldraw | Found, not installed | Useful planning/prototyping surfaces; not selected as production renderers. |
| CapCut | No matching entry returned | This means no match in these searches, not proof no connector exists anywhere. |
| ElevenLabs, Synthesia, Buffer, Postiz | No exact matching entry returned in the broad query | Their documented APIs can still be used through custom adapters; separate discovery may find more integrations. |

No connection in Codex proves that Claude has the same connection. Inspect each client's available tools and authenticate independently. Do not copy secret values into shared architecture files.

## 3. Design and desktop editing apps

Route legend: MCP/connector = assistant tools; REST = cloud automation; SDK/script = app-specific code; CLI = local processing; files = manual editor handoff. “Documented” describes a vendor surface, not successful execution here.

| App / product | Supported or proposed connection | Useful output and limitation | Evidence |
|---|---|---|---|
| Canva | Official MCP; REST APIs; Apps SDK inside Canva | Native designs, uploads, templates, edit transactions, exports. Prefer MCP for assistant editing and REST for custom workflow. REST asset/design endpoints alone are not arbitrary full-editor control. | [REST overview](https://www.canva.dev/docs/apps/rest-apis/), [MCP overview](https://www.canva.dev/docs/apps/mcp/) |
| Canva Autofill | REST/MCP using configured data fields | Generate/update templated designs. Official current docs say eligible plans include Pro, Teams, Enterprise; Sep 23 announcement includes Business/Education. Directory description still says Enterprise. Probe actual entitlement later; keep local fallback. | [Autofill reference](https://www.canva.dev/docs/apps/rest-apis/reference/autofills/), [dated vendor announcement](https://community.canva.dev/t/autofill-apis-are-now-available-on-canva-pro-and-above/8922) |
| Figma / FigJam / Slides | Official MCP; editor Plugin API; REST | Native canvas writing through supported MCP/plugin operations; REST retrieval/export is a different surface. Good for templates, visual systems and collaboration. Capability and seat limits need checking. | [MCP](https://developers.figma.com/docs/figma-mcp-server/), [API comparison](https://developers.figma.com/compare-apis/) |
| Adobe connector | Discoverable conversational app | Photo/design/video transformation advertised. Install/access test required; do not conflate with full desktop application access. | Plugin directory evidence in section 2 |
| Photoshop desktop | UXP plugin architecture | Custom desktop panels/commands and document manipulation. Requires installed host and compatible API version. | [Adobe UXP platform](https://developer.adobe.com/uxp/) |
| Photoshop / Lightroom-style cloud processing | Firefly Services Photoshop API v2; legacy migration path | Programmatic photo editing and composition; cloud credentials/entitlement separate from a desktop subscription. v2 unifies Photoshop and Lightroom-style workflows; audit exact endpoints. | [Photoshop API](https://developer.adobe.com/firefly-services/docs/photoshop/), [v2 guides](https://developer.adobe.com/firefly-services/docs/photoshop/guides/photoshop-v2/) |
| Adobe Firefly | REST via Firefly Services | Optional generative media and creative production. Request schemas, model rights and account access remain provider-specific. | [Firefly Services](https://developer.adobe.com/firefly-services/docs/guides/) |
| Adobe Express | Conversational connector; Embed SDK; editor add-ons as a separate route to assess | Template-oriented design/photo/video tools. Embed SDK needs business approval; it is an embedded UI, not an unattended cloud renderer. | [Embed SDK overview](https://developer.adobe.com/express/embed-sdk/docs/guides/) |
| Premiere | Desktop UXP (25.6+); C++ SDK; legacy CEP | Timeline/editor automation is feasible with a local extension and installed compatible Premiere. Inspect member minimum versions. Cloud “Adobe” connector does not imply this capability. | [Premiere developer platform](https://developer.adobe.com/premiere-pro/), [UXP API](https://developer.adobe.com/premiere-pro/uxp/ppro-reference/) |
| After Effects | Existing scripting workflow; future UXP migration | Motion/templated composition through the installed application. Sep 2026 roadmap schedules UXP public beta for Nov 2026: not an available production baseline on research date. | [Adobe transition announcement](https://blog.developer.adobe.com/en/publish/2026/09/investing-in-the-future-of-creative-cloud-extensibility-uxp-comes-to-our-flagship-applications), [Adobe partner scripting reference](https://www.adobevideopartner.com/wp-content/uploads/2026/02/Adobe-Video-Partner-Program_Extension-Panel-Guide_2025_compressed-1.pdf) |
| Illustrator / Media Encoder | Host-specific extension/scripting routes; migration varies | Illustrator UXP beta planned for spring 2027; Media Encoder UXP public beta announced. Keep stable current workflows separate from roadmap items. | [Adobe transition announcement](https://blog.developer.adobe.com/en/publish/2026/09/investing-in-the-future-of-creative-cloud-extensibility-uxp-comes-to-our-flagship-applications) |
| DaVinci Resolve / Fusion | Installed-host Python/Lua scripting; file/timeline handoff | Useful editorial/color/compositing route. External scripting depends on Studio/version. Confirm current installed scripting README and edition rather than relying on old free-edition anecdotes. | [vendor support](https://www.blackmagicdesign.com/support), [vendor forum edition warning](https://forum.blackmagicdesign.com/viewtopic.php?f=21&t=204977) |
| CapCut / Pippit | Human import/export handoff; public editing API not established in this survey | Supply clips, MP4 previews, PNG overlays, stems, SRT and cut list. No official controllable CapCut editing timeline established. Terms mentioning APIs do not establish a public developer endpoint. Unofficial draft writers are version-dependent and not the core. | [CapCut terms](https://www.capcut.com/clause/terms-of-service) |
| Descript | Official API, CLI and MCP | Import/transcribe; Underlord edits; transcript exports and progress. Token is Drive-scoped. Documented rendered media download requires publication to a Descript web link; otherwise export manually in app. Treat that as a distinct external action. | [current API guide](https://help.descript.com/api-and-mcp/api) |
| VEED | REST model APIs; OpenEdit agent editor as separate route | API provides model-specific generation/editing. OpenEdit offers coded composition/editor handoff; Windows readiness conflicts between landing page (“coming soon”) and repo docs that mention Windows state paths. Do not select as tested Windows baseline. | [API docs](https://api.veed.io/docs), [OpenEdit landing page](https://www.veed.io/tools/openedit), [project README](https://github.com/veedstudio/open-edit/blob/main/README.md) |
| Photopea | Browser iframe/configuration API and scripting workflow | PSD-oriented browser editing can be integrated; requires browser runtime and save callback handling. Not a local headless Python service. | [official API](https://www.photopea.com/api/) |
| Picsart | Official Creative APIs | Programmatic image transformations and optional generative/video services. Inspect per-product schema and async mode; do not assume every editor feature is exposed. | [getting started](https://docs.picsart.io/docs/creative-apis-getting-started) |
| GIMP | CLI batch interpreter / app scripting | Local photo operations and compositing. Pin GIMP version and interpreter; scripts vary between major releases. | [official CLI manual](https://www.gimp.org/man/gimp.html) |
| Inkscape | CLI exports/actions; SVG source | Editable vector diagrams and raster exports. Best for SVG-first assets, not a video timeline. | [official command-line guide](https://wiki.inkscape.org/wiki/Using_the_Command_Line) |
| Blender | Python API plus background CLI | Code-created 3D stills, animations and product scenes. Renderer, color management, assets and CPU/GPU requirements must be pinned. | [official API](https://docs.blender.org/api/current/), [4.5 CLI manual](https://docs.blender.org/manual/nl/4.5/advanced/command_line/arguments.html) |
| OBS Studio | WebSocket; Python/Lua scripting; plugins | Capture scenes and recordings. This is a source-capture adapter, not a full editing/render engine. | [official developer guide](https://obsproject.com/kb/developer-guide) |

CapCut qualification: the retrieved terms page explicitly applies to US users and restricts automated interaction. It is not a legal conclusion about an Argentine account. Before considering automated service interaction, inspect the applicable regional terms and vendor-authorized integration. The MVP file handoff avoids depending on an undocumented service API.

## 4. Generation providers and gateways

These adapters are disabled when the brand prohibits generated media. Exact models/limits are discovered at runtime and recorded with each output; no fixed “best model” in the team prompt.

| Provider | Connection | Role / important boundary | Evidence |
|---|---|---|---|
| Higgsfield | Official API; hosted MCP; installed plugin tools | Image/video generation and creative workflows. API prepaid dollar billing is separate from website subscription credits/Unlimited. MCP tools and API catalog need separate capability profiles. | [API](https://higgsfield.ai/higgsfield-api), [billing distinction](https://higgsfield.ai/creator-hub/help-center/integrations/what-is-the-higgsfield-api) |
| Runway | Official REST/SDK; discoverable connector | Generated and transformed image/video workflows. API catalog is documented; account entitlement and output format vary by model. | [API model catalog](https://docs.dev.runwayml.com/guides/models/) |
| Google Gemini / Imagen / Veo | Gemini/Gen Media APIs | Image/video generation and multimodal analysis. Availability is per model, region, billing and preview status; a Gemini app plan is not API billing. | [API reference](https://ai.google.dev/api), [video guide](https://ai.google.dev/gemini-api/docs/video) |
| OpenAI GPT Image | Images API or Responses image-generation tool; built-in image tool here | Generated/edited raster images. Keep image model IDs in provider config and consult current supported models. API execution not tested. | [image guide](https://developers.openai.com/api/docs/guides/image-generation) |
| OpenAI Sora | Retired route | Videos API and Sora 2 shutdown date is 2026-09-24. Exclude as an active new integration on this research date. | [official deprecations](https://developers.openai.com/api/docs/deprecations) |
| Black Forest Labs / FLUX | Official API | Image generation/editing by supported endpoint; pin model version and rights per model. | [official API specification](https://api.bfl.ai/docs) |
| Stability AI | Official REST | Image generation/editing services; current platform documents v2beta surface. Preview status and model licenses need recording. | [API reference](https://platform.stability.ai/docs/api-reference) |
| Ideogram | Official API | Image generation/editing, background removal and typography-oriented workflows. Final exact copy should still be rendered as deterministic text and checked. | [vendor API overview](https://ideogram.ai/api-learn/), [developer docs](https://developer.ideogram.ai/ideogram-api/api-overview) |
| Recraft | Official API | Images/vectors, edits and visual variants. Vendor routes and output types differ; SVG/editable claims need output inspection. | [vendor API](https://www.recraft.ai/api) |
| Kling | Official developer API; also through gateways when catalog supports it | Video generation with direct developer purchase/authentication. Do not equate API entitlements with website subscription. | [official quickstart](https://kling.ai/document-api/guides/get-started/quick-start) |
| Luma | Official API | Image/video generation; old Dream Machine docs direct builders to current Agents API docs. Do not implement only from old endpoint examples. | [migration notice](https://docs.lumalabs.ai/docs/welcome) |
| fal | Official model APIs/client/queue | Gateway for generation/editing. Capabilities, commercial rights, inputs and billing are per model, not guaranteed gateway-wide. | [model API example and queue guidance](https://fal.ai/models/fal-ai/ovi/api) |
| Replicate | Official predictions API/SDK | Hosted community and official models; async jobs, webhooks and model versions. Model licenses remain distinct from gateway access. | [prediction workflow](https://replicate.com/docs/topics/predictions/create-a-prediction/) |
| ComfyUI / Comfy Cloud | Local workflow API; documented cloud/API surfaces | Reusable node workflows for optional local or hosted generation. Pin models/custom nodes, hardware and licenses; local installation is not automatically private if cloud partner nodes are used. | [official project](https://github.com/Comfy-Org/ComfyUI), [versioned API spec](https://github.com/Comfy-Org/docs/blob/main/openapi-v2.yaml) |
| OpenArt | Discoverable connector | Generation advertised by plugin directory. No custom API endpoint or account access established here. | Section 2 discovery |
| Midjourney | Manual use; rare authorized exceptions only | Official guidelines say no general API and prohibit unauthorized automation. Do not adopt third-party “Midjourney API” services as supported adapters. | [official community guidelines](https://docs.midjourney.com/hc/en-us/articles/32013696484109-Community-Guidelines) |

Generated photos, original photography, photo editing, 3D rendering and coded layout are different provenance classes. Code can draw diagrams, composite photos, apply color/crop treatments and generate 3D imagery; realistic newly invented scenes require a model or a renderer and scene assets. Never describe synthetic material as photographed evidence.

## 5. Voice, captions, music, and presenters

| Tool | Connection / role | Boundary | Evidence |
|---|---|---|---|
| ElevenLabs | REST and SDKs for speech, transcription, music, effects and dubbing | Optional voice/audio provider; verify usage rights and consent for cloned voices. Generation costs and subscription entitlements are operation-specific. | [official API overview](https://elevenlabs.io/api) |
| HeyGen | Official API; discoverable connector | Avatar/presenter, dubbing and translation workflows. Use confirmed input rights/consent and API scope; do not confuse live avatar streams with finished video output. | [current quickstart](https://developers.heygen.com/docs/quick-start), [vendor API guide](https://www.heygen.com/blog/heygen-api-guide) |
| Synthesia | Official Video, Upload, avatar and billing APIs | Scripted presenters/templates; live avatar API is distinct from async finished Video API. Check plan and key scope. | [official API introduction](https://docs.synthesia.io/reference/introduction) |
| Whisper | Local model/script | Transcription and caption draft; speech errors, hallucinated segments and technical names still need review. | [official project](https://github.com/openai/whisper) |
| faster-whisper | Local Python implementation | Efficient local transcription with CPU/GPU options. Word timestamps are a starting point, not final forced-alignment accuracy. | [maintainer project](https://github.com/SYSTRAN/faster-whisper) |
| Existing recording + FFmpeg | Local files/CLI | User voice, trimming, mixing, loudness checks, stems, SRT/ASS overlays. Library text/subtitle filters depend on the installed FFmpeg build. | [official filters](https://ffmpeg.org/ffmpeg-filters.html) |

A trending song available in an app is not a license to bake that song into cross-platform commercial exports. Record track source, allowed uses and platform. Prefer an authorized track or user recording when reuse is required.

## 6. Rendering photos, graphics, carousels and videos through code

| Renderer / library | What can be coded | Recommended place | Evidence |
|---|---|---|---|
| SVG + HTML/CSS + Playwright | Editable vector layout, slide composition and browser-captured PNG/JPG | Shared brand tokens and carousel layout; lock browser/OS/fonts and wait for images/fonts before capture. | [screenshots](https://playwright.dev/docs/next/screenshots), [environment variance](https://playwright.dev/docs/test-snapshots) |
| Pillow | Raster compositing, type, diagrams, masks, overlays and image processing | Small Python asset jobs; measure text bounds and retain original photos. | [ImageDraw](https://pillow.readthedocs.io/en/stable/reference/ImageDraw.html) |
| Sharp | Resize/crop and raster processing in Node | Fast export transformations; keep color profile and aspect ratio explicit. | [resize API](https://sharp.pixelplumbing.com/api-resize/) |
| Remotion | React/TypeScript compositions, footage, captions, animation, stills | Strong proposed unified still/video renderer; frame-driven animation with one preview/export source. Check licensing for organization and product use. | [still rendering](https://www.remotion.dev/docs/renderer/render-still), [license/pricing](https://www.remotion.dev/docs/license/pricing) |
| HyperFrames | HTML compositions with timed media and animation rendered to video | Alternative to Remotion for HTML/GSAP-oriented authoring. Maintainer docs describe shared composition/playback/render model; local rendering is distinct from paid media add-ons. | [project](https://github.com/heygen-com/hyperframes), [developer architecture](https://github.com/heygen-com/hyperframes/blob/main/docs/developers/overview.mdx) |
| FFmpeg + ffprobe | Cut/concat, scale, crop, captions, encode, mix, frame/audio extraction and inspection | Required processing and technical QA layer regardless of chosen authoring renderer. | [filters](https://ffmpeg.org/ffmpeg-filters.html) |
| Manim | Python diagrams, math/engineering explanations, animated visual reasoning | Specialist scene renderer; compose its output into the general video pipeline. | [quickstart](https://docs.manim.community/en/stable/tutorials/quickstart.html) |
| Blender | Scripted cameras, lights, geometry, materials and motion | Specialist 3D pipeline; valuable for product scenes, not necessary for simple carousel MVP. | [API](https://docs.blender.org/api/current/) |
| Shotstack | JSON timeline REST rendering for video/image/audio | Cloud alternative when local rendering is unsuitable. Third-party upload and per-render costs. | [official reference](https://shotstack.io/docs/api/) |
| Creatomate | Template or RenderScript REST; preview SDK | Cloud batch stills/video with designer-authored templates; keep template revisions. | [quickstart](https://creatomate.com/docs/api/quick-start/introduction) |
| JSON2Video | JSON scene/element API | Cloud video assembly; inspect element/timing/voice functionality per schema. | [official tutorial](https://json2video.com/docs/tutorial/) |
| Bannerbear | Template image/video APIs and workflows; vendor documents MCP | Marketing asset variants; docs span V2/V3/V5, so pin current API rather than mixing examples. | [current developer resources](https://www.bannerbear.com/resources/developers/) |
| Cloudinary | Image/video transformation and delivery APIs | Resizing, cropping, overlays, subtitles and derived asset delivery. A transformation layer, not a full substitute for editorial source files. | [video transformation types](https://cloudinary.com/documentation/video_transformation_types) |

Proposed video-by-code flow:
1. Brief + asset manifest + script determine ordered beats and approved sources.
2. Storyboard supplies semantic layers, crop/focal points, text, captions, transitions and audio cues.
3. Timeline uses integer frames, one fps and half-open clip intervals; local animation time is frame minus clip start.
4. Render cover/stills and MP4 from the same style tokens/composition logic.
5. Inspect exported file, scene boundaries, captions and audio; review playback as well as sampled frames.
6. Deliver individual PNG/JPG slides and ZIP for carousels, MP4 plus captions/stems for video, and editable source where available.

No renderer was installed or benchmarked here. A remembered existing Remotion workflow may be a reuse candidate, but it needs a fresh code/export audit before adopting it. No cross-project code was imported.

## 7. Stock, source storage, planning, publishing and measurement

| App / surface | Feasible route | Caveat / place | Evidence |
|---|---|---|---|
| Pexels | Official photo/video REST API | Record asset URL, creator, download and applicable attribution/license requirements. Stock is illustrative, not project evidence. | [API documentation](https://www.pexels.com/api/documentation/) |
| Unsplash | Official photo API | API use has attribution and download/hotlinking guidelines separate from general photo-license shorthand. | [official docs](https://unsplash.com/documentation) |
| Adobe Stock | Official search/licensing API | Search is not license purchase. Preserve license record before distribution. | [official API](https://developer.adobe.com/stock/docs/api/) |
| Google Drive / Docs / Sheets / Slides | Available connector; native APIs | Sources, briefs, calendar, review copies and exports; sharing and native file conversion are explicit separate actions. | [Drive files overview](https://developers.google.com/workspace/drive/api/guides/about-files) |
| Airtable | Web API | Idea bank/calendar/metrics; tokens/scopes and plan call limits. Local JSON/CSV remains a simpler first default. | [official getting started](https://support.airtable.com/articles/6292134965-getting-started-with-airtable-s-web-api) |
| Postiz | Official public API | Channel connections, posts/uploads, scheduling and analytics; feature support varies by channel. No connection or subscription confirmed here. | [API overview](https://docs.postiz.com/public-api/introduction) |
| Buffer | Current GraphQL API; vendor advertises assistant/MCP route | API now exists across plans per vendor; do not rely on historical “closed API” statements. Verify account, channels and action scopes. | [current API overview](https://buffer.com/api), [plan/access guide](https://support.buffer.com/en-us/articles/using-buffers-api-GtIYIQilz5) |
| Instagram / Facebook | Meta publishing/insights route | Professional-account requirements and login/permissions differ. Direct official page retrieval was blocked in this survey; defer exact scopes/limits to adapter verification. | [official publishing docs, retrieval unverified](https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login/content-publishing), [Meta Postman overview](https://www.postman.com/meta/instagram/documentation/6yqw8pt/instagram-api?entity=request-23987686-6fa9ed1d-3310-4844-ad25-f0001ab66f11) |
| TikTok | Official Content Posting API | Supports photos/video; audit required to lift visibility restrictions. In-app effects/music and upload flows do not have complete API parity. | [official direct-post guide](https://developers.tiktok.com/docs/en/content-posting-api-get-started) |
| YouTube | Data API upload + Analytics API | Unverified projects' uploads are private until audit. Preserve upload ID before retry; separate draft/private upload from public publishing. | [upload reference](https://developers.google.com/youtube/v3/docs/videos/insert), [analytics](https://developers.google.com/youtube/analytics) |
| LinkedIn | Posts / Community Management APIs | Permissions, app access and version headers matter; not every account gets broad organizational analytics. | [official Posts API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api) |
| n8n | HTTP Request and vendor nodes | Optional automation runner, not a media editor. Credentials, node versions and schedule ownership add operations overhead. | [official HTTP integration](https://n8n.io/integrations/http-request/) |
| Zapier | Vendor integrations / HTTP workflow | Useful managed automation; each trigger/action must be assessed rather than assuming editor parity. | [Canva integration](https://zapier.com/apps/canva/integrations) |
| Make | Potential workflow runner | Vendor/app-specific action inventory not independently validated here; discovery candidate only. | [vendor site](https://www.make.com/) |
| vidIQ | Discoverable connector | Topic/competitor/analytics research advertised. Preserve observation date and distinguish estimated demand/scores from channel results. | Section 2 discovery |

This is the optional distribution layer. The architecture-only request does not authorize channel connection, scheduling or publication.

## 8. Additional candidates and honest coverage limits

Kapwing, Filmora, InVideo, Affinity, Final Cut Pro, Apple Motion, Audacity, Penpot, Excalidraw, Notion, Dropbox, Frame.io, Artlist, Epidemic Sound, Suno, Udio, Pika, Leonardo and Krea remain potential specialists or manual destinations. This survey does not establish a supported end-to-end API/MCP for each. Final Cut/Apple Motion also introduce a macOS dependency. Investigate only when an actual content requirement makes the candidate worthwhile; record vendor docs, OS, available operations and output fidelity before recommending an adapter.

Do not turn “every app possible” into an obligation to install every product. The capability contract makes the architecture extensible even when a vendor was not surveyed. No scraping service or unofficial desktop draft writer is represented as an official connection.

## 9. Adapter admission and priority

### Candidate tiers

- P0: local files, SVG/HTML stills, FFmpeg montage, local transcription; choose one of Remotion/HyperFrames later for richer reusable motion.
- P1: Canva editable output; optional generative gateway already available; user-approved brand context.
- P2: Figma, Adobe, Resolve, Descript, specialist voice/3D/cloud renderers when requirements justify them.
- P3: publishing/analytics/calendar automation; separate acceptance and authorization.
- Deferred: undocumented editing APIs, unsupported OS routes, roadmap-only features and restrictive automation routes.

### Required profile before execution

Record provider, surface (connector/API/SDK/CLI/files), observation date, official documentation, auth method/scopes, OS/host/version, operations, import/export formats, editability, model/schema version, cost source/units, data destinations, rights/provenance requirements, limits, failure semantics, and last successful sandbox fixture.

Use capability names such as read-assets, upload-assets, create-design, edit-design, export-still, render-video, transcribe, generate-media, publish, and read-metrics. Never expose one blanket “supports content” boolean.

### Required later probes (not performed)

- Basic round trip: authorized fixture input -> operation -> final export -> inspected dimensions/duration/content.
- Denied/missing entitlement: explicit status and useful local/file fallback; no silent upgrade or installation.
- Paid job timeout: preserve job ID; poll/query existing work instead of blindly resubmitting.
- Expired URL/auth: refresh through authorized provider flow; do not treat a remote link as a durable asset.
- Cross-editor handoff: verify editable text, crop, font substitutions, transitions and alpha; an imported flattened slide is reported as flattened.
- Publication: verify destination/account, payload hash, approval, external post ID and resulting visibility separately.
- Policy: disable generated media and confirm no generative API is invoked; distinguish transcription from synthetic imagery.
- Windows: confirm actual app edition/runtime/GPU rather than advertising vendor-wide compatibility.

## 10. Findings for Claude's architecture review

1. Keep the historical research intact; its Claude-only and personal no-AI constraints need a per-brand/per-client distinction.
2. Accepted ADR 0004's per-team targets mechanism remains useful; its rationale that Codex cannot use Canva is no longer a sound blanket premise given this session's exposed Canva tools. Any target expansion remains proposed.
3. The generic team does not need build changes for every vendor. Core agents can emit specifications; the main session resolves tools and executes external adapters.
4. Avoid adding unsupported plugin MCP/hook schemas just to encode provider-specific tool names. Existing inherit gives all session tools, not least privilege; prefer orchestration boundaries and scoped adapters.
5. Update dated claims: Canva Autofill Pro+; Premiere UXP GA; AE UXP future beta; current Buffer API; Sora retired; Descript media download requires web-link publication.
6. “Most viral” is a measurable experiment objective. No source supports one universally dominant aesthetic. Use the design-system recipes as hypotheses, then compare real outcomes within format/platform/audience.
7. Credentials, brand palettes, personal assets and channel IDs stay outside the public catalog. The architecture documents contain no account credentials or operational media.

## 11. Verification record

- Repository read: catalog and contribution conventions, existing plan/research, decision records and lessons.
- Live discovery: available session tools and plugin-directory results.
- External evidence: primary vendor/project documentation linked next to claims; uncertain/inaccessible routes labeled.
- Scope: only new planning documents written; no source/generated catalog changes, installs, renders, cloud mutations, commits or pushes authorized.
- Pending: user selection of reusable vs personal scope, media policy, target channels, editor preference, budget and operating cadence. Defaults are proposal choices only.

