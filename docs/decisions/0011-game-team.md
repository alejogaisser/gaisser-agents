# 0011. Add a game team with engine-agnostic roles and per-engine references

- Date: 2026-11-08
- Status: accepted
- Decision: Add `game-team` with `game-designer` (deep tier), `game-programmer`, `game-technical-artist`, `game-qa`, and an on-call `game-network-engineer` (standard tier, effort high). The roles are engine-agnostic, and the skill detects the engine from the project and loads only that engine's reference (Unity, Unreal, Godot, Roblox, web, other). It has a Design gate, a Review gate, at most 2 fix cycles, and jam as a mode, not a team. Released as gaisser-agents 4.5.0.
- Reason: One roster serves every engine, because agents differ by facts (layout, command line, test framework, limits), not by role, and references carry facts without duplicating prompts. Code-first workarounds (editor scripts, engine-free logic, a manual playtest list) cover what agents cannot edit visually.
