Added evaluation submission with `afterok` through the existing entry point.

- CLI, private profile keys, training Python arguments, and numeric training-ID stdout are preserved.
- Evaluation ID goes to stderr; evaluation uses `run_dir=RUN_ROOT checkpoint=best output_dir=RUN_ROOT/evaluation`.
- Partial submission failures exit nonzero and warn that training was already submitted.

Changed `submit.sh`, added `jobs/evaluate.sbatch`, and documented behavior and optional recommendations in `README.md`. Recommendations include evidence, benefits, migration costs, and necessity; none were implemented.

Validation: Bash syntax checks passed. No scheduler commands, private profiles, workloads, network access, or package installation were used. Cluster behavior remains unverified; the human runs cluster commands.
