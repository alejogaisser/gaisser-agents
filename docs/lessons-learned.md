# Lessons learned

- 2026-10-02: Verify platform behavior in the current docs before designing around it. Source: the premise that subagents cannot spawn subagents was outdated; they can, up to three levels by default.
- 2026-10-02: Check the platform for a native migration path before building one. Source: Claude Code's marketplace `renames` map replaced a planned alias plugin for `dev-pipeline`.
- 2026-10-05: Check how the host's menus nest before choosing the packaging unit. Source: the Claude Code slash menu nests only plugin -> skill, so one plugin per team gave one top-level row per team; one plugin for all teams keeps the menu tidy.
- 2026-11-06: Keep optional roles opt-in and slot them into a fixed stage order. Source: growing the software team from 3 to 10 agents without changing the default run.
- 2026-11-07: Check which roles can run code before assigning diagnosis. Source: bug fixes went straight to the architect, who has no shell, so no one reproduced a bug before planning its fix.
