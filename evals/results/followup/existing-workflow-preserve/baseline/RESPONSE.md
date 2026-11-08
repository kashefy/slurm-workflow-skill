Added evaluation through the existing `bash submit.sh /absolute/private/profile.sh` interface.

- Evaluation uses `afterok:TRAINING_ID`, the existing profile keys and Python argument conventions, and writes results to `RUN_ROOT/evaluation`.
- Stdout remains one numeric training job ID. The evaluation ID goes to stderr.
- Training environment, configuration, and `logs/train.out` naming are preserved.
- Evaluation submission errors produce a nonzero exit and an inspect-before-retry message; training may already be submitted.

Validation: `bash -n submit.sh jobs/train.sbatch jobs/evaluate.sbatch` passed. No scheduler commands, private profiles, or workloads were run. Cluster behavior remains untested; the human runs cluster commands.
