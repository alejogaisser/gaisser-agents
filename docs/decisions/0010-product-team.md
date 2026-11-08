# 0010. Add a product team that closes a plan before the software team builds

- Date: 2026-11-07
- Status: accepted
- Decision: Add `product-team` with `product-discovery`, `product-spec`, `product-ux`, and `product-reviewer`. It takes an idea to a closed plan in `docs/product/<slug>/` with approval gates after the problem, the MVP scope (always kept), and the design, and at most 2 fix cycles after the review. It never builds: the spec's acceptance criteria use the software team's format and IDs, and the final report hands the spec to `software-team`. Discovery, spec, and reviewer run on the deep tier, UX on the standard tier, following Anthropic's model guide. Released as gaisser-agents 4.4.0.
- Reason: The software team starts from a task that is already decided; nothing checked whether an idea was worth building or cut it to an MVP. Reusing the software team for the build avoids a second engineer, and a separate reviewer closes gaps before code exists instead of after.
