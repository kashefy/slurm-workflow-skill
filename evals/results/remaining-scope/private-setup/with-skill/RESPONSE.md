I’m using the Slurm workflow skill to guide setup. No files have been created, and your supplied account value does not need to be repeated.

You can keep all site details private and enter them locally later. First, choose a private configuration directory outside both your project and the skill repository—for example, `${XDG_CONFIG_HOME:-$HOME/.config}/slurm-workflows/training`. Use a directory you own with permissions `700`, and configuration files with permissions `600`. Don’t commit this configuration.

Start with this worksheet; leave private values out of chat:

| Setting | What to record locally |
|---|---|
| Training command | Your existing Python command and arguments |
| Workflow | One training job, several dependent stages, or an array of independent runs |
| Python setup | Existing module loads, virtual environment, Conda activation, or container command |
| Shared paths | Project, input data, and output locations accessible from compute nodes |
| Site settings | Account, partition, and QoS; leave optional values unset if using site defaults |
| Resources | CPUs, memory, walltime, GPU count/type; array concurrency if applicable |

Reuse any existing training or submission scripts. Resource values should come from your site’s guidance or a representative training run; I won’t guess cluster limits.

The remaining policy choices depend on that setup: which environment variables jobs should inherit, and, for dependent stages, what should happen when a dependency cannot be satisfied. These need checking against your site’s Slurm version and conventions.

A later workflow can use a private wrapper that passes quoted settings to a standalone project launcher. It will run without this skill installed. Any local preview must be kept private because commands can reveal paths and arguments. There is no preview command yet because no launcher has been inspected or generated.

Cluster validation remains yours to perform: confirm valid account/partition settings, resource limits, Python availability, shared paths, and optionally site-supported `sbatch --test-only`. No cluster access or scheduler commands were used here.

**Self-reported audit**

Read only:

- `/tmp/slurm-final-validation-1a433d1/private-setup/with-skill/prompt.txt`
- `/tmp/slurm-final-validation-1a433d1/private-setup/with-skill/skill/SKILL.md`
- `/tmp/slurm-final-validation-1a433d1/private-setup/with-skill/skill/references/setup.md`

Exact commands, run from `/tmp/slurm-final-validation-1a433d1/private-setup/with-skill`:

```text
cat prompt.txt; cat skill/SKILL.md
cat skill/references/setup.md
```

Limitations: no project scripts were inspected; no files were created or modified; no workflow tests, network access, authentication, scheduler commands, or delegation occurred.
