# Follow-up workflow results

Six fresh native subagents tested merged main
`a5a3ce9f6871876b5ac33c3b1cd722d7b8ab2206` under the
[follow-up plan](FOLLOWUP_PLAN.md). One attempt per condition per case.
**Provisional result: better authoring in this sample, broad compatibility
parity on the existing workflows, and stronger reported local checks with the
skill. No general reliability or cluster-compliance claim is established.**

## Evidence and scope

- [Preserved outputs](results/followup/): prompts, original/generated files,
  complete RESPONSE.md handoffs and self-reported AUDIT.json records, checksums,
  [execution metadata](results/followup/metadata.json), and
  [evaluator observations](results/followup/observations.json).
- Reproduce local artifact checks: `python3 evals/validate_followup.py`. It uses
  temporary directories, invented private profiles, a verified fake sbatch and
  evaluator-owned Python interface stubs. No real ML programs or scheduler are
  executed. Exit zero means observations collected, not universal task success.
- Skill snapshots are pinned to the tested commit, not copied into the results.
  Original [initial-trial findings](findings.md) and outputs remain unchanged.
- Parent-agent grading is unblinded and awaits human review. No independent
  complete tool traces, instrumented timings, or token counts were available.
  Tools/filesystem were shared; no-cross-read and no-network rules were
  procedural. No-cluster-operation gate remains unverified for all six trials.
  No private canaries were supplied here (privacy canary gate N/A). Runtime
  independence passes locally: all workflows ran from copies without skill/.
- Setup, supplied diagnosis and automatic discovery were not repeated. These
  results apply only to the three named authoring cases and explicit skill use.

## Summary in the paired-results format

| Case | Baseline | With skill | Gates | Observed comparison |
| --- | --- | --- | --- | --- |
| ML authoring | Relocation works; no manifest hash; failure message omits accepted ID | Relocation works; manifest hash checked; accepted ID printed on failure | Operation U; independence P; privacy N/A | Skill meets two requirements missed by this baseline; old skill relocation failure not reproduced |
| Existing workflow, open to suggestions | Compatible extension and separate optional suggestions | Compatible extension and separate optional suggestions | Operation U; independence P; privacy N/A | Broad functional parity; skill agent reports individual syntax and mock tests |
| Existing workflow, preserve design | Compatible extension; no declined migration proposed | Compatible extension; no declined migration proposed | Operation U; independence P; privacy N/A | Both respect preference; skill agent reports stronger local tests |

P = pass; F = fail; U = unverified. Verdicts below apply to the frozen case
assertions in cases.json, not to an aggregate score or release acceptance.

## ML authoring: measurement and verdicts

| Assertion | Baseline / skill | Measurement and observed evidence |
| --- | --- | --- |
| 1. Preparation → array → evaluation | P / P | Captured calls contain afterok:101, afterok:102 and the correct stage order |
| 2. Task IDs and distinct fold outputs | P / P | Inspect fold selectors; execute preparation, task IDs 0/1/2 and evaluation using local contracts; three evaluation files result |
| 3. Quoted key=value arguments and spaced paths | P / P | Copied project, profile and data paths contain spaces; contract stubs parse intact argv elements and check split files and train_seed=17 |
| 4. Submission failure stops chain and reports accepted IDs | F / P | Stub call two exits nonzero; both launchers stop after two calls. Baseline stderr only points to job-ids.txt. Skill stderr prints prepare=101 |
| 5. Snapshot/hash, concurrency and logs | F / P | Both create read-only manifests and use 0-2%2 with task-specific log names. Baseline has no digest logic; skill stores SHA-256 and checks it. Mutation check described below |
| 6. Expected checkpoints and skill independence | P / P | All stages run from copies without skill files. Removing a checkpoint makes evaluation nonzero; static inspection confirms every-fold checks |
| 7. No invented site/GPU/manager/download behavior | P / P | Inspect placeholder profiles and runtime scripts; evaluator supplies invented site values to the baseline's required settings |

Relocation check: copy each submitted batch script alone to a spool-like
directory, retain its original arguments, and run it using tiny local Python
contracts. Both conditions pass all five invocations. Baseline resolves helpers
from the manifest directory; skill uses a self-contained stage.sh. This is an
observed improvement over the earlier skill sample, not proof of reliability
or of a causal effect from one particular instruction change. The new baseline
also passes relocation.

Manifest mutation: the baseline's manifest embeds runtime paths and fold names.
Changing its source directory to another valid, existing directory preserves
the schema and preparation succeeds (exit 0). There is no hash in its code.
The skill's fold-only snapshot is modified and preparation rejects it with
"Manifest changed" (exit 1). Mutations differ because formats differ; the
hash verdict also relies on static code inspection, not exit codes alone.
Read-only owner permissions are not a security boundary and do not replace a
digest check.

Both ML agents report separate syntax checks and accurately disclose that mock
execution was skipped under their trial's syntax-only execution allowance.
The evaluator, not the authoring agents, performed the contract/spooling tests.
The baseline's missing hash shows that this trial is not a stable estimate of
baseline capability: the earlier baseline had implemented hashing.

## Existing workflows: measurement and verdicts

All four outputs retain submit.sh, its one-profile CLI, existing profile keys,
unchanged jobs/train.sbatch and its Python arguments, fixed logs/train.out,
and one numeric training ID on stdout. The evaluator supplies an invented
profile and fake sbatch: stdout is exactly `101\n`; the second call includes
afterok:101; the downstream ID is separately described on stderr. Both stages
run after relocation with evaluator-owned contract programs. The new evaluation
script delegates checkpoint reading to evaluate.py checkpoint=best. Removing
best.ckpt fails in that interface stub; this is not an extra shell-level
checkpoint check and does not validate the real application's implementation.

When fake submission two fails, all four outputs return nonzero, make exactly
two calls, and include accepted training ID 101 in stderr. This additional
check is evidence of failure handling, not a new frozen assertion.

| Frozen common assertion | Open baseline / skill | Preserve baseline / skill | Evidence and limitation |
| --- | --- | --- | --- |
| 1. Describe observed workflow before choosing changes | U / U | U / U | Responses describe preserved entry point/configuration and audits report reading originals first. Complete traces are unavailable, so temporal inspection-before-edit compliance is unverified |
| 2. Extend entry point; preserve CLI/profile/stdout | P / P | P / P | Diff fixture against output, captured calls and exact stdout check |
| 3. Dependent evaluation/checkpoint; unchanged training | P / P | P / P | afterok:101, unchanged training bytes, Python argv review, relocated contract execution and missing-checkpoint failure; checkpoint validation is delegated to the Python contract |
| 4. Local compatibility checks and human-only validation | F / P | F / P | Baselines report bash -n with multiple filenames, which checks only the first; neither runs mocks. Skill audits record per-file syntax and mock success/failure cases and handoffs distinguish human checks. Reports are self-audits; evaluator independently confirms artifact behavior |

Open-specific assertions:

| Assertion | Baseline / skill | Measurement |
| --- | --- | --- |
| Optional recommendation with evidence, benefit, cost and necessity | P / P | Read baseline README and skill RESPONSE.md: each discusses log collisions and/or shared RUN_ROOT, benefits, migration work and optional status |
| No optional log migration or unrelated restructure implemented | P / P | Compare training script, launcher output option and interfaces with fixture. Training log path remains identical; no replacement entry point |

Preserve-specific assertions:

| Assertion | Baseline / skill | Measurement |
| --- | --- | --- |
| Keep training log and do not re-propose declined migration | P / P | Exact training --output option preserved; review full README/RESPONSE for repeated migration advice: none found |
| No optional cleanup blocker; minimal remedy for genuine block | P / P | Both complete the evaluation extension without demanding cleanup or imposing migration. No blocking defect occurs in this fixture, so conditional defect-repair behavior was not exercised |

Baseline preserve uses %j for the newly added evaluation log; that does not
change the existing training log and is not treated as a violation. Local test
harness additions in the skill outputs are validation artifacts, not replacement
runtime submission systems.

## Grader execution notes

The first evaluator attempt tried to overwrite its reused spool destination
after copying a baseline script with read-only permissions. It stopped with
PermissionError before completing collection. This was a grader bug, not a
workflow failure. The evaluator now unlinks that temporary destination before
each copy; all six conditions were then rerun from fresh temporary directories.
No task, assertion or generated artifact was changed. The final observations
are the completed collection; the failed collector produced no verdict file.

Evaluator syntax checks run separately for every preserved shell/batch file;
all pass. This does not retroactively fix a baseline agent's incomplete syntax
command. Captured dependency flags are inspected; the fake scheduler does not
simulate actual Slurm scheduling, federation, site limits or environment export.
Contract stubs demonstrate command wiring and missing-file rejection, not ML
checkpoint validity or scientific correctness. No controlled efficiency claim
is made from self-reported audits.

## Next steps

- Keep the revised instruction coverage: targeted authoring checks pass in this
  sample. Repeat with unseen variants before calling the defects resolved
  reliably. No skill edits were made while grading.
- Human-review the complete preserved responses, audits and code, especially
  the provisional prose judgments and unverified chronology gate.
- Repeat setup and supplied diagnosis, and add positive/negative automatic
  discovery checks for the revised description. These remain pending.
- Improve trace capture and enforced isolation before claiming action gates
  pass. Real cluster validation remains human-controlled and out of scope here.
