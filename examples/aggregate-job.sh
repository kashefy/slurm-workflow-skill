#!/usr/bin/env bash
set -euo pipefail
python3 "$1" verify "$3" "$4"
python3 "$2" aggregate "$3" "$4" "$5"
