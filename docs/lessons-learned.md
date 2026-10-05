# Lessons learned

- 2026-10-02: Verify platform behavior in the current docs before designing around it. Source: the premise that subagents cannot spawn subagents was outdated; they can, up to three levels by default.
- 2026-10-02: Check the platform for a native migration path before building one. Source: Claude Code's marketplace `renames` map replaced a planned alias plugin for `dev-pipeline`.
- 2026-10-05: Check how the host's menus nest before choosing the packaging unit. Source: the Claude Code slash menu nests only plugin -> skill, so one plugin per team gave one top-level row per team; one plugin for all teams keeps the menu tidy.
