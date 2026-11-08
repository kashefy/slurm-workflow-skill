#!/usr/bin/env bash
set -euo pipefail
stage=$1; project=$2; run=$3; manifest=$4; digest=$5; setup=$6; source_root=$7
[[ $(sha256sum -- "$manifest" | cut -d ' ' -f1) == "$digest" ]] || { echo 'Manifest changed' >&2; exit 1; }
# This is user-owned trusted executable configuration on shared storage.
source "$setup"
cd -- "$project"
mapfile -t folds < "$manifest"
[[ ${#folds[@]} == 3 && ${folds[0]} == fold-00 && ${folds[1]} == fold-01 && ${folds[2]} == fold-02 ]]
case $stage in
prepare)
  python3 prepare.py "source_root=$source_root" "output_dir=$run/prepared"
  for fold in "${folds[@]}"; do
    [[ -s "$run/prepared/$fold/train_ids.txt" && -s "$run/prepared/$fold/validation_ids.txt" ]]
  done
  ;;
train)
  task=${SLURM_ARRAY_TASK_ID:?Missing array index}
  [[ $task =~ ^[012]$ ]] || exit 1
  fold=${folds[$task]}
  mkdir -p -- "$run/trained/$fold"
  python3 train.py "train_file=$run/prepared/$fold/train_ids.txt" "validation_file=$run/prepared/$fold/validation_ids.txt" "output_dir=$run/trained/$fold" 'train_seed=17'
  [[ -s "$run/trained/$fold/best.ckpt" ]]
  ;;
evaluate)
  for fold in "${folds[@]}"; do
    [[ -s "$run/trained/$fold/best.ckpt" ]]
    python3 evaluate.py "run_dir=$run/trained/$fold" 'checkpoint=best' "output_dir=$run/evaluated/$fold"
  done
  ;;
*) exit 2 ;;
esac
