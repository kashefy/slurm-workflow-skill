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

## Evaluation dependency

Run the same entry point: `bash submit.sh /absolute/private/profile.sh`.
Training submission still prints exactly its numeric ID to stdout. Evaluation is
submitted with `--dependency=afterok:TRAINING_ID`; its numeric ID is reported on
stderr. The evaluation job sources the same private profile and invokes:

```text
PYTHON evaluate.py run_dir=RUN_ROOT checkpoint=best output_dir=RUN_ROOT/evaluation
```

Training and evaluation logs use `RUN_ROOT/logs/train.out` and
`RUN_ROOT/logs/evaluate.out`. The profile keys and training arguments are unchanged.
No agent tooling is needed on the cluster. Keep the trusted profile outside
project and skill repositories, and ensure its absolute path, PYTHON, project,
and RUN_ROOT are accessible from compute nodes.

If evaluation submission fails or returns an unclear ID, the entry point exits
nonzero after printing the already accepted training ID. Training remains
submitted. Inspect scheduler state before retrying, since rerunning this entry
point submits training again. An afterok dependency allows evaluation to run
only after successful training; if training fails, evaluation may remain pending
or be cancelled according to site policy. Successful training must produce the
expected best.ckpt for evaluation to work.

## Optional recommendations (not implemented)

- **Use a separate RUN_ROOT for each run.** Both training output and its fixed
  log path currently share RUN_ROOT; concurrent runs can overwrite artifacts or
  cause evaluation to read another run's checkpoint. Isolated roots improve
  correctness and traceability. Migration cost: low if humans select a new root
  per invocation, higher if automated naming and downstream path updates are
  introduced. Not required to add afterok, but advisable before concurrent runs.
- **Include job IDs in log filenames.** The fixed train.out and evaluate.out
  names can collide when runs share RUN_ROOT. Slurm's `%j` filename token would
  distinguish logs and simplify diagnosis. Migration cost: low, with updates to
  any log readers expecting fixed filenames. Not required for this request;
  log naming alone does not isolate checkpoints.
- **Record a private submission receipt.** Evaluation IDs currently appear only
  on stderr; a private receipt could retain both IDs and paths for recovery.
  Migration cost: moderate, requiring a receipt location and handling partial
  submission safely. Not required for this request.
