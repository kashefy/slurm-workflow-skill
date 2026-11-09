#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { printf "Expected manifest path\n" >&2; exit 1; }
source "$(dirname -- "$1")/wrappers/common.sh" "$@"
case ${SLURM_ARRAY_TASK_ID:-} in 0|1|2) ;; *) fail 'Expected array task ID 0, 1, or 2';; esac
fold=${fields[SLURM_ARRAY_TASK_ID+6]}
[[ -f "$DATA_DIR/$fold/train_ids.txt" && -f "$DATA_DIR/$fold/validation_ids.txt" ]] || fail "Missing prepared files: $fold"
mkdir -p -- "$OUTPUT_DIR/$fold"
python3 train.py "train_file=$DATA_DIR/$fold/train_ids.txt" "validation_file=$DATA_DIR/$fold/validation_ids.txt" "output_dir=$OUTPUT_DIR/$fold" train_seed=17
[[ -f "$OUTPUT_DIR/$fold/best.ckpt" ]] || fail "Missing checkpoint: $fold"
