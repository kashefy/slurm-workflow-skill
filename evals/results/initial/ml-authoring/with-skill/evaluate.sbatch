#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh" "$@"
for fold in "${folds[@]}"; do
  [[ -s $runs/$fold/best.ckpt ]] || { echo "Missing or empty checkpoint: $fold" >&2; exit 1; }
done
for fold in "${folds[@]}"; do
  mkdir -p -- "$evaluations/$fold"
  "$python" evaluate.py "run_dir=$runs/$fold" checkpoint=best "output_dir=$evaluations/$fold"
done
