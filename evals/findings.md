# Initial status

The three behavioral cases and rubric are prepared. No paired agent results
have yet been established. A fresh-session CLI probe on 2026-11-08 using
codex-cli 0.166.0-alpha.1 failed before agent execution:
`failed to initialize in-process app-server client: Read-only file system`.
The invocation used `codex exec --ephemeral --skip-git-repo-check --sandbox
read-only --json` in a disposable diagnosis fixture directory. This is an
evaluation infrastructure failure, not a skill failure. No model response or
paired comparison was produced. Raw diagnostic files remain local under work/.

Existing unittest checks exercise bundled scripts,
not agent discovery, questioning, or diagnosis. Do not report them as skill lift.

Next: run isolated baseline/with-skill sessions, review traces and artifacts,
and report per-case assertions. Resolve infrastructure failures separately from
skill failures. Record exact model and skill revision with every result.
