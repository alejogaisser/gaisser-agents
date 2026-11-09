# Playtest checks

Shared by QA and the technical artist. Engine-neutral.

## Budgets

Use these unless the GDD or the context file says otherwise.

- Frame time, 95th percentile: 16.7 ms on desktop, web, and console; 33.3 ms on mobile or low-end hardware.
- Memory: from the context file. When it gives none, record `no budget` and report the measured value.

## Measuring

- Use a scripted scenario of at least 10 seconds after warm-up, so every run does the same thing.
- Record the average and the 95th percentile of the frame time, and the memory at the end.
- Headless runs (no window or no graphics device) measure CPU logic only. Label such numbers as CPU-only and not representative of rendering, and move GPU checks to the playtest list.

## Checklist areas

- Clean boot
- The first minute
- The core loop
- Win and lose
- Pause
- Restart
- Quit
- Each input device
- Resolutions and aspect ratios
- Audio
- Accessibility basics: readable text, cues that do not depend on color alone, documented or remappable controls, and captions when audio carries information

## Check format

Write each check in `docs/game/playtest.md` on one line:

`- [ ] PT<n> (<AC or mechanic>): <steps>. Expect: <result>.`
