# Human handoff

No workload implementations are supplied. Keep these wrappers together in a
shared project directory. They need Bash, Python supplied by your environment,
and standard Linux tools (realpath, sha256sum, cmp, mktemp). All paths must be
identical and accessible on submission and compute nodes. No internet is needed.

1. Choose a private shared directory outside the workload and wrapper repositories.
   Create it with mode 700. Copy profile.example.sh there with mode 600 and edit it.
   Create your own trusted environment.sh there (mode 600) containing your existing
   module/virtual-environment setup. Both are executable shell configuration;
   source only files you own and trust. No credentials are required here.
2. Fill PROJECT (containing the existing prepare.py, train.py, evaluate.py),
   SOURCE_ROOT, OUTPUT_ROOT, RECEIPT_ROOT, ENV_SETUP, absolute PYTHON executable,
   and stage-specific resource arrays. Choose account, partition and QoS, or
   deliberately use site defaults. Configure CPU, memory, walltime and GPU requests
   per stage. Set SITE_CONFIGURED=yes only after making these choices.
3. Choose EXPORT_POLICY explicitly. ALL inherits submission variables and can
   expose unrelated configuration; a selected variable list is more controlled.
   NONE changes environment initialization and may trigger site environment
   loading. Check the installed Slurm version and site rules. Environment setup
   must work under the selected policy. No export policy is chosen by default.
4. Confirm receipt-directory permissions and visibility; parents must be private
   and appropriate for shared storage. The launcher creates private receipts and
   a fresh output directory on each invocation. Runtime paths and arguments can
   be visible to scheduler users according to site policy.

Local syntax validation (does not run Python or Slurm):

```bash
bash -n common.sh launch.sh prepare.sbatch train.sbatch evaluate.sbatch profile.example.sh
```

After replacing the private profile placeholders, the human can preview locally:

```bash
SLURM_WORKFLOW_PREVIEW=1 bash launch.sh '/absolute/private/profile.sh'
```

Preview creates fresh output and receipt directories and prints quoted commands
with symbolic dependency IDs. Keep its output private. It does not contact Slurm
or validate scheduler acceptance. A real invocation creates a new snapshot:

```bash
bash launch.sh '/absolute/private/profile.sh'
```

Only the human runs the last command on the submission host. Before doing so,
check installed Slurm options, account/partition/QoS validity, resource limits,
shared paths, permissions, environment setup, and federation routing. If supported,
the human may use site-approved sbatch --test-only checks on individual commands.
Do not pass reserved dependency, array, export, cluster or parsable options through
resource arrays; avoid conflicting output and error options too.

Each successful submission saves its raw response before parsing numeric job IDs
or jobid;cluster. Errors stop subsequent submissions. A malformed response or
cluster mismatch may still represent an accepted job: inspect private receipts
and scheduler evidence before deciding what to do. Never retry blindly.

The train job is an array with three tasks and concurrency two. Evaluation uses
an afterok dependency on the entire array and starts a new Python process for
each fold. It first verifies all checkpoint files are present and nonempty.
This is structural validation only: checkpoint semantics and evaluation artifacts
are unspecified by the interface and cannot be validated here. Preparation checks
that each expected IDs file exists; empty splits are not prohibited by the contract.

The manifest has exact fixed fold names, is copied into a unique receipt directory,
made read-only and hashed, and is verified by every stage. Do not edit a submitted
snapshot. Read-only modes and a hash detect accidental edits, not malicious users
who can alter both files and commands. Wrapper code, environment setup and Python
implementations must remain stable while jobs are pending or running.

Failed predecessors can leave dependent jobs pending. Site invalid-dependency
policies vary; this launcher does not set --kill-on-invalid-dep. The human must
choose any cancellation, replacement or recovery. Missing logs or accounting
rows alone do not prove a job succeeded or failed. No scheduler, stub submission,
or workload execution was performed during authoring; only Bash syntax was checked.
