# 0002. Rename plugins with the marketplace renames map

- Date: 2026-10-02
- Status: accepted
- Decision: `dev-pipeline` became `dev-team` 2.0.0 through `"renames": {"dev-pipeline": "dev-team"}` in `catalog.json`, emitted into `.claude-plugin/marketplace.json`. The map is append-only.
- Reason: Claude Code v2.1.193 and later migrate users' settings to the new name. Rejected: an alias plugin, which would register every agent twice.
