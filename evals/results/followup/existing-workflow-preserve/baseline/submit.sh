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
training_id=${BASH_REMATCH[1]}
printf '%s\n' "$training_id"
if ! evaluation_raw=$(sbatch --parsable "${SBATCH_OPTIONS[@]}" \
    --dependency="afterok:$training_id" --output="$RUN_ROOT/logs/evaluate-%j.out" \
    "$base/jobs/evaluate.sbatch" "$base" "$profile"); then
    printf 'Training job %s submitted; evaluation submission failed. Inspect before retrying; do not resubmit training blindly.\n' "$training_id" >&2
    exit 1
fi
if [[ $evaluation_raw =~ ^([0-9]+)(\;[^[:space:];]+)?$ ]]; then
    printf 'Evaluation job %s depends on successful training job %s\n' "${BASH_REMATCH[1]}" "$training_id" >&2
else
    printf 'Training job %s submitted; evaluation submission result unclear. Inspect before retrying.\n' "$training_id" >&2
    exit 1
fi
