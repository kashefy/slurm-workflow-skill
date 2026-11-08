#!/usr/bin/env bash
set -euo pipefail
input=$(python3 "$1" task "$3" "$4" "${SLURM_ARRAY_TASK_ID:?missing array task ID}")
python3 "$2" task "$3" "$4" "$5" "$SLURM_ARRAY_TASK_ID" "$input"
