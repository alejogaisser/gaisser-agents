# Roblox reference

Checked against: Rojo v7 and the Roblox documentation, 2026-11-08.

## Detect

- `default.project.json` or another `*.project.json` (Rojo), `*.rbxl`, `*.rbxlx`, `wally.toml`, `rokit.toml`, or `aftman.toml` at the project root.
- Roblox Studio has no version file in the project. Take the version from the context file, if any.

## Project layout

- `default.project.json` maps folders to services and describes the instance tree. Rojo builds the place from the files.
- Scripts use suffixes: `.server.luau` for server scripts, `.client.luau` for client scripts, and plain `.luau` for ModuleScripts.
- Without Rojo, code lives inside the place file, out of the agents' reach. Propose adopting Rojo and ask the user first. Create a new project with `rojo init <name>`.
- Community tools, used only when the project already has them: Selene, StyLua, `luau-lsp`, and Wally.

## Limits and workarounds

- Never hand-edit `.rbxl` files. Define instances in Rojo files, or create them from scripts.
- Parts, terrain, and UI come from scripts or Rojo model files.
- There are no custom shaders. Set lighting, `Atmosphere`, `ParticleEmitter`, and `Beam` by property.
- There is no official headless Studio, so play tests are manual, or run through Studio's MCP server.
- Open Cloud Luau execution and publishing are outward actions that need the user's API key. Never write a key into a file or a prompt, and never run them without the user.

## Build

- `rojo build -o build.rbxlx` builds a place file; use a `.rbxl` output for the binary format.
- `rojo serve` starts the live-sync server for the Studio plugin.
- `rojo init <name>` creates a new Rojo project.

## Test

- No official headless Studio exists. Keep game rules in engine-free ModuleScripts and unit test them outside Studio with a Luau runner the project already uses.
- Studio play tests are `manual:` checks, or run through the Studio MCP server.
- Open Cloud Luau execution runs a script against a published place. It needs an API key with scope `universe.place.luau-execution-session:write`, and its edits are not persisted. It is an outward action: only the user runs it.

## Performance

- Sample `RunService.Heartbeat` deltas in a scripted scenario and read `Stats:GetTotalMemoryUsageMb()` at the end. Compute the average and the 95th percentile as `playtest-checks.md` says.
- Real device frame times need a manual check on the target hardware.

## Networking

- Roblox games are client and server by nature. The server is authoritative.
- Validate every `RemoteEvent` and `RemoteFunction` call on the server: argument types, ranges, ownership, and cooldowns. Rate limit each remote.
- Never trust the client for score, currency, damage, or position beyond a stated tolerance.

## Editor bridge

- Studio has a built-in MCP server. Enable it from Assistant, then Manage MCP Servers, then Enable Studio as MCP server.
- Use it for play-mode checks and console output. The older community `studio-rust-mcp-server` is no longer actively updated.

## Sources

- Rojo v7: https://rojo.space/docs/v7/getting-started/new-game/
- Open Cloud Luau execution: https://create.roblox.com/docs/cloud/reference/features/luau-execution
- Roblox Studio MCP server: https://create.roblox.com/docs/studio/mcp
