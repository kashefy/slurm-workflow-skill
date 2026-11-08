# Submission and dependencies

The human runs `sbatch`; the agent never does. The examples capture
`sbatch --parsable` as either `jobid` or `jobid;cluster`, save the raw response
after each successful submission, and use only the numeric ID in dependency
expressions. Failed submissions stop the chain and report previously accepted
responses. A successful command with malformed output may still have submitted
a job; inspect its receipt rather than retrying blindly. Receipts may contain
private information. Store them outside both repositories with restricted
access, and retain them according to your own policy.

The chain uses `afterok` for preparation → whole array → aggregation. A
failed predecessor can leave dependents pending with a failed dependency, even
if the predecessor is later requeued and succeeds. A user must explicitly
choose whether to leave, cancel, or replace such jobs; do not do so
automatically. `--kill-on-invalid-dep` and site defaults can change behavior.
Confirm support and semantics in the target Slurm version and site
configuration; the templates do not enable that option.

The launcher passes the same user-supplied sbatch options to all stages; split
or adapt it if stages need different resources. Do not supply conflicting
`--array`, `--dependency`, or `--parsable` options. All stages must be submitted
to the same cluster: a different returned cluster stops further submissions,
but cannot undo a job already accepted. Federated routing and dependencies
must be checked by the human against their Slurm version and site.

Do not expect variables to expand in `#SBATCH` lines: Slurm reads directives,
not shell expansions. Pass dynamic values as sbatch arguments instead.
Examples intentionally do not set `--export`. Slurm's default and explicit
`--export=ALL`, `NONE`, or selected variables have different reproducibility,
privacy and site implications. In particular, `NONE` may trigger environment
loading, and restrictive exports can affect later `srun` steps; consult the
target version's `sbatch` and `srun` manuals (including `SLURM_EXPORT_ENV`)
and choose explicitly. Ensure Python and required dependencies are available
on compute nodes without putting credentials in arguments or scripts.
