#!/usr/bin/env bash
set -euo pipefail
[[ $# == 9 ]] || exit 2
source_root=$9
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh" "${@:1:8}"
"$python" prepare.py "source_root=$source_root" "output_dir=$prepared"
for fold in "${folds[@]}"; do
  [[ -f $prepared/$fold/train_ids.txt && -f $prepared/$fold/validation_ids.txt ]] || { echo "Missing prepared inputs: $fold" >&2; exit 1; }
done
