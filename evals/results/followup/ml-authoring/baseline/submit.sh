#!/usr/bin/env bash
set -euo pipefail
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ $# == 1 && $1 == /* ]] || fail 'Usage: bash submit.sh /absolute/private/site.sh'
source "$1"
for name in PROJECT_DIR SOURCE_ROOT RUN_ROOT ENV_SETUP PARTITION ACCOUNT PREP_TIME TRAIN_TIME EVAL_TIME PREP_CPUS TRAIN_CPUS EVAL_CPUS PREP_MEMORY TRAIN_MEMORY EVAL_MEMORY; do
  value=${!name:-}
  [[ -n $value && $value != *CHANGE_ME* && $value != *$'\n'* && $value != *$'\r'* ]] || fail "Configure $name (single line)"
done
for name in PROJECT_DIR SOURCE_ROOT RUN_ROOT ENV_SETUP; do
  [[ ${!name} == /* ]] || fail "$name must be absolute"
done
[[ -d $PROJECT_DIR && -d $SOURCE_ROOT && -r $ENV_SETUP ]] || fail 'Missing project, source, or environment setup'
for file in prepare.py train.py evaluate.py; do
  [[ -f "$PROJECT_DIR/$file" ]] || fail "Missing existing program: $file"
done
mkdir -p -- "$RUN_ROOT"
run=$(mktemp -d "$RUN_ROOT/run.XXXXXXXX")
mkdir -- "$run/wrappers" "$run/logs" "$run/data" "$run/models"
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cp -- "$here/common.sh" "$here/prepare.sbatch" "$here/train.sbatch" "$here/evaluate.sbatch" "$run/wrappers/"
printf '%s\n' ml-folds-v1 "$PROJECT_DIR" "$SOURCE_ROOT" "$run/data" "$run/models" "$ENV_SETUP" fold-00 fold-01 fold-02 > "$run/manifest.txt"
chmod 444 "$run/manifest.txt" "$run/wrappers/"*
# Slurm expands % sequences in log filenames, so disallow them in this path.
[[ $run != *%* ]] || fail 'RUN_ROOT cannot contain %'
printf 'Run directory: %s\n' "$run"
capture() {
  local label=$1 raw id
  shift
  if ! raw=$(sbatch --parsable "$@"); then
    fail "$label submission failed; inspect $run/job-ids.txt for accepted jobs"
  fi
  # --parsable may return jobid;cluster on federated installations.
  [[ $raw =~ ^([0-9]+)(\;[A-Za-z0-9_.-]+)?$ ]] || fail "Unexpected sbatch output for $label: $raw; inspect scheduler manually"
  id=${BASH_REMATCH[1]}
  printf '%s=%s\n' "$label" "$raw" >> "$run/job-ids.txt"
  printf '%s' "$id"
}
base=(--partition="$PARTITION" --account="$ACCOUNT" --chdir="$PROJECT_DIR")
prep=$(capture preparation "${base[@]}" --job-name=ml-prepare --time="$PREP_TIME" --cpus-per-task="$PREP_CPUS" --mem="$PREP_MEMORY" "${PREP_EXTRA[@]}" --output="$run/logs/prep-%j.out" "$run/wrappers/prepare.sbatch" "$run/manifest.txt")
train=$(capture training "${base[@]}" --job-name=ml-train --time="$TRAIN_TIME" --cpus-per-task="$TRAIN_CPUS" --mem="$TRAIN_MEMORY" "${TRAIN_EXTRA[@]}" --dependency="afterok:$prep" --array=0-2%2 --output="$run/logs/train-%A_%a.out" "$run/wrappers/train.sbatch" "$run/manifest.txt")
evaluation=$(capture evaluation "${base[@]}" --job-name=ml-evaluate --time="$EVAL_TIME" --cpus-per-task="$EVAL_CPUS" --mem="$EVAL_MEMORY" "${EVAL_EXTRA[@]}" --dependency="afterok:$train" --output="$run/logs/eval-%j.out" "$run/wrappers/evaluate.sbatch" "$run/manifest.txt")
printf 'Accepted preparation=%s training=%s evaluation=%s\n' "$prep" "$train" "$evaluation"
