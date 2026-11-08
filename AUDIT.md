# Development audit

Run `python3 scripts/audit.py` before every commit. CI runs it on pushes and
pull requests, requiring ShellCheck. This is a fast regression gate, not proof
that agent behavior improved. No API calls, cluster access, or ML compute are
part of the audit.

It checks required skill metadata and referenced files, local documentation
paths, evaluation prompts/assertions/fixtures, preserved evidence checksums,
Bash syntax per maintained script, ShellCheck when available, and workflow unit
tests. Historical trial scripts remain unchanged evidence, including known
defects. Metadata checks are not a full Agent Skills schema validator; links
are checked for local paths, not anchors or remote URLs.

## Review on every change

For the instructions themselves use [SKILL_REVIEW.md](SKILL_REVIEW.md): twelve
specific checks with evidence and failure conditions. The local audit rejects
stale or incomplete recorded reviews. It reports unresolved findings; use
`--require-clean-review` to require that none remain.

- Is the skill still limited to authoring and diagnosis from supplied evidence?
- Are cluster values configurable and private files outside both repositories?
- Will generated workflows run without the skill checkout?
- Do instructions teach concrete procedures without unnecessary explanation?
- Does each result have an explicit measurement and limitations?
- Are changed requirements and corrected grading clearly distinguished?

Review these questions against the diff; keyword scans cannot establish them.
Record answers and the local audit outcome in the PR description.

## When to run fresh-agent evaluations

| Change | Additional verification |
| --- | --- |
| Skill procedure, reference advice, or templates | Repeat the affected baseline/with-skill case in fresh sessions; record skill/model/harness revisions and evidence |
| Trigger name or description | Run positive and negative discovery cases; explicit loading is insufficient |
| Runtime helpers | Exercise affected failure paths with stubs; repeat related authoring case when generated behavior changes |
| Grader or fixture | Preserve prior results, explain amendments, and rerun both conditions if the judgment changes |
| Documentation wording only | Local audit and review; no new behavior claim without new evidence |

Before a release, review all cases and unresolved findings. Repeated trials and
independent human review are needed for reliability claims. Green CI cannot
override failed or unverified behavioral gates. The initial script-relocation
defect remains open until fixed and evaluated separately.

Use [the plan](evals/TRIAL_PLAN.md), [methods](evals/MEASUREMENTS.md), and
[findings](evals/findings.md) to record evaluations. Raw traces and private
inputs remain outside the repository; publish only reviewed evidence.
