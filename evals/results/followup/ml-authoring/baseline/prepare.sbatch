#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { printf "Expected manifest path\n" >&2; exit 1; }
source "$(dirname -- "$1")/wrappers/common.sh" "$@"
python3 prepare.py "source_root=$SOURCE_ROOT" "output_dir=$DATA_DIR"
for fold in "${fields[@]:6:3}"; do
  [[ -f "$DATA_DIR/$fold/train_ids.txt" && -f "$DATA_DIR/$fold/validation_ids.txt" ]] || fail "Missing prepared files: $fold"
done
