---
name: ruby-gate
description: Run one phase's quality gate and the scope check on the working tree, without dispatching a subagent. Usage — /rubyDev:ruby-gate <phase> [--base <ref>].
user-invocable: true
---

# Ruby Gate

Runs a single phase gate from `<plugin-root>/references/quality-gates.md` against the
current working tree and reports the result. This skill dispatches no subagent and
changes no project file.

## Locating this plugin's files

This skill lives at `<plugin-root>/skills/ruby-gate/SKILL.md`, so the plugin root is two
directories up from this skill's directory. (Standard install locations:
`~/.vibe/plugins/ruby-dev/` user-global, or `<project>/.vibe/plugins/ruby-dev/`
project scope.)

## User Input

The arguments are the text the user typed after `/rubyDev:ruby-gate`.

## Workflow Execution

1. **Parse the arguments.** The first word is `<phase>`: one of `specifier`,
   `implementer`, `cleaner`, `hardener`, `verifier`. `--base <ref>` sets the baseline;
   the default is `HEAD`. If the phase is missing or not one of the five names, print the
   usage line `/rubyDev:ruby-gate <phase> [--base <ref>]` and stop.

2. **Resolve the baseline.** Run `git rev-parse <ref>` to get the baseline hash. With
   `--base <ref>`, take the changed set as `git diff --name-only <ref>` plus the
   untracked files, excluding the tool-artifact directories (`coverage/`, `tmp/`, `log/`,
   `.bundle/`). On a tree that was already dirty relative to `<ref>`, pre-existing
   changes count, so report triggers as candidates for you to confirm. Without
   `--base`, the command has no pre-dispatch snapshot, so a dirty tree would produce
   false triggers: skip the scope check and report
   `not evaluated: no baseline; pass --base <ref>`.

3. **Run the gate.** Read `<plugin-root>/tasks/gate-check.md` and follow it for
   `PHASE` = the phase and `BASE` = the baseline hash.

4. **Run the scope check** (only when `--base` was given; otherwise it was skipped in
   step 2). Apply the four escalation triggers in the "Escalation triggers" section of
   `<plugin-root>/references/quality-gates.md` to the changed set from step 2. With no
   `PATHS` known, report triggers 2 and 3 only, and report trigger 1 and 4 as
   `not evaluated: PATHS unknown`.

5. **Print the result.** Output exactly:

   ```
   GATE: pass | fail | fail (not run)
   PHASE: <phase>
   MEASURED: <command> → <value or exit status>
   NOT-RUN: <tool unavailable entries, or "none">
   FAILING-ROW: <row and threshold missed, or "none">
   ROLLBACK-TARGET: <phase, or "none">
   SCOPE-CHECK: <ok | trigger that fired + diff stat | not evaluated: <reason>>
   ```

## Constraints

- Do NOT spawn any subagent (no `agents.spawn` calls).
- Do NOT edit, create, or delete project files (tool artifacts such as `coverage/` and
  caches excepted), and do not roll back; this skill only reports.
- Do NOT report a pass on any command that did not run.
