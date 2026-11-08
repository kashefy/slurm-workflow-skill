#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh" "$@"
index=${SLURM_ARRAY_TASK_ID:?Missing array task ID}
[[ $index =~ ^[0-2]$ ]] || exit 2
fold=${folds[index]}
[[ -f $prepared/$fold/train_ids.txt && -f $prepared/$fold/validation_ids.txt ]] || exit 1
mkdir -p -- "$runs/$fold"
"$python" train.py "train_file=$prepared/$fold/train_ids.txt" "validation_file=$prepared/$fold/validation_ids.txt" "output_dir=$runs/$fold" train_seed=17
[[ -s $runs/$fold/best.ckpt ]] || { echo "Missing or empty checkpoint: $fold" >&2; exit 1; }
