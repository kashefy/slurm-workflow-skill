#!/usr/bin/env bash
set -euo pipefail
project=$1
source "$2"
exec "$PYTHON" "$project/evaluate.py" "run_dir=$RUN_ROOT" "checkpoint=best" "output_dir=$RUN_ROOT/evaluation"
