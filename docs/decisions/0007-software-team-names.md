# 0007. The dev team becomes the software team

- Date: 2026-11-06
- Status: accepted
- Decision: `dev-team` is renamed `software-team`, with the entry skill `software-team` and `agentPrefix` `software-`. Its agents are named by job title: `software-architect`, `software-engineer`, and `software-test-engineer` (formerly `dev-architect`, `dev-coder`, `dev-tester`). New plans carry `<!-- software-team plan -->`; the older `dev-team` and `dev-pipeline` markers are still recognized. Released as gaisser-agents 4.0.0. The `renames` map is unchanged, because its entries name past plugins, not teams.
- Reason: The team will grow beyond plan, build, and test, and "software" names that domain better than "dev". Job titles say what each role does. `software-test-engineer` was chosen over `software-qa` and `software-tester` because the agent writes and runs tests, not only checks. Skills and agents have no renames map, so the README carries a migration note.
