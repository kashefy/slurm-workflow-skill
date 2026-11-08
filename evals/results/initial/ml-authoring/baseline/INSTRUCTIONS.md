# Configuration and human submission

These wrappers require Bash, Slurm sbatch, sha256sum, and a shared filesystem
visible under identical absolute paths on submission and compute nodes.
The three Python programs must already exist in PROJECT_DIR. No Python
implementations, packages, datasets, or credentials are supplied here.

1. Copy config.example.sh to a private location outside project repositories,
   e.g. ~/.config/ml-run.sh, and restrict it with chmod 600.
2. Configure PROJECT_DIR, staged SOURCE_ROOT, and a new absolute RUN_ROOT
   outside project repositories. Its parent must already exist. Use a new run
   directory on every attempt; submission refuses an existing one.
3. Configure each phase's options arrays for the site's account, partition,
   time, memory, CPU, accelerator and QoS requirements. Do not put array,
   dependency, output, wrap, or script replacement options in those arrays.
4. Set PYTHON to an executable/argument array. If required, set ENV_SETUP to
   an absolute, trusted Bash script that loads modules or activates an existing
   environment. All packages and inputs must be available offline.
5. Keep this wrapper directory, the private configuration, staged data, and
   Python programs unchanged until all jobs finish. Paths can contain spaces;
   each key=value argument is passed as one Bash array element without eval.
   Slurm treats percent sequences in output paths specially; avoid percent
   characters in RUN_ROOT. Use a single cluster (no federation/multi-cluster
   submission options).

Local validation (safe; does not submit or run Python workloads):

```bash
bash -n common.sh config.example.sh submit.sh prepare.sbatch train.sbatch evaluate.sbatch
bash -n /absolute/private/ml-run.sh
```

Human submission, from this wrapper directory, after reviewing configuration:

```bash
bash submit.sh /absolute/private/ml-run.sh
```

The submission script creates a read-only folds.txt manifest mapping array
indices 0, 1, 2 to fold-00, fold-01, fold-02. Its SHA-256 is captured at
submission and checked by every job. Read-only permissions prevent accidental
edits; checksum validation rejects later changes, including owner edits.
The manifest.sha256 file records the digest for inspection.

Preparation must succeed before the training array starts. The array runs
three folds with at most two concurrent tasks. Evaluation depends on successful
completion of the entire array and invokes a fresh Python process for every
fold. Checkpoints and prepared lists are checked for existence.

Only checked numeric job IDs from successful sbatch --parsable calls are used
in dependencies and saved in jobs.tsv. Logs are in RUN_ROOT/logs. If any
submission fails or returns an unexpected response, submission stops; already
submitted jobs may still run. The human must inspect these jobs and decide
whether to cancel or retry. Failed prerequisites may leave dependent jobs
pending according to site policy. No cancellation or automatic resubmission
is performed.

Validation performed during authoring: Bash syntax checks passed. Scheduler
behavior, resource compatibility, Python programs, environment activation,
and real data processing were not executed or validated.
