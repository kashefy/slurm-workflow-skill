Extended `submit.sh` to submit evaluation with `afterok:TRAIN_ID`, and added `jobs/evaluate.sbatch`. README documents the extension.

Preserved the CLI, private-profile keys, environment setup, training log name, Python argument conventions, and single numeric training-ID stdout. Evaluation writes to `RUN_ROOT/evaluation`, logs to `RUN_ROOT/logs/evaluate.out`, and reports its job ID on stderr. Submission errors retain the accepted training ID in the diagnostic and never retry automatically.

Checks passed: separate Bash syntax checks for all three scripts; known local scheduler stub checks for numeric and cluster-qualified IDs, quoted paths, the dependency, unchanged training logging, failed evaluation submission, malformed evaluation output, and malformed training output. ShellCheck was unavailable. No workload, private profile, or real scheduler was run.

Human use, from the project directory: `bash submit.sh /absolute/private/profile.sh`. Before running, confirm shared paths, Python availability, site options and same-cluster routing for both stages; `SBATCH_OPTIONS` must not override parsable/dependency options. Cluster scheduling and workload correctness remain unverified. A failed training job can leave evaluation pending according to site dependency policy; inspect manually before any retry.
