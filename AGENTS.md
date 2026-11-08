# Contributor guidance

Keep this skill small, portable, original, and optional. Do not add cluster
access, execution, authentication, synchronization, installation, monitoring,
or automatic retry machinery. Preserve the separation between agent advice and
commands a human chooses to run. Examples must use invented values or
placeholders, never private site configuration or logs.

When modifying scripts, run the local checks in README and exercise failure
paths with the scheduler stub. Do not claim stub tests establish behavior on a
real cluster; identify version- and site-dependent behavior explicitly.
