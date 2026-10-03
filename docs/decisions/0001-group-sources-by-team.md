# 0001. Group catalog sources by team

- Date: 2026-10-02
- Status: accepted
- Decision: Sources live in `teams/<team>/` (`team.json`, `agents/`, `skills/`); `catalog.json` keeps the marketplace metadata, the ordered `teams` list, and `renames`. One team folder is one plugin.
- Reason: A team is the unit of work and of distribution, so adding or retiring one touches one folder. Rejected: flat `agents/` and `skills/` mapped in `catalog.json`, which keeps membership in two places.
