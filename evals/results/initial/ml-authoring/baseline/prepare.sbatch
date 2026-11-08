#!/usr/bin/env bash
set -euo pipefail
# Slurm may spool this script elsewhere: wrapper directory is an explicit argument.
HERE=$1
source "$HERE/common.sh"
load_config "$2"
check_manifest "$3" "$4"
setup_python
"${PYTHON[@]}" prepare.py "source_root=$SOURCE_ROOT" "output_dir=$RUN_ROOT/prepared"
for fold in "${FOLDS[@]}"; do
  [[ -f "$RUN_ROOT/prepared/$fold/train_ids.txt" && -f "$RUN_ROOT/prepared/$fold/validation_ids.txt" ]] || exit 1
done
