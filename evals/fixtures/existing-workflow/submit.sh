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
printf '%s\n' "${BASH_REMATCH[1]}"
