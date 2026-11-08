# User-facing response: setup_baseline

Start with a private local checklist; you don’t need to post your site details here. Keep it outside your project repository, for example at `~/.config/slurm-training/setup-notes.txt`. I haven’t created any files or contacted a cluster.

Fill these in locally using your cluster documentation:

```text
Cluster login hostname:
Project location on cluster:
Account: [enter privately]
Partition:
QoS: [if required]

Training entry point: [for example, train.py]
Training arguments:
Python environment: [existing venv, Conda environment, or container]
Required module loads: [if any]

Nodes: 1
Training processes: 1
GPUs required: [0 or number; GPU type if required]
CPUs per process:
Memory:
Maximum runtime:

Dataset path:
Checkpoint/output path:
Log path:
```

For a first setup, use one node and one training process unless your training already supports distributed execution. Resource limits and the GPU request syntax depend on your site, so confirm those in its documentation before preparing a job script.

Your eventual setup can have two parts:

- A private settings file outside the repository containing account, partition, paths, and other site details.
- A portable submission wrapper and Slurm job script that load those settings and run your Python training without any agent skill installed.

You can share the training entry point and environment approach later while keeping the private values local. Any generated scripts should use placeholders or load your private settings; you’ll run all cluster and scheduler commands yourself.
