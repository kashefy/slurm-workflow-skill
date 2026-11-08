#!/usr/bin/env bash
set -euo pipefail
source "$1/common.sh"
load_config "$2"
check_manifest "$3" "$4"
setup_python
for fold in "${FOLDS[@]}"; do
  [[ -f "$RUN_ROOT/models/$fold/best.ckpt" ]] || exit 1
  mkdir -p -- "$RUN_ROOT/evaluation/$fold"
  "${PYTHON[@]}" evaluate.py "run_dir=$RUN_ROOT/models/$fold" checkpoint=best "output_dir=$RUN_ROOT/evaluation/$fold"
done
