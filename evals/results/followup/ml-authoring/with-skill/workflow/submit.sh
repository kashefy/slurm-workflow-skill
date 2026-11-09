#!/usr/bin/env bash
set -euo pipefail
umask 077
# Supply an absolute, trusted, user-owned profile outside both repositories.
profile=${1:?Usage: submit.sh /absolute/private/profile.sh}
[[ $profile == /* && -f $profile ]] || exit 2
source "$profile"
: "${PROJECT:?}" "${RUN_PARENT:?}" "${RECEIPT_PARENT:?}" "${SOURCE_ROOT:?}" "${ENV_SETUP:?}"
for path in "$PROJECT" "$RUN_PARENT" "$RECEIPT_PARENT" "$SOURCE_ROOT" "$ENV_SETUP"; do
  [[ $path == /* ]] || { echo 'All configured paths must be absolute' >&2; exit 2; }
done
# Profile defines Bash arrays; options differ by stage. No eval is used.
declare -p PREP_OPTIONS TRAIN_OPTIONS EVAL_OPTIONS >/dev/null
for option in "${PREP_OPTIONS[@]}" "${TRAIN_OPTIONS[@]}" "${EVAL_OPTIONS[@]}"; do
  case $option in --array*|--dependency*|--parsable*|--clusters*|-M) echo 'Conflicting scheduler option' >&2; exit 2;; esac
done
mkdir -p -- "$RUN_PARENT" "$RECEIPT_PARENT"
run=$(mktemp -d "$RUN_PARENT/run.XXXXXXXX")
receipt=$(mktemp -d "$RECEIPT_PARENT/receipt.XXXXXXXX")
mkdir -- "$run/logs"
cp -- "$PROJECT/workflow/folds.txt" "$receipt/folds.txt"
chmod 400 "$receipt/folds.txt"
digest=$(sha256sum -- "$receipt/folds.txt" | cut -d ' ' -f1)
printf '%s\n' "$digest" > "$receipt/manifest.sha256"
accepted=(); cluster_seen=''; cluster_set=0
trap 'rc=$?; if ((rc)); then printf "Stopped; accepted: %s\nReceipts: %s\nDo not retry blindly.\n" "${accepted[*]:-none}" "$receipt" >&2; fi' EXIT
submit() {
  local stage=$1; shift
  local raw id cluster
  if [[ ${SLURM_WORKFLOW_PREVIEW:-0} == 1 ]]; then
    printf '%q ' sbatch --parsable "$@"; printf '\n'
    job_id=12345; return
  fi
  if sbatch --parsable "$@" > "$receipt/$stage.stdout" 2> "$receipt/$stage.stderr"; then
    raw=$(cat -- "$receipt/$stage.stdout")
  else
    echo "Submission failed: $stage" >&2; return 1
  fi
  [[ $raw =~ ^([0-9]+)(\;([a-zA-Z0-9_.-]+))?$ ]] || { echo "Malformed response for $stage; inspect receipts before any retry" >&2; return 1; }
  id=${BASH_REMATCH[1]}; cluster=${BASH_REMATCH[3]:-}
  accepted+=("$stage=$raw")
  if ((cluster_set)) && [[ $cluster != "$cluster_seen" ]]; then
    echo 'Cluster mismatch; submission may already be accepted' >&2; return 1
  fi
  cluster_seen=$cluster; cluster_set=1; job_id=$id
}
args=("$PROJECT/workflow/stage.sh")
common=("$PROJECT" "$run" "$receipt/folds.txt" "$digest" "$ENV_SETUP" "$SOURCE_ROOT")
submit prepare "${PREP_OPTIONS[@]}" "--output=$run/logs/prepare-%j.out" "--error=$run/logs/prepare-%j.err" "${args[@]}" prepare "${common[@]}"
prep_id=$job_id
submit train "${TRAIN_OPTIONS[@]}" "--dependency=afterok:$prep_id" '--array=0-2%2' "--output=$run/logs/train-%A_%a.out" "--error=$run/logs/train-%A_%a.err" "${args[@]}" train "${common[@]}"
train_id=$job_id
submit evaluate "${EVAL_OPTIONS[@]}" "--dependency=afterok:$train_id" "--output=$run/logs/evaluate-%j.out" "--error=$run/logs/evaluate-%j.err" "${args[@]}" evaluate "${common[@]}"
printf 'Run: %s\nReceipts: %s\nAccepted: %s\n' "$run" "$receipt" "${accepted[*]:-preview only}"
