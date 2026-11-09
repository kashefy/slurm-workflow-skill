# Minimal digits/SVM project demonstration

This is a real project setup exercise, not a paired benchmark or cluster run.
Demo source: [slurm-ml-demo at b6c3897](https://github.com/kashefy/slurm-ml-demo/tree/b6c389703934868bfd588ed0da7b545982ae777e).
Skill used: `fbed1f053129e4f1c081bf9917bbf358e4dad14e`.

## Task and sequence

The user requested a minimal example using bundled sklearn digits, three
stratified folds and a fixed scaled RBF SVM, with an off-the-shelf container.
The project began with only a README. No Curriculearn source or data was used.

Three read-only planning agents assessed ML contracts, Slurm/container setup,
and the image candidate. The parent froze interfaces in PLAN.md. An ML agent
implemented preparation, explicit-index training and aggregation; a separate
test agent authored CLI tests. Only after those interfaces existed did the
Slurm agent apply SKILL.md and its setup/dependencies/arrays/validation
references. A final read-only agent reviewed integration and found no blocking
issue. Agent reports are self-reports, not independently captured full traces.

The resulting layer has three thin shell files: a container runner that owns
fold mapping, one batch script receiving an explicit runner path, and one
human-run submission launcher. The launcher chains preparation → three-fold
array → aggregation; no Python training code accepts a fold or Slurm argument.
Private runtime/image/site settings remain external; all runtime code is
independent of this skill checkout. Contributor instructions do not mandate a
skill. The demo keeps its concise task checklist and verification state in
PLAN.md and README rather than adding an evaluation framework.

## Measurements and results

| Claim | Measurement | Result / limit |
| --- | --- | --- |
| ML workflow works on host | Run all three actual training folds and aggregate; CLI tests verify split coverage, reproducibility, hashes, counts and summary | Four ML tests pass; mean accuracy 0.9833055092, population std 0.0081785968, NumPy 2.3.5/sklearn 1.8.0 |
| Training is fold-agnostic | Inspect explicit CLI and test arbitrary index filenames/paths with spaces | No --fold or scheduler variable in training interface |
| Slurm wiring is correct locally | Known fake sbatch records arguments; assert array 0-2 and afterok links, accepted IDs, partial-failure stop, malformed-output handling and preview | Five scheduler/runtime-mock test cases pass; no actual scheduling |
| Batch helpers survive spooling | Copy job.sbatch elsewhere and execute with captured arguments and fake runtime | All stages and three task IDs dispatch correctly; no real container executed |
| Source is mounted read-only | Inspect captured fake-runtime bind arguments | /project:ro and /run:rw present; runtime/site defaults are not a filesystem-isolation guarantee |
| Off-the-shelf image is pinned | Docker registry manifest inspection resolves the dated scipy-notebook tag's amd64 digest | Digest verified; imports and runtime package versions not verified |
| Container execution works | Attempt OCI pull before import/workload tests | Pull failed extracting a layer: no space left on device. Container execution and SIF conversion remain unverified; this is infrastructure evidence, not a skill failure |

The parent ran `python3 -m unittest discover -s tests -v`: all nine tests
passed. Per-file Bash syntax is included in those checks. ShellCheck was
unavailable. The image is about 1.21 GiB compressed; no image, dataset or generated
run artifact is committed. No cluster was contacted and no real job submitted.

## Findings and next checks

- The skill could be used at the intended stage without introducing a runtime
  dependency or replacing the established Python interfaces.
- Tests exercise the earlier failure modes (spooling and accepted-ID reporting)
  in a concrete ML project, while the small workload remains easy to run locally.
- Do not claim the skill caused these successes: there is no no-skill control,
  and the parent coordinated interfaces and reviewed work.
- Container size/staging is the main outstanding practical issue. The user
  must verify the image/SIF on a capable machine, fill private settings and run
  manual container stages before choosing to submit on the cluster.
- These findings do not justify new universal rules about fold-aware Python
  APIs: the explicit-index boundary is this project's design choice.

No operational skill instructions changed for this demonstration. Preserve this
record alongside earlier evaluations; any later container/cluster evidence
should name the actual source/image revisions and distinguish it from mocks.
