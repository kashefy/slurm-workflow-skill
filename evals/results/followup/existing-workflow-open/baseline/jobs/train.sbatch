#!/usr/bin/env bash
set -euo pipefail
project=$1
source "$2"
exec "$PYTHON" "$project/train.py" "output_dir=$RUN_ROOT"
