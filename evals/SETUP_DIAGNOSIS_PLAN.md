# Remaining-scope validation

Status: four content trials and four metadata probes completed. Results and
limits are in [SETUP_DIAGNOSIS_RESULTS.md](SETUP_DIAGNOSIS_RESULTS.md). The content
prompts/assertions were already frozen at the pinned case commit; this written
protocol was added before the metadata probes, after the content agents began.

Skill/case source: merged main `1a433d150d5fd5378999e51e452dc0a5ac9a47ad`.
Use the unchanged private-setup and supplied-diagnosis prompts/assertions from
cases.json, once per condition in fresh native agents with fork_turns=none.
Only with-skill sessions receive operational resources. No development history,
assertions, previous responses or other workspace access is supplied/authorized.
Launch order: setup baseline, setup skill, diagnosis skill, diagnosis baseline.

Setup and diagnosis prompts prohibit file creation/modification; collect final
responses and separately labeled self-reported audits through the parent. Save
these as response evidence, not independent complete tool traces. Compare
workspace inventories with supplied inputs. Grade each assertion with direct
response/fixture evidence using the same standard for both conditions. Require
explicit exclusion of both project and skill repositories for private storage.
Keep missing evidence unknown and separate task rows from step measurements.

Native agents share tool/filesystem capabilities. No-cluster-operation remains
unverified because independent traces/enforced isolation are unavailable. No
metrics or exact model identifiers are inferred where the harness does not
expose them. All prose grades are unblinded parent-agent judgments pending
human review. One trial per condition cannot establish general reliability.

## Discovery limitation and metadata probes

This interface cannot inject the skill into its native platform registry or
observe automatic activation. Instead use four fresh metadata-only probes,
each receiving one task and the exact name/description from the pinned skill.
Agents decide whether to consult the skill and give a reason without seeing
its body or performing the task. Expected labels live only in
routing-cases.json, not in the agent inputs. Positive tasks concern dependency
extension and supplied accounting; negatives concern a Python CLI edit and
quoting in a non-Slurm Bash backup script.

Compare selected/null decisions with frozen labels. Record agreement and reasons,
but do not call this an actual-discovery pass or substitute it for a real
platform installation/discovery check. The probe is explicitly prompted to
select, unlike normal implicit discovery, and uses a single-skill catalog.

No operational skill changes, new evaluation framework, real cluster action,
Curriculearn changes or release publication are part of this pass. Preserve
all prior evidence and report remaining release-readiness limits explicitly.
