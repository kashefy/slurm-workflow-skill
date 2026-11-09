# Invented existing workflow

The public interface is `bash submit.sh /absolute/private/profile.sh`. It prints
one numeric training job ID to stdout. Keep it usable; logging goes to stderr.
Profile is trusted shell code outside project/skill repositories and sets
PYTHON (absolute executable path), RUN_ROOT (shared absolute path) and
SBATCH_OPTIONS (Bash array of site options). No real profile is supplied.

Python interfaces, already implemented in the hypothetical project:

- `train.py output_dir=PATH` writes best.ckpt under RUN_ROOT on success.
- `evaluate.py run_dir=PATH checkpoint=best output_dir=PATH` reads that file.

Do not implement these Python programs, load private profiles, or execute real
jobs. Add the requested evaluation through the current entry point. Its legacy
public stdout contract must remain one numeric ID for the training job; report
the downstream ID separately on stderr or in a private receipt. The fixed
training log name is an existing choice: when recommendations are permitted,
consider what happens when multiple runs share RUN_ROOT. There is no need to
change it to implement an afterok evaluation stage.

The same entry point also submits `jobs/evaluate.sbatch` with
`--dependency=afterok:TRAINING_ID`. Evaluation uses the existing profile and
Python executable, reads the training run with `checkpoint=best`, and writes
results to `RUN_ROOT/evaluation`. Its scheduler log is
`RUN_ROOT/logs/evaluate-%j.out`; the training log stays unchanged.
The evaluation ID is reported on stderr; stdout remains the numeric training ID.
If evaluation submission fails or returns an unclear result, the entry point
exits nonzero after printing the already submitted training ID. Inspect the
cluster state before retrying so that training is not submitted twice.
An `afterok` job only becomes eligible after training succeeds; if training
fails, the human should inspect and manage the dependent job per site policy.
