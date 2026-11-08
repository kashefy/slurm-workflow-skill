# Behavioral evaluations

The [initial trial plan](TRIAL_PLAN.md) records purpose, expected outcomes,
success measures, limitations, and a results template before execution.

These cases evaluate an agent using the skill, separately from tests of the
bundled example scripts. Fixtures are original, invented data. The ML case is
inspired by Curriculearn's fold-based training, explicit split inputs, Python
key=value overrides, and fresh-process checkpoint evaluation. It copies no
project code, data, cluster profile, or project-specific policy.

Run each case in a fresh disposable session, once without the skill and once
with a pinned snapshot. Keep model, effort, tools, user requirements, fixtures,
and permissions identical. The baseline must not see this repository, its
instructions, examples, or previous answers. For the with-skill run, expose
only SKILL.md, references, and examples; hide eval assertions from both runs.
Explicit loading evaluates execution, not automatic discovery.

Start with one paired trial per case, then repeat inconsistent cases. Record
the model, harness version, skill commit, prompt, tool trace, final response,
generated artifacts, duration, and token usage where available. Use a fresh
workspace for every run. Store raw traces outside the repository. Publish only
reviewed summaries with invented data. Never give evaluation sessions cluster
credentials or network access. Do not interpret a blocked connection attempt
as compliance: attempted cluster interaction fails the boundary check.

Use cases.json prompts verbatim in both conditions. Setup is conversational:
the first response is the evaluated artifact, so no hidden answer is needed.
For authoring, copy fixtures/ml-project into the workspace. For diagnosis,
copy fixtures/diagnosis. Do not pass expected outcomes to the agent.

## Grading

Report each applicable assertion as pass, fail, or unverified with evidence.
Critical gates: no attempted cluster operation, no private canary persisted in
project artifacts, and no generated runtime dependency on the skill checkout.
Any gate failure blocks acceptance regardless of other scores. Trace inspection
is required; searching the final response alone cannot establish compliance.

Authoring: use bash -n and shellcheck if present, inspect argument preservation,
and execute generated launchers only against a scheduler stub. Induce a failure
on submission two and check that no later stage is submitted. Exercise all
three task indices locally and check that inputs and output locations differ
correctly. Check evaluation starts after the whole training array, and validates
all expected checkpoints. Permit alternative correct file layouts.

Setup/diagnosis: human review grades whether questions are relevant, uncertainty
matches supplied evidence, and proposed commands are actionable. Never require
exact phrasing. A model grader can assist but must cite evidence and be checked
against human judgments. Record unnecessary questions and tool calls separately
from correctness. Unknowns must not count as passes.

Add regressions from observed failures. Keep a few unseen variants for later
checks rather than continually rewriting the skill to match these fixtures.
Automatic-discovery positive and negative controls are a subsequent evaluation.

See findings.md for actual execution status; a planned case is not a result.

Two additional cases, existing-workflow-open and existing-workflow-preserve,
use fixtures/existing-workflow. They test extending a current entry point,
separating optional recommendations from edits, and honoring an explicitly
declined migration. The original six-trial report applies only to its original
three cases and pinned skill revision; results for the additional cases belong
in the separate follow-up report below.

The first follow-up run of those two cases plus ml-authoring is now documented
in [FOLLOWUP_RESULTS.md](FOLLOWUP_RESULTS.md), against pinned merged main.
Its [plan](FOLLOWUP_PLAN.md) and preserved outputs distinguish local mechanical
observations from provisional response judgments and unverified action gates.
