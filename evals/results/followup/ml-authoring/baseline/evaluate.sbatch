#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { printf "Expected manifest path\n" >&2; exit 1; }
source "$(dirname -- "$1")/wrappers/common.sh" "$@"
for fold in "${fields[@]:6:3}"; do
  [[ -f "$OUTPUT_DIR/$fold/best.ckpt" ]] || fail "Missing checkpoint: $fold"
  mkdir -p -- "$OUTPUT_DIR/$fold/evaluation"
  python3 evaluate.py "run_dir=$OUTPUT_DIR/$fold" checkpoint=best "output_dir=$OUTPUT_DIR/$fold/evaluation"
done
