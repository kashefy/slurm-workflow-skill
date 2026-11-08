# Manifest-driven arrays

The demo manifest is UTF-8, one nonempty value per line. Lines are zero-indexed
in order; duplicate values remain distinct tasks. Empty manifests, blank lines,
and CRLF are rejected. The launcher copies the manifest to a private, unique
receipt directory, records its SHA-256, makes the copy read-only, and submits
indices `0..N-1` with a user-selected `%` concurrency limit. Editing an input
manifest creates a new version and hash; never edit a submitted snapshot. The
hash check detects changed bytes, but permissions and hashes do not provide
protection against a malicious writer who can alter both files or arguments.

The snapshot, workload and output directory must be visible at identical
absolute paths on compute nodes. The demo verifies the hash in each stage and
uses the task index to select a value. Its output names contain stable task IDs;
the aggregate validates every expected JSON output against the manifest and
hash before producing a summary. Adapt that validation for the real output
format; mere file existence is insufficient. Use a fresh output directory per
run or arrange explicit run isolation.

Use the site's supported `--output` and `--error` options for logs: for example,
`--output=/chosen/shared/logs/%x-%A_%a.out` and a matching error path. `%A`
and `%a` distinguish array tasks; other stages have different substitutions,
so adapt their paths as needed. Create directories before submission and
confirm substitutions on the target Slurm version. Do not assume a missing log
means a task failed or succeeded.
