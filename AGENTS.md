# Contributor guidance

Before every commit, run `python3 scripts/audit.py` and follow [AUDIT.md](AUDIT.md).
For procedure, template, or trigger changes, run the affected fresh-agent
evaluations or explicitly document why they remain pending. Passing local
checks alone does not establish skill quality.
When SKILL.md, its references, or the instruction-review rubric changes,
perform the evidence-based checks in SKILL_REVIEW.md and update the recorded
review; never refresh its hashes without reviewing the content.

Keep this skill small, portable, original, and optional. Do not add cluster
access, execution, authentication, synchronization, installation, monitoring,
or automatic retry machinery. Preserve the separation between agent advice and
commands a human chooses to run. Examples must use invented values or
placeholders, never private site configuration or logs.

When modifying scripts, run the local checks in README and exercise failure
paths with the scheduler stub. Do not claim stub tests establish behavior on a
real cluster; identify version- and site-dependent behavior explicitly.
