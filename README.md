# Slurm workflow skill

Experimental, optional agent guidance for preparing portable Slurm scripts and
diagnosing evidence supplied by a user. It does not connect to a cluster or run
Slurm commands. Scripts produced with its help are ordinary project files and
do not require the skill at runtime.

Install by copying this directory (or linking it, if your agent supports links)
into your agent's skills directory, following that agent's installation
instructions. Ask the agent to use `SKILL.md` for a Slurm workflow or diagnosis.
The agent must not submit or inspect jobs itself.

Operational task guidance lives in SKILL.md, references/ and examples/.
Contributor instructions, audits, reviews and evaluations remain in this
repository as development evidence; they are not required reading when using
the skill on a project.

For existing workflows, the skill inspects current entry points and conventions
before editing. It separates optional recommendations from requested changes
and respects decisions to retain the current design. See
[existing-workflow guidance](references/existing-workflows.md).

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidance and an optional
personal-instructions snippet for co-developing the skill alongside a project.

`examples/` contains a small, runnable starting point. Copy and adapt the scripts
and Python workload into your project; the manifest helper is a runtime
dependency and must accompany them. For the demo, create a UTF-8 manifest with
one nonempty input value per line, then a human can run, from a shared
filesystem accessible to compute nodes:

```bash
mkdir -p /chosen/shared/output /chosen/private/receipts
./examples/submit-single.sh ./examples/workflow.py /chosen/private/receipts
./examples/submit-chain.sh ./inputs.txt /chosen/shared/output \
  /chosen/private/receipts 4 ./examples/workflow.py
```

Both launchers accept additional `sbatch` options at the end, for example
`--time=00:10:00`, selected by the user for their site. The receipt directory
must be outside both repositories, private, and on storage shared with compute
nodes for the chain. The output directory must also be shared. The demo treats
each manifest line as a value, not as a file to read. Replace its processing
and validation with your application's logic. See the references before use.

Start with [guided private setup](references/setup.md). No cluster profile is
required to try the examples locally. To preview a chain without calling Slurm,
prefix its command with `SLURM_WORKFLOW_PREVIEW=1`. Preview prints potentially
private paths and arguments and creates local directories and a snapshot; it
does not validate scheduler compatibility. Dependency IDs are symbolic.

The launchers keep an `accepted-jobs.tsv` receipt containing stage names and
raw scheduler responses. A submission failure prints that journal, not input
manifest contents. A malformed response still requires human investigation.

Local checks (no scheduler required):

Run the development audit before committing:

```bash
python3 scripts/audit.py
```

CI also runs this audit. See [AUDIT.md](AUDIT.md) for review questions and when
fresh-agent evaluations are required. Individual checks remain available:

```bash
python3 -m unittest discover -s tests -v
for f in examples/*.sh tests/stubs/sbatch; do bash -n "$f"; done
shellcheck examples/*.sh tests/stubs/sbatch # if installed
```

These are local stub tests, not evidence of compatibility with any cluster.
Actual submission, scheduling, filesystem access, accounting, and output
correctness require human-run validation on the target site.

Agent behavior is evaluated separately: see [behavioral evaluations](evals/README.md)
for three authoring/setup/diagnosis cases, paired baseline instructions, and
grading criteria. [Recorded findings](evals/findings.md) distinguish planned
trials from completed results.
