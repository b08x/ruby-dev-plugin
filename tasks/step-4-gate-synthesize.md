# Step 4: Gate, Synthesize, Close Out Trackboi

## Context
You are the final stage of the `/ruby-development` workflow, mirroring the `rubyist`
gateway agent's Step 4. All specialist stages from Step 3 have returned.

## Goal
Independently verify the work, gate on the auditor's verdict if one ran, and close out
the trackboi card — then hand the user a compact, evidence-based summary. Never relay an
unverified claim.

## Input
- The Step 1 plan (specifically `VERIFY` and `GATE`).
- The Step 3 dispatch log (all stage results).
- The trackboi card id.

## Instructions

1. **Run `VERIFY` yourself.** Execute the exact command named in the plan
   (`bundle exec rspec`, `ruby -c`, reading the type file directly — whatever it was).
   Do not trust a specialist's "tests pass" claim as a substitute for running it.

2. **Check the gate.** If the plan named an auditor gate:
   - **Any Critical or High severity finding, or a NO-GO verdict, means the route is not
     done.** Re-dispatch the owning stage with the finding as its new `TASK`, then
     re-run the auditor and `VERIFY` again.
   - Only Medium/Low findings may be reported to the user as known-unresolved.
   - Report the verdict verbatim — including when it fails.

3. **Close out the trackboi card:**
   - On a passing gate + successful `VERIFY`: `add_card_comment` with the final
     synthesis, then `move_card` to `done`.
   - On NO-GO or `VERIFY` failure: `add_card_comment` with the failure detail, and leave
     the card in `doing` — do not mark it done on a failed route.

4. **Surface contradictions, don't paper over them.** If a specialist's report
   contradicted an earlier stage, name the conflict explicitly in the synthesis rather
   than silently picking one version.

## Constraints
- Do NOT report "done" without having personally run `VERIFY` in this step.
- Do NOT mark the trackboi card `done` on anything less than a passing gate + VERIFY.

## Expected Output

```
VERIFY-RESULT: <command run> → <pass/fail, with the actual output or a summary of it>
GATE-VERDICT: <verbatim auditor verdict, or "none — no gate in this plan">
RE-DISPATCH: <none | what was re-dispatched and the result of the re-gate>
TRACKBOI-CLOSEOUT: done | left in doing (blocked) — <card id>
SUMMARY-FOR-USER: <what was built/fixed, which specialists ran, file paths touched, any known-unresolved Medium/Low findings>
```

## Success Criteria
- [ ] VERIFY was actually executed in this step, not assumed from a specialist's claim
- [ ] Any Critical/High finding or NO-GO triggered a re-dispatch and re-gate before closeout
- [ ] The trackboi card's final column matches the actual outcome (done only if genuinely done)
