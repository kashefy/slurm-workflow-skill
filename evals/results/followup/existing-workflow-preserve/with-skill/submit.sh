#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { echo 'Usage: submit.sh /absolute/private/profile.sh' >&2; exit 2; }
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
profile=$1
source "$profile"
mkdir -p -- "$RUN_ROOT/logs"
raw=$(sbatch --parsable "${SBATCH_OPTIONS[@]}" --output="$RUN_ROOT/logs/train.out" \
    "$base/jobs/train.sbatch" "$base" "$profile")
[[ $raw =~ ^([0-9]+)(\;[^[:space:];]+)?$ ]] || { echo 'Unclear submission; inspect before retrying' >&2; exit 1; }
train_id=${BASH_REMATCH[1]}
printf '%s\n' "$train_id"
if ! eval_raw=$(sbatch --parsable "${SBATCH_OPTIONS[@]}" \
    --dependency="afterok:$train_id" --output="$RUN_ROOT/logs/evaluate.out" \
    "$base/jobs/evaluate.sbatch" "$base" "$profile"); then
    printf 'Evaluation submission failed; training job %s was accepted. Inspect before retrying.\n' "$train_id" >&2
    exit 1
fi
if [[ ! $eval_raw =~ ^([0-9]+)(\;[^[:space:];]+)?$ ]]; then
    printf 'Unclear evaluation submission after training job %s; response: %q. Inspect before retrying.\n' "$train_id" "$eval_raw" >&2
    exit 1
fi
printf 'Evaluation job %s depends on training job %s (afterok).\n' "${BASH_REMATCH[1]}" "$train_id" >&2
