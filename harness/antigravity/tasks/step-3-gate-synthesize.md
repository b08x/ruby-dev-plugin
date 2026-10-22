# Step 3: Gate and Synthesize

## Context
You are the final stage of the `rubyist` development workflow, mirroring the `rubyist`
orchestrator's Step 4. All subagent stages from Step 2 have returned.

## Goal
Independently verify the work, gate on the verifier's verdict if one ran,
then hand the user a compact, evidence-based summary. Never relay an
unverified claim.

## Input
- The Step 1 plan (specifically `VERIFY` and `GATE`).
- The Step 2 dispatch log (all stage results).

## Instructions

1. **Run `VERIFY` yourself.** Execute the exact command named in the plan
   (`bundle exec rspec`, `ruby -c`, reading the type file directly — whatever it was).
   Do not trust a subagent's "tests pass" claim as a substitute for running it.

2. **Check the gate.** Run `./gate-check.md` for the final
   phase of the route (`verifier` when it ran, otherwise the last phase that ran) and
   passing the verifier's report as `VERIFIER-REPORT` for the verifier phase, and for every phase in the plan's `GATE` field whose last gate result was not a pass.
   - **`GATE: fail` (other than `fail (not run)`), a Critical or High finding, or a NO-GO verdict means the route is
     not done.** Roll back to the target named in the failing phase's row of
     `references/quality-gates.md`, within that file's 2-rollback cap (ask the user if the target is not in the route), then re-run the gate and `VERIFY`. `GATE: fail (not run)` triggers no rollback; the route closes as "done with NOT-RUN gates".
   - Only Medium/Low findings may be reported to the user as known-unresolved.
   - Report the verdict verbatim — including when it fails.
   - List every `not run: <tool> unavailable` entry from any gate in the summary.

3. **Surface contradictions, don't paper over them.** If a subagent's report
   contradicted an earlier stage, name the conflict explicitly in the synthesis rather
   than silently picking one version.

## Constraints
- Do NOT report "done" without having personally run `VERIFY` in this step.
- Do NOT report a route as complete on anything less than a passing gate + VERIFY, except a gate that did not run because a tool was missing: that is not a pass, and it is reported under `NOT-RUN`.

## Expected Output

```
VERIFY-RESULT: <command run> → <pass/fail, with the actual output or a summary of it>
GATE-VERDICT: <verbatim verifier verdict and GATE result, or "none — no gate in this plan">
NOT-RUN: <every gate command that did not run because a tool was missing, or "none">
RE-DISPATCH: <none | what was re-dispatched and the result of the re-gate>
SUMMARY-FOR-USER: <what was built/fixed, which subagents ran, file paths touched, any known-unresolved Medium/Low findings>
```

## Success Criteria
- [ ] VERIFY was actually executed in this step, not assumed from a subagent's claim
- [ ] Any `GATE: fail` (other than `fail (not run)`), Critical/High finding or NO-GO triggered a rollback and re-gate before closeout, or a stop at the cap
- [ ] The reported outcome matches the verify and gate results exactly
