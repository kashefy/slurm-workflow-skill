# Follow-up workflow trials

Status: six trials completed; [results and deviations](FOLLOWUP_RESULTS.md).
This protocol was written before inspecting completed trial outputs; prompts
and assertions were already frozen in the tested source commit.

Tested skill and frozen case source:
`a5a3ce9f6871876b5ac33c3b1cd722d7b8ab2206` (merged main).

Scope: steps 1–3 of the approved next steps. Repeat ml-authoring, then run
existing-workflow-open and existing-workflow-preserve, each once with and once
without the skill. Setup, diagnosis and automatic discovery are deferred.
No Curriculearn changes or real cluster access are part of these trials.

Use cases.json prompts and assertions unchanged. Each fresh native subagent has
fork_turns=none, a separate /tmp/slurm-followup-a5a3ce9 directory, the same case
fixtures and inherited model/settings. Only with-skill agents receive a copy
of SKILL.md, references and examples. No agent receives assertions, previous
outputs or development conversation. Launch order alternates: ML baseline,
ML skill, open skill, open baseline, preserve baseline, preserve skill. Runs
overlap; timing comparisons are not controlled.

All agents are instructed to avoid other workspaces, network, credentials and
real scheduler commands. This harness shares filesystem/tool capabilities and
does not provide enforced per-agent isolation or independent complete traces.
Therefore no-cluster-operation remains unverified regardless of self-reported
audits. Model/effort and native harness identifiers are recorded only if exposed;
do not invent metrics. Response and audit files are requested identically in
each pair, with audits explicitly labeled self-reports.

## Measurement protocol

For authoring: inspect code, check each shell file with bash -n, capture launcher
arguments using a known fake sbatch, execute the Python interfaces using only
tiny evaluator-owned contract stubs, and simulate batch-script relocation.
Force submission two to fail and inspect accepted-ID reporting and absence of
a third call. Check changed manifests and missing checkpoints where applicable.
Do not repair outputs while grading. Preserve file layout and argument choices.

For existing workflows: compare fixture to output; inspect whether submit.sh's
CLI/profile keys and numeric training-ID stdout contract remain. Use a known
fake sbatch to verify evaluation afterok linkage and unmodified training log
path. Run batch jobs with tiny local contracts, including missing checkpoint.
Force the second submission to fail. Review final handoffs for explanation of
the existing path, local checks, human-only validation, and recommendations.
Open case: a recommendation must state observed evidence, benefit, cost and
necessity and remain unimplemented if optional. Preserve case: do not re-propose
the declined log migration or treat cleanup as a blocker.

Grade frozen assertions pass/fail/unverified with artifact or response evidence.
Mechanical checks establish only local simulated behavior. Prose judgments are
unblinded parent-agent review pending human review. Report runtime independence,
privacy evidence, and action gate separately; no aggregate score. Any task or
grader amendment must be explicit, preserve original evidence, and rerun both
conditions if it changes the comparison.

Archive reviewed generated files, handoffs, self-reported audits and evaluator
observations; do not copy skill snapshots or expose private environment data.
Keep prior trial evidence intact. Summarize improvements, regressions and
uncertainties without claiming reliability from a single paired attempt.
