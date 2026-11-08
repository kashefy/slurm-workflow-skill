#!/usr/bin/env bash
set -euo pipefail
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[[ $# == 1 ]] || fail 'Expected manifest path'
MANIFEST=$1
[[ -f "$MANIFEST" ]] || fail 'Missing manifest'
mapfile -t fields < "$MANIFEST"
[[ ${#fields[@]} == 9 && ${fields[0]} == ml-folds-v1 ]] || fail 'Invalid manifest'
PROJECT_DIR=${fields[1]}
SOURCE_ROOT=${fields[2]}
DATA_DIR=${fields[3]}
OUTPUT_DIR=${fields[4]}
ENV_SETUP=${fields[5]}
for i in 0 1 2; do
  [[ ${fields[i+6]} == "fold-0$i" ]] || fail 'Invalid fold mapping'
done
source "$ENV_SETUP"
cd "$PROJECT_DIR"
