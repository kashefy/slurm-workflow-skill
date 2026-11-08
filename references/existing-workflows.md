# Working with an existing workflow

Before generating files, read applicable project instructions, workflow docs,
submission entry points, batch scripts, runtime/environment wrappers, public
configuration examples, and relevant tests. Stay within the requested project
scope; do not load private profiles merely to discover their values. Ask for
specific private information only when needed and authorized; offer placeholders
or local entry instead.

Summarize the observed execution path: Python command and arguments, environment
or container setup, dependencies, array task mapping, logging, inputs/outputs,
and configuration loading. Mark unverified or missing details. Do not infer
that an existing convention is accidental just because the examples differ.

Choose the smallest compatible change. Reuse the current submission entry
point, configuration interface, task IDs and output conventions. Add missing
capabilities through those interfaces instead of creating a parallel workflow.
Preserve unrelated behavior and tests. For consequential interface changes or
replacement, present the concrete migration and obtain the developer's choice
before implementing it. Do not ask for confirmation for routine compatible edits.

## Recommendations without unsolicited migrations

Complete the requested work using current conventions where feasible. List
optional improvements separately with:

- Evidence: the actual script/configuration behavior and its consequence.
- Benefit: the concrete failure or effort the change could reduce.
- Cost: affected interfaces/files, migration work and compatibility implications.
- Necessity: required for the request, or optional and safely deferrable.

Do not implement an optional recommendation unless the developer selects it or
the current task explicitly authorizes it. Do not copy existing private values
into the explanation. If the developer says to keep the workflow, honor that
choice, record deferred advice only when useful and authorized, and do not
repeatedly propose the same migration. Ask only when a consequential unresolved
choice blocks the requested result.

If an observed correctness problem prevents the requested result, explain the
specific failure and offer the smallest compatible fix. Do not conceal the
problem, declare all existing conventions unacceptable, or use it to justify
unrelated restructuring. If the developer declines a required fix, explain what
cannot be completed and leave their workflow intact.

Example: extending a container-based fold array should preserve its container
wrapper and fold IDs. A private-profile migration or alternate environment
manager is optional unless the request makes it necessary. The skill's generic
templates are starting points for missing pieces, not a preferred architecture.

Validate with relevant existing local checks and known scheduler mocks. Check
both the new behavior and preserved interfaces; use per-file syntax checks.
Separate unrelated weaknesses from blocking issues. Report changed files,
preserved interfaces, local results, human-run cluster checks, and any selected
or deferred recommendations. Never claim compatibility from code inspection
alone. No real scheduler or cluster interaction is permitted.
