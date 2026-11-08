#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ $# == 1 ]] || { echo 'Usage: launch.sh /absolute/private/profile.sh' >&2; exit 2; }
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$1"
for name in PROJECT SOURCE_ROOT OUTPUT_ROOT RECEIPT_ROOT ENV_SETUP PYTHON EXPORT_POLICY; do
  value=${!name:?Missing configuration}
  [[ $value != *CHOOSE* ]] || { echo "Configure $name" >&2; exit 2; }
done
[[ ${SITE_CONFIGURED:-no} == yes ]] || { echo 'Complete site configuration first' >&2; exit 2; }
project=$(realpath -e -- "$PROJECT")
source_root=$(realpath -e -- "$SOURCE_ROOT")
setup=$(realpath -e -- "$ENV_SETUP")
profile=$(realpath -e -- "$1")
for private_file in "$profile" "$setup"; do
  case "$private_file/" in "$project/"*|"$base/"*) echo "Private configuration must be outside repositories" >&2; exit 2;; esac
done
[[ $PYTHON == /* && -f $setup ]] || exit 2
mkdir -p -- "$OUTPUT_ROOT" "$RECEIPT_ROOT"
receipts=$(realpath -e -- "$RECEIPT_ROOT")
case "$receipts/" in "$project/"*|"$base/"*) echo 'Receipts must be outside repositories' >&2; exit 2;; esac
for option in "${COMMON_OPTIONS[@]}" "${PREP_OPTIONS[@]}" "${TRAIN_OPTIONS[@]}" "${EVAL_OPTIONS[@]}"; do
  case "$option" in --array*|--dependency*|--parsable*|--export*|--clusters*|-M*|-a*|-d*) echo "Reserved option: $option" >&2; exit 2;; esac
done
receipt=$(mktemp -d "$receipts/run.XXXXXXXX")
chmod 700 -- "$receipt"
out=$(mktemp -d "$(realpath -e -- "$OUTPUT_ROOT")/run.XXXXXXXX")
mkdir -- "$out/prepared" "$out/training" "$out/evaluation" "$receipt/logs"
cp -- "$base/folds.txt" "$receipt/manifest.txt"
# Strict bytes, including the final newline, make task mapping unambiguous.
printf 'fold-00\nfold-01\nfold-02\n' | cmp -s - "$receipt/manifest.txt" || exit 2
hash=$(sha256sum -- "$receipt/manifest.txt"); hash=${hash%% *}
printf '%s\n' "$hash" > "$receipt/manifest.sha256"
chmod 400 -- "$receipt/manifest.txt" "$receipt/manifest.sha256"
args=("$project" "$receipt/manifest.txt" "$hash" "$out/prepared" "$out/training" "$out/evaluation" "$setup" "$PYTHON")
printf 'Receipt: %s\nOutputs: %s\n' "$receipt" "$out"
cluster_seen=unset
submit() {
  local stage=$1 raw id cluster
  shift
  if [[ ${SLURM_WORKFLOW_PREVIEW:-0} == 1 ]]; then
    printf '%q ' sbatch --parsable "--export=$EXPORT_POLICY" "${COMMON_OPTIONS[@]}" "$@"
    printf '\n'
    JOB_ID="PREVIEW_${stage}"
    return
  fi
  if ! raw=$(sbatch --parsable "--export=$EXPORT_POLICY" "${COMMON_OPTIONS[@]}" "$@" 2>"$receipt/$stage.stderr"); then
    printf '%s\n' "$raw" > "$receipt/$stage.failed-response"
    echo "Submission failed; inspect $receipt for accepted jobs. Do not retry blindly." >&2
    exit 1
  fi
  printf '%s\n' "$raw" > "$receipt/$stage.response"
  if [[ ! $raw =~ ^([0-9]+)(\;([A-Za-z0-9_.-]+))?$ ]]; then
    echo "Malformed response; a job may exist. Inspect $receipt before any retry." >&2; exit 1
  fi
  id=${BASH_REMATCH[1]} cluster=${BASH_REMATCH[3]:-local}
  if [[ $cluster_seen != unset && $cluster != "$cluster_seen" ]]; then
    echo "Cluster changed; job may already exist. Inspect $receipt." >&2; exit 1
  fi
  cluster_seen=$cluster
  JOB_ID=$id
}
submit prepare "${PREP_OPTIONS[@]}" --job-name=ml-prepare "--output=$receipt/logs/%x-%j.out" "--error=$receipt/logs/%x-%j.err" "$base/prepare.sbatch" "${args[@]}" "$source_root"
prep_id=$JOB_ID
submit train "${TRAIN_OPTIONS[@]}" --job-name=ml-train --array=0-2%2 "--dependency=afterok:$prep_id" "--output=$receipt/logs/%x-%A_%a.out" "--error=$receipt/logs/%x-%A_%a.err" "$base/train.sbatch" "${args[@]}"
train_id=$JOB_ID
submit evaluate "${EVAL_OPTIONS[@]}" --job-name=ml-evaluate "--dependency=afterok:$train_id" "--output=$receipt/logs/%x-%j.out" "--error=$receipt/logs/%x-%j.err" "$base/evaluate.sbatch" "${args[@]}"
printf 'Final job: %s\n' "$JOB_ID"
