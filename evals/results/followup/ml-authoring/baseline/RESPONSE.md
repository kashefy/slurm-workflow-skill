Prepared standalone Bash/Slurm wrappers:

- `submit.sh`: creates a unique run directory, snapshots a read-only manifest and wrappers, captures checked job IDs, and records accepted jobs in `job-ids.txt`.
- `prepare.sbatch`: prepares and verifies all three folds.
- `train.sbatch`: maps array IDs 0–2 to fold-00–fold-02, with concurrency two.
- `evaluate.sbatch`: evaluates all folds sequentially in separate Python processes after the entire training array succeeds.
- `common.sh` and `site-config.example.sh`: shared loader and private configuration template.

Human setup and submission:

1. Copy `site-config.example.sh` outside your project repository and restrict access (`chmod 600 /absolute/private/site.sh`). Fill in all paths, account, partition, stage time limits, CPU counts, memory and any GPU/site options.
2. Provide an absolute shared environment setup file that activates an already installed Python environment without network access. All project programs, staged inputs, run paths, and environment setup must be accessible on compute nodes. Use Bash 4+ and Slurm with `sbatch --parsable` support.
3. Review stage resource options and wrappers. Extra options must not override dependencies, array settings, working directory, or log paths. Configure single-cluster submission; federated output is parsed but cross-cluster dependency routing is not implemented.
4. From the wrapper directory, run `bash submit.sh /absolute/private/site.sh` on the cluster submission host. This is a real submission command for the human only.
5. Inspect the printed run directory, `job-ids.txt`, and logs. Failed prerequisites prevent downstream execution; the site may leave those jobs pending. If submission stops midway, accepted jobs remain active. Inspect and manage them manually before resubmitting; resubmission creates a new run.

Local validation: `bash -n` passed individually for all six Bash files. No scheduler command, workload, package installation, authentication, or network access was performed. Python implementations were neither created nor executed.

The line-based manifest preserves spaces and key=value arguments through Bash arrays and quoting, without eval. Newlines and carriage returns in settings are rejected. Its read-only permissions prevent accidental changes, but the owner can deliberately change permissions; keep run artifacts unchanged. Existing Python programs and the environment setup remain external and must also remain stable for reproducibility. No scheduler integration or runtime behavior was tested.
