# Step 3: Gate and Synthesize

## Context
You are the final stage of the `/ruby-development` workflow, mirroring the `rubyist`
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

2. **Check the gate.** If the plan named a verifier gate:
   - **Any Critical or High severity finding, or a NO-GO verdict, means the route is not
     done.** Re-dispatch the owning stage with the finding as its new `TASK`, then
     re-run the verifier and `VERIFY` again.
   - Only Medium/Low findings may be reported to the user as known-unresolved.
   - Report the verdict verbatim — including when it fails.

3. **Surface contradictions, don't paper over them.** If a subagent's report
   contradicted an earlier stage, name the conflict explicitly in the synthesis rather
   than silently picking one version.

## Constraints
- Do NOT report "done" without having personally run `VERIFY` in this step.
- Do NOT report a route as complete on anything less than a passing gate + VERIFY.

## Expected Output

```
VERIFY-RESULT: <command run> → <pass/fail, with the actual output or a summary of it>
GATE-VERDICT: <verbatim verifier verdict, or "none — no gate in this plan">
RE-DISPATCH: <none | what was re-dispatched and the result of the re-gate>
SUMMARY-FOR-USER: <what was built/fixed, which subagents ran, file paths touched, any known-unresolved Medium/Low findings>
```

## Success Criteria
- [ ] VERIFY was actually executed in this step, not assumed from a subagent's claim
- [ ] Any Critical/High finding or NO-GO triggered a re-dispatch and re-gate before closeout
- [ ] The reported outcome matches the verify and gate results exactly
