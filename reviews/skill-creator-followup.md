# Skill-creator instruction improvements

Reviewed baseline: `6b4d88138ddb23b0fed3296804fb6f349bc30ba0`.
Method: parent-agent review using the published OpenAI skill-creator
[instructions](https://github.com/openai/skills/blob/main/skills/.system/skill-creator/SKILL.md),
read on 2026-11-08. Skill-creator was not installed; its mutable upstream main
was consulted, not a pinned installation. The user approved applying the
proposals while retaining repository development evidence.

Applied changes:

- Explicit authoring/extension/diagnosis trigger description.
- Inspect existing project/context before asking for missing information.
- Name target-project and skill repositories as private-storage exclusions.
- Route each reference by task and name the example location.
- Add a concise local validation reference covering per-file syntax, explicit
  scheduler stubs, submission failures, argument/task mapping, and spooling.
- Require self-contained batch scripts or explicit shared helper paths.
- Explain task/step attribution and snapshot versus live state in diagnosis.
- Add a conditional handoff checklist and clarify accepted-ID failure messages.
- Reduce repeated privacy wording in diagnosis; preserve core boundaries in
  SKILL.md. Preserve the existing developer-preference procedure.
- Clarify operational versus contributor content without deleting audit or
  evaluation material, moving files, or adding a framework.

The recorded instruction review covers the changed text and all six references.
Passing its rows establishes textual coverage only, pending human review. It
does not supersede the original trial findings: preserved outputs remain
unchanged, including the relocation failure and missing-ID messages.

Behavioral verification remains pending as a separate step: repeat affected
authoring/setup/diagnosis pairs, run the two existing-workflow pairs, and test
positive/negative automatic discovery for the changed description. This change
applies approved instruction improvements and local validation only; no new
agent-performance claim is made before those trials. No real cluster validation
has occurred. Local audit outcomes are recorded in the commit/handoff; missing
ShellCheck must remain visible rather than being counted as a pass.

Local verification for this change: `python3 scripts/audit.py
--require-clean-review` passed the recorded 13-row instruction review, reference
and evidence-integrity checks, maintained Bash syntax checks, and seven workflow
unit tests. ShellCheck was unavailable and skipped locally; CI requires it.
No fresh-agent trials or live scheduler checks were run for this revision.
