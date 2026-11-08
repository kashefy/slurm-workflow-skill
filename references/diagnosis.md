# Diagnosis from supplied evidence

Ask the human to share consistently redacted submission commands and errors,
job IDs and dependency relationships, relevant stdout/stderr, and (where
available) their own `squeue`, `sacct`, and `scontrol` output. Request only the
next useful group of evidence. Apply SKILL.md's privacy and evidence rules.

For example, the human can consult site documentation and run commands such as
`squeue -j JOBID`, `sacct -j JOBID --format=JobID,State,ExitCode`, and
`scontrol show job JOBID`, replacing the placeholder. These require cluster
access; the agent does not execute them. Check which job or array element each
row describes, its state, exit code, reason, dependencies, and timestamps.
Compare application errors and resource requests with site limits and the
available environment. Accounting can be delayed, disabled, or incomplete.
Distinguish job/array-element rows from steps such as .batch and .extern; do not
count those as additional array tasks or attribute step measurements to a job
without naming their source. State when the supplied output was captured, if
known. Snapshot state does not establish current live state; request fresh
human-supplied evidence only when the distinction affects the next decision.

Missing logs, completion markers, or accounting rows mean **unknown** unless
other evidence establishes the state. Distinguish a submission failure from a
pending dependency, an application error, and resource exhaustion. Explain
uncertainty and suggest a focused next human-run check. Do not automatically
resubmit, rerun selected elements, or cancel invalid dependents; first obtain
an explicit user-selected policy.
