# 0008. The software team adds groups that run only when called

- Date: 2026-11-06
- Status: accepted
- Decision: The software team adds seven agents in three groups that never run unless the user calls them: a diagram run (`software-diagrammer`, `software-docs-writer`), a review (`software-security-reviewer`, `software-code-reviewer`, `software-performance-reviewer`), and specialists (`software-devops`, `software-db-engineer`). Calls can be mixed and always run in the order plan, build, verify, review, diagram run, record. Reviewers are read-only and run in parallel; their `critical` and `high` findings share the 2-cycle fix loop when the run built the change. Released as gaisser-agents 4.2.0.
- Reason: More roles must not make every run slower or costlier, so the core flow stays the default and each group is opt-in. A fixed stage order makes any mix predictable, and docs run last so they show the final code.
