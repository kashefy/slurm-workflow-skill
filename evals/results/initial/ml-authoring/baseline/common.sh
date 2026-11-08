#!/usr/bin/env bash
set -euo pipefail
load_config() {
  source "$1"
  for name in PROJECT_DIR SOURCE_ROOT RUN_ROOT; do
    [[ ${!name:-} == /* && ${!name} != *'/ABSOLUTE/'* ]] || {
      printf 'Configure absolute %s in private config\n' "$name" >&2; exit 1;
    }
  done
  ((${#PYTHON[@]})) || { echo 'Configure PYTHON array' >&2; exit 1; }
}
check_manifest() {
  local actual
  actual=$(sha256sum -- "$1")
  actual=${actual%% *}
  [[ $actual == "$2" ]] || { echo 'Manifest checksum mismatch' >&2; exit 1; }
  mapfile -t FOLDS < "$1"
  [[ ${#FOLDS[@]} == 3 && ${FOLDS[0]} == fold-00 && ${FOLDS[1]} == fold-01 && ${FOLDS[2]} == fold-02 ]] || {
    echo 'Invalid fold manifest' >&2; exit 1;
  }
}
setup_python() {
  if [[ -n ${ENV_SETUP:-} ]]; then source "$ENV_SETUP"; fi
  cd -- "$PROJECT_DIR"
}
