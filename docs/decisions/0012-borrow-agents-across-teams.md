# 0012. Let an entry skill borrow another team's agents by plain name

- Date: 2026-11-08
- Status: accepted
- Decision: An entry skill may borrow another team's agents by plain name, because skill tokens only name the skill's own team. The game team borrows the software architect for planning, and the debugger, the reviewers, devops, and the diagram run on call. Shared contracts, such as the handoff template, are copied and kept identical by a test.
- Reason: It avoids duplicate prompts that drift apart, without a change to the build's schema. The cost is that the build does not validate borrowed names, so a test checks that each exists.
