#!/usr/bin/env bash
set -euo pipefail
source "$1/common.sh"
load_config "$2"
check_manifest "$3" "$4"
[[ ${SLURM_ARRAY_TASK_ID:-} =~ ^[012]$ ]] || { echo 'Invalid array index' >&2; exit 1; }
fold=${FOLDS[$SLURM_ARRAY_TASK_ID]}
setup_python
mkdir -p -- "$RUN_ROOT/models/$fold"
"${PYTHON[@]}" train.py "train_file=$RUN_ROOT/prepared/$fold/train_ids.txt" "validation_file=$RUN_ROOT/prepared/$fold/validation_ids.txt" "output_dir=$RUN_ROOT/models/$fold" train_seed=17
[[ -f "$RUN_ROOT/models/$fold/best.ckpt" ]]
