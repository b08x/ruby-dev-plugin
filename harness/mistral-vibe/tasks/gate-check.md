# Gate Check

## Context
You run one phase's quality gate. The `/ruby-development` workflow calls you after each
stage (Step 2) and for the final run (Step 3); the `/rubyDev:ruby-gate` skill calls you
standalone. Thresholds live in `../references/quality-gates.md`, not here.

## Goal
Run the gate commands for one phase against the current working tree and report
`GATE: pass` or `GATE: fail` with the measured values. You decide nothing about routing:
you name the rollback target from the table and the orchestrator acts on it.

## Input
- `PHASE`: one of `specifier`, `implementer`, `cleaner`, `hardener`, `verifier`.
- `BASE`: the baseline ref (a commit hash, default `HEAD`); used only to list the files changed since `BASE` when `PATHS` is not given.
- `PATHS`: the files or directories in scope for the stage, when known. When not given, scope commands to files changed since `BASE`.
- `VERIFIER-REPORT`: for `PHASE` = `verifier` only, the verifier subagent's report (verdict and findings). The gate reads the SIFT verdict and severities from it and does not run the SIFT audit itself.
- The brief's threshold override, if any (for example, CRAP <= 8 for the cleaner).

## Instructions

1. **Read the phase's row** in `../references/quality-gates.md`.
   Take the gate commands, threshold, mode, and rollback target from that row only.

2. **Run each command** in the row against the current working tree, scoped to `PATHS`
   when given. Record the exit status and the measured value for each.

3. **Handle a command that does not apply** (for example packwerk outside Rails): record `not applicable: <reason>`; it never fails the gate. **Handle a missing tool.** If a command's tool is not installed, record
   `not run: <tool> unavailable` for that command. Do not install the tool and do not
   count the command as passed.

4. **Compare to the threshold.** A blocking command that misses its threshold fails the
   gate. A report-only command never fails the gate; record its value.

5. **Name the failing row** and its rollback target when the gate fails. A gate that failed
   only because of `not run` entries reports `GATE: fail (not run)`; the orchestrator does
   not roll back on it.

## Constraints
- Do NOT change any project file. Temporary configuration lives under the scratch directory;
  enable SimpleCov for the cleaner measurement with a scratch preload via `RUBYOPT=-r<scratch>/simplecov_preload.rb`, not by editing `spec_helper.rb`.
- Do NOT edit `quality-gates.md` or choose a different threshold.
- Do NOT dispatch a subagent.
- Do NOT report a pass on any command that did not run.

## Expected Output

```
GATE: pass | fail | fail (not run)
PHASE: <phase>
MEASURED: <command> → <value or exit status>   (one line per command)
NOT-RUN: <tool unavailable entries, or "none">
FAILING-ROW: <the phase row and the threshold missed, or "none">
ROLLBACK-TARGET: <phase from the table, or "none">
```

## Success Criteria
- [ ] Every command in the phase's row has a measured value or a `not run` entry
- [ ] The result follows the row's threshold exactly, with no override beyond the brief's stated one
- [ ] A failing result names its row and rollback target
