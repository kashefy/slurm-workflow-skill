# Guided private setup

First ask for the Python invocation, inputs, outputs, and desired stages. Ask
whether the user needs a single job, a dependency chain, or an array. Inspect
existing project conventions before suggesting replacements.

Then ask where private configuration should live. Offer a user-selected
directory outside both repositories, for example
`${XDG_CONFIG_HOME:-$HOME/.config}/slurm-workflows/PROFILE`. Do not create or
populate it without the user's choice. Directories should be mode 700 and
configuration files mode 600; avoid shared storage with unsuitable permissions.

Ask only the applicable questions:

- Which account, partition, and QoS are required? Unset is allowed when the user
  intends to use site defaults; do not invent required keys.
- What CPU, memory, walltime, GPU, and array concurrency requests are appropriate?
  Different stages may need different requests.
- How is Python made available on compute nodes? Ask for the existing setup
  convention, without installing or modifying environments.
- Which paths are shared at identical locations on compute nodes? The example
  manifest snapshot and runtime helpers must be readable there.
- Which export and invalid-dependency policies does the user choose? Explain
  site and version uncertainty rather than silently selecting a policy.

Offer to let the user fill private values locally without sharing them in chat.
Generate a placeholder-only setup file if useful. A personal shell wrapper can
pass private settings as quoted `sbatch` arguments to a copied project launcher;
that wrapper stays outside both repositories. Shell configuration is executable
code: source only a file the user owns and trusts. Do not use `eval` to assemble
options. Do not commit a profile merely because it contains no credentials.

Before handoff, list unresolved settings and provide a local preview command.
The example launchers support `SLURM_WORKFLOW_PREVIEW=1`; this prints shell-quoted
commands with symbolic dependency IDs and never calls `sbatch`. It still creates
local directories and a manifest snapshot. Preview output may expose private
paths and arguments, so the user should keep it private. It is not a reusable
execution plan or scheduler validation. A real run takes a fresh snapshot.

Explain the remaining human checks: installed Slurm version, valid account and
partition, resource limits, environment setup, shared paths, and optionally
site-supported `sbatch --test-only`. The agent must not run those commands.
