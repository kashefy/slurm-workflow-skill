#!/usr/bin/env bash
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$HERE/common.sh"
[[ $# == 1 && $1 == /* ]] || { echo 'Usage: bash submit.sh /absolute/private/config.sh' >&2; exit 1; }
CONFIG=$1
load_config "$CONFIG"
for option in "${PREP_OPTIONS[@]}" "${TRAIN_OPTIONS[@]}" "${EVAL_OPTIONS[@]}"; do
  [[ $option != *REPLACE_ME* ]] || { echo 'Configure site options' >&2; exit 1; }
done
# Refuse an existing run directory; inputs/checkpoints must belong to this run.
mkdir -- "$RUN_ROOT"
mkdir -- "$RUN_ROOT/logs"
MANIFEST="$RUN_ROOT/folds.txt"
printf '%s\n' fold-00 fold-01 fold-02 > "$MANIFEST"
chmod 444 -- "$MANIFEST"
DIGEST=$(sha256sum -- "$MANIFEST")
DIGEST=${DIGEST%% *}
printf '%s\n' "$DIGEST" > "$RUN_ROOT/manifest.sha256"
submit() {
  local output
  if ! output=$(sbatch --parsable "$@"); then
    echo 'Submission failed; earlier jobs may remain active. Consult jobs.tsv.' >&2; return 1
  fi
  if [[ ! $output =~ ^([0-9]+)(\;[A-Za-z0-9_.-]+)?$ ]]; then
    printf 'Unrecognized sbatch response: %s; inspect scheduler manually.\n' "$output" >&2
    return 1
  fi
  JOB_ID=${BASH_REMATCH[1]}
}
submit "${PREP_OPTIONS[@]}" --job-name=ml-prepare --output="$RUN_ROOT/logs/prepare-%j.out" "$HERE/prepare.sbatch" "$HERE" "$CONFIG" "$MANIFEST" "$DIGEST"
PREP_ID=$JOB_ID
printf 'prepare\t%s\n' "$PREP_ID" >> "$RUN_ROOT/jobs.tsv"
submit "${TRAIN_OPTIONS[@]}" --array=0-2%2 --dependency="afterok:$PREP_ID" --job-name=ml-train --output="$RUN_ROOT/logs/train-%A_%a.out" "$HERE/train.sbatch" "$HERE" "$CONFIG" "$MANIFEST" "$DIGEST"
TRAIN_ID=$JOB_ID
printf 'train\t%s\n' "$TRAIN_ID" >> "$RUN_ROOT/jobs.tsv"
submit "${EVAL_OPTIONS[@]}" --dependency="afterok:$TRAIN_ID" --job-name=ml-evaluate --output="$RUN_ROOT/logs/evaluate-%j.out" "$HERE/evaluate.sbatch" "$HERE" "$CONFIG" "$MANIFEST" "$DIGEST"
printf 'evaluate\t%s\n' "$JOB_ID" >> "$RUN_ROOT/jobs.tsv"
cat -- "$RUN_ROOT/jobs.tsv"
