# Web engines reference

Checked against: the project's own `package.json` and the framework's current documentation, 2026-11-08.

## Detect

- A `package.json` that depends on `phaser`, `three`, `pixi.js`, `@babylonjs/core`, `kaplay`, or `excalibur`, and no other engine marker.
- The engine version is the dependency's version in `package.json`.

## Project layout

- Read the `scripts` in `package.json` and the bundler's config (Vite, webpack, or another) to find the entry point and the output folder.
- Everything is code: scenes, levels, and UI are built in source files.

## Limits and workarounds

- There is no editor to script. Build levels from data files or procedural code.
- Visual quality that only a human can judge goes on the playtest list as a `manual:` check.
- Browser-only behavior (audio autoplay rules, fullscreen, input) needs a browser; use a browser smoke test when Playwright is present, and a `manual:` check otherwise.

## Build

- Use the project's scripts: `npm run build`. Do not add a bundler the plan does not name.

## Test

- Use the project's own runner for logic, for example Vitest or Jest, through `npm test`.
- Keep game rules in plain modules with no engine imports so the tests run without a browser.
- Run a browser smoke test when Playwright is present: load the page, check for console errors, and confirm the game reaches its first playable state.

## Performance

- Sample frame times with `requestAnimationFrame` and `performance.now()` in a scripted scenario of at least 10 seconds, then compute the average and the 95th percentile as `playtest-checks.md` says.
- `performance.memory` exists only in Chromium browsers; label memory numbers accordingly.
- A headless browser may not use the GPU; label such numbers as not representative of rendering.

## Networking

- Use WebSocket or WebRTC with an authoritative server. Validate every message on the server.
- Never put secrets in the client bundle.

## Editor bridge

- None needed. Use a browser automation tool when one is installed.

## Sources

- The project's `package.json` and the documentation of the engine it depends on, at the installed version.
