#!/usr/bin/env bash
set -euo pipefail

if (( $# < 5 )); then
    echo "Usage: $0 MANIFEST OUTPUT_DIR RECEIPT_DIR CONCURRENCY PYTHON_PROGRAM [SBATCH_OPTIONS...]" >&2
    exit 2
fi
here=$(cd -- "$(dirname -- "$0")" && pwd -P)
# shellcheck source=examples/submit-common.sh
source "$here/submit-common.sh"
manifest=$(absolute_file "$1")
output_dir=$2
receipt_dir=$3
concurrency=$4
program=$(absolute_file "$5")
shift 5
[[ $concurrency =~ ^[1-9][0-9]*$ ]] || { echo "Concurrency must be a positive integer" >&2; exit 2; }
[[ -f $manifest && -f $program ]] || { echo "Manifest or Python program not found" >&2; exit 1; }
mkdir -p -- "$output_dir/logs"
output_dir=$(cd -- "$output_dir" && pwd -P)
new_receipt "$receipt_dir"
cp -- "$manifest" "$receipt/manifest.txt"
chmod a-w "$receipt/manifest.txt"
count=$(python3 "$here/manifest.py" count "$receipt/manifest.txt")
hash=$(python3 "$here/manifest.py" hash "$receipt/manifest.txt")
printf '%s\n' "$hash" > "$receipt/manifest.sha256"

submit_job prepare "$@" "$here/prepare-job.sh" "$here/manifest.py" "$program" "$receipt/manifest.txt" "$hash" "$output_dir"
prepare_id=$job_id
submit_job array "$@" --dependency="afterok:$prepare_id" --array="0-$((count - 1))%$concurrency" \
    --output="$output_dir/logs/%x-%A_%a.out" --error="$output_dir/logs/%x-%A_%a.err" \
    "$here/array-job.sh" "$here/manifest.py" "$program" "$receipt/manifest.txt" "$hash" "$output_dir"
array_id=$job_id
submit_job aggregate "$@" --dependency="afterok:$array_id" \
    "$here/aggregate-job.sh" "$here/manifest.py" "$program" "$receipt/manifest.txt" "$hash" "$output_dir"
