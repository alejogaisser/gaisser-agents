# 0005. Dev team handoff, acceptance criteria, failure routing, and memory

- Date: 2026-10-02
- Status: accepted
- Decision: Every plan starts with a handoff (Goal, Context, Constraints, Files to touch, Out of scope, Acceptance criteria); criteria are pass or fail checks written before coding; the tester classifies failures as `implementation` (coder) or `design` (architect), with at most 2 fix cycles; the architect keeps `docs/decisions/` and `docs/lessons-learned.md`.
- Reason: Approved by the owner to make handoffs explicit, define done before coding, send each failure to the right role, and keep project knowledge in the repository.
