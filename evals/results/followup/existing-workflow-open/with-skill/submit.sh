#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { echo 'Usage: submit.sh /absolute/private/profile.sh' >&2; exit 2; }
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
profile=$1
source "$profile"
mkdir -p -- "$RUN_ROOT/logs"
raw=$(sbatch --parsable "${SBATCH_OPTIONS[@]}" --output="$RUN_ROOT/logs/train.out" \
    "$base/jobs/train.sbatch" "$base" "$profile")
[[ $raw =~ ^([0-9]+)(\;[^[:space:];]+)?$ ]] || { printf 'Unclear training submission response: %q; inspect before retrying\n' "$raw" >&2; exit 1; }
train_id=${BASH_REMATCH[1]}
train_cluster=${BASH_REMATCH[2]:-}
printf '%s\n' "$train_id"
if ! eval_raw=$(sbatch --parsable "${SBATCH_OPTIONS[@]}" \
    --dependency="afterok:$train_id" --output="$RUN_ROOT/logs/evaluate.out" \
    "$base/jobs/evaluate.sbatch" "$base" "$profile"); then
    printf 'Evaluation submission failed; training job %s was accepted. Inspect before retrying.\n' "$train_id" >&2
    exit 1
fi
if [[ ! $eval_raw =~ ^([0-9]+)(\;[^[:space:];]+)?$ ]]; then
    printf 'Unclear evaluation submission response: %q; training job %s was accepted. Inspect before retrying.\n' "$eval_raw" "$train_id" >&2
    exit 1
fi
eval_id=${BASH_REMATCH[1]}
eval_cluster=${BASH_REMATCH[2]:-}
printf 'Evaluation job %s submitted after successful training job %s.\n' "$eval_id" "$train_id" >&2
if [[ $eval_cluster != "$train_cluster" ]]; then
    printf 'Submission cluster responses differ (%q, %q); inspect accepted training %s and evaluation %s before further action.\n' "$train_cluster" "$eval_cluster" "$train_id" "$eval_id" >&2
    exit 1
fi
