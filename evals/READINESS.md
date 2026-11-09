# Experimental readiness evidence

This is an evidence index, not a release announcement. Operational content at
merged main `1a433d150d5fd5378999e51e452dc0a5ac9a47ad` has been exercised through
the cases below. Each paired case has one recent trial per condition; that is
exploratory evidence, not a reliability estimate.

| Area | Current evidence | Remaining limit |
| --- | --- | --- |
| Instruction coverage | Recorded 13-row review provisionally passes | Unblinded agent review; independent human review pending |
| ML authoring | Spooling, failure IDs, manifests and local contracts checked in FOLLOWUP_RESULTS.md | One paired sample; no real Slurm/ML validation |
| Existing workflow, suggestions welcome | Compatible extension and separate unimplemented advice in FOLLOWUP_RESULTS.md | Inspection chronology/action trace unverified |
| Existing workflow, design preserved | Existing interfaces/log naming preserved and declined migration not repeated | One paired sample; no blocking-defect fixture |
| Private configuration setup | Explicit external storage and local entry in SETUP_DIAGNOSIS_RESULTS.md | Response-only exercise, not a multi-turn setup |
| Supplied-evidence diagnosis | Correct main conclusions, task/step and snapshot distinctions | One incident; actions not independently trace-verified |
| Trigger description | Four metadata selection probes match labels | Proxy only; real native discovery/installation untested |
| Local regression audit | Metadata/links/review freshness, evidence hashes, Bash syntax and seven tests | ShellCheck unavailable locally; inspect CI separately |

Contributor review and evaluation files remain separate from task instructions.
All historical outputs, including failed samples, remain preserved unchanged.

The automated work so far supports a small experimental skill for further
testing; it does not justify a claim of general reliability or verified action
compliance. No release/tag is created in this pass. Before publishing one,
review preserved outputs independently and run positive/negative native
discovery cases on a supported host without modifying target projects.
Cluster acceptance and execution remain human-run checks; no cluster credentials
or Curriculearn changes are needed for the outstanding offline review.

Evidence: [follow-up workflow results](FOLLOWUP_RESULTS.md),
[setup/diagnosis and routing results](SETUP_DIAGNOSIS_RESULTS.md), and
[original results](findings.md).
