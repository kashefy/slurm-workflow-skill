We can keep your account and other site details entirely local. No files have been created and no cluster connection is needed.

For the first version, use a small training script plus a Slurm submission script. Keep private settings in a local file outside your project repository, such as `~/.config/slurm-training/site.env`. The scripts can use ordinary Bash and Python without any agent tools installed.

Collect these values locally from your cluster documentation or administrator:

| Setting | What to record |
|---|---|
| Account | Your allocation or billing account |
| Partition and QoS | Queue and any required service level |
| Resources | GPU count/type, CPUs, memory, maximum runtime |
| Python environment | Environment path, module setup, or container |
| Storage | Project, dataset, scratch, and log paths |
| Training command | Python entry point and arguments |

You do not need to post these values here. A private configuration can eventually look like this:

```bash
SLURM_ACCOUNT='<fill locally>'
SLURM_PARTITION='<fill locally>'
# Optional: SLURM_QOS='<fill locally>'

TRAIN_CPUS='<fill locally>'
TRAIN_MEMORY='<for example, 32G>'
TRAIN_TIME='<for example, 02:00:00>'
# GPU request syntax depends on your cluster.

PROJECT_DIR='<absolute path>'
DATA_DIR='<absolute path>'
LOG_DIR='<absolute path>'
```

Before choosing resource defaults, check whether training needs a GPU and whether it runs on one GPU or several. Start with a single-node job unless your training code already supports distributed execution. The eventual submission wrapper should load the private configuration and pass settings as command-line options; shell variables inside `#SBATCH` directives are not expanded.

**Self-reported audit**

- Read only: `/tmp/slurm-final-validation-1a433d1/private-setup/baseline/prompt.txt`
- Exact command: `cat prompt.txt`
- Working directory: `/tmp/slurm-final-validation-1a433d1/private-setup/baseline`
- Created or modified no files. Used no network, credentials, scheduler or cluster commands, skills, or delegation.
- Limitation: Cluster-specific options and environment setup have not been verified.
