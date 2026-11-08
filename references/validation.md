# Local validation and human handoff

Run only local checks on generated or changed workflows. Reuse relevant project
tests rather than introducing a second testing framework.

1. Run `bash -n "$file"` separately for each shell/batch script. A command such
   as `bash -n first.sh second.sh` checks only first.sh. Run ShellCheck if
   available; explicitly report if it is skipped.
2. Use an explicitly known local fake sbatch. Confirm its resolved path points
   to the test stub; fail if the stub is absent. Never fall back to the real
   command. The stub must record argument boundaries and return known IDs.
   Check single jobs, whole-array dependencies, array range/concurrency, quoted
   arguments and per-task log paths as applicable.
3. For a multi-job launcher, make the stub fail on the second submission. Check it stops before
   a third call and reports the IDs of earlier accepted jobs, with private
   receipts retained. A successful call with an unparseable response may still
   represent an accepted job; preserve the response and do not blindly retry.
4. Exercise changed task mapping and expected-output validation with tiny local
   interface stubs or project tests, not real ML compute or downloads. Include
   a missing/invalid expected output and a changed-manifest check when relevant.
5. Copy each batch script alone to another directory to simulate spooling, then
   run it with the captured arguments and local workload stubs. It must still
   resolve its helpers. Keep helper paths explicit and on configured shared
   storage; test paths with spaces.

The bundled tests/stubs/sbatch can inspire a project-owned test stub, but a
generated workflow must not require this skill's test files at runtime. Missing
fixtures or tools are a reason to report an unverified check, not to execute a
real scheduler command. Local checks do not establish Slurm or site compatibility.

Give the human the remaining checks: valid account/partition/QoS, supported
Slurm options, resource and array limits, shared paths, compute-node environment,
and site-supported scheduler validation such as sbatch --test-only. Label these
as commands the human must run. Include the working directory and necessary
setup without embedding private values. Do not claim a successful local stub
run establishes scheduling, workload correctness or scientific validity.
