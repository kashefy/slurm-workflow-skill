#!/usr/bin/env bash

new_receipt() {
    umask 077
    mkdir -p -- "$1"
    local root
    root=$(cd -- "$1" && pwd -P)
    receipt=$(mktemp -d "$root/slurm-workflow.XXXXXXXX")
    : > "$receipt/accepted-jobs.tsv"
    printf 'Receipt directory: %s\n' "$receipt" >&2
}

submit_job() {
    local label=$1 raw status
    shift
    if [[ ${SLURM_WORKFLOW_PREVIEW:-0} == 1 ]]; then
        printf 'Plan %s:' "$label"
        printf ' %q' sbatch --parsable "$@"
        printf '\n'
        job_id="PLAN_${label}"
        return 0
    fi
    if raw=$(sbatch --parsable "$@"); then
        printf '%s\n' "$raw" > "$receipt/$label.txt"
        printf '%s\t%s\n' "$label" "$raw" >> "$receipt/accepted-jobs.tsv"
        printf 'Accepted %s: %s\n' "$label" "$raw" >&2
    else
        status=$?
        printf 'Submission of %s failed (status %s). Accepted jobs:\n' "$label" "$status" >&2
        cat -- "$receipt/accepted-jobs.tsv" >&2
        return "$status"
    fi
    if [[ ! $raw =~ ^([0-9]+)(\;([^[:space:];]+))?$ ]]; then
        printf 'Unexpected response; job may have been submitted. Inspect %s/%s.txt\n' "$receipt" "$label" >&2
        return 1
    fi
    # Used by the launcher that sources this file.
    # shellcheck disable=SC2034
    job_id=${BASH_REMATCH[1]}
    job_cluster=${BASH_REMATCH[3]}
    if [[ ${chain_cluster_set:-} == yes && $job_cluster != "$chain_cluster" ]]; then
        printf 'Cluster differs from previous submissions; stopping. Inspect receipts.\n' >&2
        return 1
    fi
    chain_cluster=$job_cluster
    chain_cluster_set=yes
}

absolute_file() {
    local dir
    dir=$(cd -- "$(dirname -- "$1")" && pwd -P)
    printf '%s/%s\n' "$dir" "$(basename -- "$1")"
}
