# Contributing

When editing this skill, follow this repository's [AGENTS.md](AGENTS.md), run
`python3 scripts/audit.py` before committing, and apply the
[instruction review](SKILL_REVIEW.md) when SKILL.md or its references change.
See [AUDIT.md](AUDIT.md) for when fresh-agent evaluations are required.

## Optional personal instructions for co-development

If you choose to develop this skill alongside another project, copy and adapt
the snippet below into your personal agent instructions or a workspace-level
AGENTS.md outside both repositories. Use a location your agent actually loads;
instruction discovery differs between agent tools. Replace the placeholder
with your local skill checkout path. Merely reading this document does not
activate the snippet.

Do not add it to the target project's committed instructions. Other developers
may use another skill or none, and generated workflows must remain independent
of this skill. This is an optional developer preference, not a project
requirement. No personal or external project instructions are modified here.

```text
For my Slurm-related work, consult the skill at <SLURM_SKILL_CHECKOUT>/SKILL.md.
Use it to prepare portable workflows and diagnose evidence I provide. Do not
connect to a cluster or execute real scheduler commands; I perform submission.
Known local scheduler stubs may be used for explicitly local validation.

When a Slurm change or supplied result reveals a reusable lesson, classify it
as project-specific logic, private cluster configuration, or reusable skill
guidance. Keep project changes in the project and private configuration outside
both repositories. Carry reusable improvements into the separate skill checkout
within the authorized task scope, or record a sanitized follow-up when deferred.

Before editing the skill, read its AGENTS.md and contribution guidance. Follow
its instruction-review and evaluation requirements, and run its local audit.
Keep commits separate by repository. Report which repository changed, checks
performed, outstanding findings, and required human-run cluster validation.
Never copy private configuration or supplied logs into either repository
without explicit authorization, and do not make the project depend on the skill.
```

Choosing this snippet does not authorize unrelated changes, cluster access, or
publishing. Record deferred improvements without private values or raw logs.
