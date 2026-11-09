# Other engines reference

Checked against: no engine in particular, 2026-11-08. Use this file for an engine without its own reference, for example Bevy (`Cargo.toml` with `bevy`), LOVE (`conf.lua`), or Defold (`game.project`).

## Detect

- No marker of Unity, Unreal, Godot, Roblox, or a web engine matched.
- Identify the engine from the build files and the README, and record its name and version in the plan.

## Project layout

- Read the README, the build files (for example `Cargo.toml`, `Makefile`, or `CMakeLists.txt`), and the CI configuration to learn the layout.

## Limits and workarounds

- Prefer code over editor work: define levels and content in data files or in code.
- When the engine has no command line for building or testing, say so, and turn those checks into `manual:` checks.
- Keep game rules in engine-free code with unit tests in the language's own test tool.
- When a documented command fails, read the log and the tool's own help (`<tool> -help` or `<tool> --help`) instead of guessing flags.

## Build

- Find the build command in the README, the build files, or the CI configuration. Use only a command you found there.
- If none exists, list the options with `<tool> -help` or check the installed version's documentation, and record the command in the plan before using it.

## Test

- Find the test command the same way. For logic, use the language's own test tool.
- Checks that need the running game are `manual:` checks.

## Performance

- Sample frame times in a scripted scenario with the engine's own timer and compute the average and the 95th percentile as `playtest-checks.md` says. If the engine cannot run headless, make it a `manual:` check.

## Networking

- Use the engine's own networking, server-authoritative, with every client message validated on the server. Check the installed version's documentation for its API.

## Editor bridge

- None assumed. Use an MCP server only when the project already configures one.

## Sources

- The engine's own documentation at the installed version, and the project's README and CI files. Ask through the report for the editor path when it is needed.
