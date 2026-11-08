#!/usr/bin/env bash
set -euo pipefail
[[ $# == 8 ]] || { echo 'Expected eight runtime arguments' >&2; exit 2; }
project=$1 manifest=$2 expected_hash=$3 prepared=$4 runs=$5 evaluations=$6 setup=$7 python=$8
actual=$(sha256sum -- "$manifest"); actual=${actual%% *}
[[ $actual == "$expected_hash" ]] || { echo 'Manifest hash mismatch' >&2; exit 2; }
mapfile -t folds < "$manifest"
[[ ${#folds[@]} == 3 && ${folds[0]} == fold-00 && ${folds[1]} == fold-01 && ${folds[2]} == fold-02 ]] || { echo 'Invalid fold manifest' >&2; exit 2; }
source "$setup"
cd -- "$project"
