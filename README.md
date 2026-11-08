# Slurm workflow skill

Experimental, optional agent guidance for preparing portable Slurm scripts and
diagnosing evidence supplied by a user. It does not connect to a cluster or run
Slurm commands. Scripts produced with its help are ordinary project files and
do not require the skill at runtime.

Install by copying this directory (or linking it, if your agent supports links)
into your agent's skills directory, following that agent's installation
instructions. Ask the agent to use `SKILL.md` for a Slurm workflow or diagnosis.
The agent must not submit or inspect jobs itself.

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

Local checks (no scheduler required):

```bash
python3 -m unittest discover -s tests -v
for f in examples/*.sh tests/stubs/sbatch; do bash -n "$f"; done
shellcheck examples/*.sh tests/stubs/sbatch # if installed
```

These are local stub tests, not evidence of compatibility with any cluster.
Actual submission, scheduling, filesystem access, accounting, and output
correctness require human-run validation on the target site.
