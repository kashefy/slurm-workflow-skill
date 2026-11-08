# Concrete instruction review

Review SKILL.md and every reference it directs the agent to read. Do not grade
from memory, intent, or an author's explanation. This rubric is new; it does
not retroactively change the frozen six-trial assertions.

For each check below record `pass`, `needs-work`, or `unverified`, the exact
file/section or quotation, and a specific correction where needed. Missing
required text is needs-work; inaccessible evidence is unverified. Do not infer
that a rule works in practice because it appears in the instructions.

| ID | Required evidence for pass | Concrete failure condition |
| --- | --- | --- |
| SR01 | Description identifies authoring AND supplied-evidence diagnosis; body explicitly covers single jobs, dependency chains, and arrays, directly or through named references | A task family is absent or left to an unnamed resource |
| SR02 | Body prohibits agent cluster connections, authentication, submission, cancellation and cluster commands; human-run submission remains allowed | Any prohibition missing, or instructions elsewhere direct the agent to do it |
| SR03 | Setup procedure asks for command, inputs, outputs, job shape, existing conventions; site questions follow only as applicable | Starts by inventing site facts or requires a complete cluster questionnaire for every task |
| SR04 | Configuration instructions explicitly name BOTH target-project and skill repositories as excluded storage locations; user selects external path; local private entry is offered | Says only 'repo' or 'both repositories' without identifying them, or requires values in chat |
| SR05 | Credentials are never requested; supplied logs/config are not persisted without authorization; redaction preserves relationships | Credential collection, silent persistence or inconsistent redaction advice |
| SR06 | Generated runtime helpers belong in the target project; running the workflow requires no skill installation or mandatory project instruction | Runtime source/import references skill checkout or requires skill adoption |
| SR07 | Each reference has a stated use condition: setup, dependencies, arrays, diagnosis | An undifferentiated list says only 'as relevant', leaving selection implicit |
| SR08 | Validation procedure specifies bash -n per file, scheduler stubs for dependency/failure checks, and human-only cluster validation; no claim local tests prove scheduler compatibility | Generic 'validate scripts', multi-file bash -n, or missing local/human distinction |
| SR09 | Batch jobs are instructed to use explicit shared helper paths or be self-contained; no dependence on the spooled script's directory | Known relocation failure has no preventive instruction |
| SR10 | Submission procedure stops on failure, preserves responses and reports accepted IDs; malformed responses forbid blind retry | Failure handling omitted, or receipt pointer alone substitutes for reporting IDs |
| SR11 | Diagnosis treats missing records as unknown, distinguishes tasks/steps and snapshot/current state, and requests focused next evidence | Missing evidence is called success/failure or live state is inferred |
| SR12 | Handoff enumerates generated files, unresolved settings, local checks actually run, human commands, and remaining uncertainty | No explicit completion checklist or equivalent output contract |
| SR13 | Existing-workflow discovery precedes edits; recommendations state evidence/benefit/cost/necessity separately; optional changes need selection; explicit keep-as-is preference is respected; blocking defects get a minimal fix proposal | Generates parallel infrastructure, silently migrates interfaces, repeatedly pushes declined advice, or hides a blocking correctness problem |

Check cross-file contradictions for every row. A local mock's output is not a
real submission, but the reviewer must not turn an ambiguous permission into a
claim of verified behavior. For scope expansion, change the rubric explicitly
rather than quietly accepting contradictory instructions.

## Recorded review and routine enforcement

The current review is in reviews/skill-review.json. Its input hashes cover
SKILL.md, this rubric, and all references. `python3 scripts/audit.py` rejects a missing or
stale review and malformed/missing review rows. It prints outstanding findings;
it does not pretend to grade prose automatically. A matching hash proves only
that the recorded review applies to those bytes.

When instructions change, read the diff and affected references, review all
rows, update evidence/corrections and input hashes, and record the reviewer's
identity. Do not update hashes without doing the review. Behavioral changes
also need the affected fresh-agent trials under AUDIT.md. An agent review is
provisional until a human reviews it.

Open needs-work/unverified rows are visible development debt. Before claiming
the instruction review is clean, run
`python3 scripts/audit.py --require-clean-review`; it fails on either verdict.
Default development CI still permits explicitly recorded debt. This keeps
known defects visible without silently marking the experimental skill ready.
