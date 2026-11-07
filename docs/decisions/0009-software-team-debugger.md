# 0009. The software team adds a debugger that runs before the plan

- Date: 2026-11-07
- Status: accepted
- Decision: The software team adds `software-debugger`, called on demand ("debug", "why does this fail"). It runs in a new Diagnose stage before the Plan stage, reproduces the bug, proves its root cause, writes a failing reproduction test, and proposes a fix classified as `implementation` or `design`, without changing production code. Its report goes verbatim to the architect, who turns each reproduction test into an acceptance criterion. Released as gaisser-agents 4.3.0.
- Reason: The architect cannot run code, so bug fixes were planned without a reproduction, and the test engineer only checks criteria written without knowing the cause. A separate agent on the deep tier keeps diagnosis apart from verification, and the reproduction test as a criterion links the two instead of duplicating them.
