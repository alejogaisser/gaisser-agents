# 0003. Team names, entry skills, and agent names

- Date: 2026-10-02
- Status: accepted
- Decision: Team names end in `-team`; each team has one entry skill named like the team (`/dev-team`, `$dev-team`); agent and skill names are unique across the catalog, and new teams prefix their agents (`content-`, `finance-`).
- Reason: Users call a team by domain, and manual installs and Codex have no namespaces, so names must not collide.
