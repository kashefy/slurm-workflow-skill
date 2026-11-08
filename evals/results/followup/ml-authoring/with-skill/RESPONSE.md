Created `workflow/submit.sh`, `workflow/stage.sh`, `workflow/folds.txt`, and `workflow/profile.example.sh`. They preserve the supplied Python interfaces and quoted key=value arguments, including paths with spaces. No Python implementations were added.

The launcher makes a fresh run directory and read-only, SHA-256-checked manifest snapshot. It captures `sbatch --parsable` responses in private receipts, checks numeric IDs and cluster consistency, and submits preparation → `afterok` training array `0-2%2` → `afterok` evaluation. Evaluation starts a separate Python process for each fold. Submission failure stops the chain and reports accepted jobs; malformed responses are retained because a job may already have been accepted. No automatic retries or cancellations occur.

Human setup and use:

1. Place this workflow directory under the project containing the existing `prepare.py`, `train.py`, and `evaluate.py`.
2. Choose private configuration and receipt locations outside both project and skill repositories. Use private directories with mode 700 and profile/environment files with mode 600. Copy the placeholder profile there and edit it locally. Source only trusted, user-owned files.
3. Configure absolute shared paths, staged data, Python environment setup, and stage-specific account/partition/QoS, CPU, memory, walltime and GPU options. Review the empty option arrays deliberately; they currently use site defaults. Choose an export policy with your site. The environment setup file must make `python3` and required packages available offline on compute nodes.
4. From the project directory, preview locally (this creates fresh directories and a manifest but submits nothing):

   ```bash
   SLURM_WORKFLOW_PREVIEW=1 bash workflow/submit.sh '/absolute/private/profile.sh'
   ```

5. After human review, submit:

   ```bash
   bash workflow/submit.sh '/absolute/private/profile.sh'
   ```

Keep preview output and receipts private. All project, environment, manifest/receipt and run paths must be visible at identical absolute paths on compute nodes. Batch scripts receive every path as an explicit argument, so Slurm spooling does not affect helper discovery. The read-only snapshot and hash detect accidental edits; they do not prevent malicious owner modification.

Validation: separate `bash -n` checks passed for all three shell files. Stub submissions, failure injection, task execution, output-content validation, spool simulation and ShellCheck were not run under this trial's syntax-check-only execution constraint. Workload output checks cover nonempty split files and checkpoints; their semantic correctness and evaluation outputs require the real application's validation contract.

Human cluster checks remain: supported Slurm options/version, same-cluster routing, account/partition/QoS, resource and array limits, shared filesystem access, Python setup, log substitutions, export policy and invalid-dependency behavior. Use site-supported `sbatch --test-only` checks if appropriate. Failed predecessors can leave dependents pending; inspect receipts and scheduler state before deciding what to do. No scheduler command or workload was run here.
