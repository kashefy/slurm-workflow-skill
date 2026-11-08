#!/usr/bin/env bash
set -euo pipefail

if (( $# < 2 )); then
    echo "Usage: $0 PYTHON_PROGRAM RECEIPT_DIR [SBATCH_OPTIONS...]" >&2
    exit 2
fi
here=$(cd -- "$(dirname -- "$0")" && pwd -P)
# shellcheck source=examples/submit-common.sh
source "$here/submit-common.sh"
program=$(absolute_file "$1")
[[ -f $program ]] || { echo "Python program not found: $program" >&2; exit 1; }
receipt_dir=$2
shift 2
new_receipt "$receipt_dir"
submit_job single "$@" "$here/single-job.sh" "$program"
