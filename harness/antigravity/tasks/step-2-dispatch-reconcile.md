# Step 2: Dispatch Subagents & Reconcile

## Context
You are the dispatch/reconcile stage of the `rubyist` development workflow, mirroring the
`rubyist` orchestrator's Step 3. The orchestrator runs
this logic itself between subagent calls after the Step 1 plan
was confirmed.

**Note on execution**: because each subagent dispatch and reconciliation decision
depends on the previous one's actual artifact (not a summary), this step is executed by the orchestrator directly issuing `invoke_subagent` calls in plan order.

## Goal
Turn each `STAGES:` line from the Step 1 plan into a complete brief, in plan order,
respecting the plan's `CONTRACTS`. Reconcile parallel stages against their pinned
contract before anything downstream is briefed.

## Input
- The full Step 1 plan.

## Instructions

1. **Write one brief per stage**, using this exact template:
   ```
   TASK: <one sentence>
   PATHS: <files or directories in scope>
   SKILLS: <domain skills the subagent loads for this task, from the plan's stage line, or "none">
   CONSTRAINTS: <mode, gems in play, anything pinned, the plan's CROSS-CUTTING decisions>
   CONTRACT: <the exact type/method shape this stage must produce and consume — "n/a" if nothing downstream reads this stage's output>
   PRIOR-ART: <sibling repos/files whose convention this stage must match, or "none">
   UPSTREAM: <2-5 bullet summary of relevant prior-stage findings, or "none">
   RETURN: <the specific artifact needed back>
   ```

2. **Respect sequencing.** Stages with no data dependency on each other may be briefed
   for parallel dispatch — but only stages whose shared `CONTRACT` type is already pinned
   in the Step 1 plan. Never brief two parallel peers without that type copied into both.

3. **Cleaner diagnoses before it changes.** Brief `cleaner` with the finding or measured
   hotspot when one exists; when the cause is unknown, its `TASK` is to diagnose first
   and the role skill's order (diagnose, change, re-measure) applies. Brief `hardener`
   only for mutation testing and dependency or security scanning.

4. **Architecture precedes AI implementation.** Any stage touching retrieval, RAG,
   agents, or LLM pipelines must have the `specifier`'s component plan in `UPSTREAM`
   before an `implementer` brief is written.

5. **After each subagent returns**, compact its report to `CHANGED` / `FINDINGS` /
   `UNRESOLVED` / `NEXT` before it enters the next brief's `UPSTREAM`.

6. **Record a baseline before the first dispatch.** Run `git rev-parse HEAD` and save
   the content-hash snapshot defined in `../references/quality-gates.md`,
   because the working tree may already be dirty. Every scope check below compares
   against this baseline, not against `HEAD` alone.
   When a stage will run `bundle` for the first time, list `Gemfile.lock` in that stage's
   `PATHS`; otherwise the generated lockfile fires scope triggers 1 and 3.

7. **Checkpoint after the specifier.** When the route contains both `specifier` and
   `implementer`, stop after the specifier returns. Show the user the Gherkin scenarios
   and the QA procedure, and wait for approval before briefing the implementer. Skip the
   pause when `--no-checkpoint` was passed, or when the route has no `specifier`.

8. **Scope check after every stage, before its gate.** Compare the working tree to the
   baseline. Stop and show the user the diff stat and the trigger that fired when any of
   the four escalation triggers in `../references/quality-gates.md`
   fires; the procedure is in that file's "Escalation triggers" section. A scope-check stop does not count against the rollback cap.

9. **Gate each stage.** Run `./gate-check.md` with the stage's
   phase name and the baseline ref (for the `verifier`, also pass the verifier subagent's compacted report as `VERIFIER-REPORT`). Do not copy gate commands or thresholds into briefs
   or into this step; the gate table is the only source.

10. **Roll back on a blocking failure.** Re-dispatch the rollback target named in the
    gate result, with the failure as the new `TASK`, then run the scope check and the
    gate again. After 2 rollbacks on the same gate, stop dispatching and ask the user.
    Phase agents never choose the route.

11. **Reconcile fan-outs immediately.** When a parallel pair returns, check both artifacts
    against the pinned `CONTRACT` field by field yourself — do not take either subagent's
    word for it. A mismatch is a stage failure: re-dispatch the wrong one with the
    corrected shape before anything downstream is briefed.

## Constraints
- Never paste a previous subagent's full raw output into the next brief — summaries only.
- Never write Ruby yourself, at any point in this step.
- Never dispatch a third rollback for the same gate.

## Expected Output
A running log, one entry per stage, in this shape:
```
STAGE <n>: <subagent-name>
BRIEF: <the brief sent>
RETURNED: CHANGED / FINDINGS / UNRESOLVED / NEXT (compacted)
RECONCILE: <ok | mismatch found + how it was resolved | n/a>
SCOPE-CHECK: <ok | trigger that fired + diff stat>
GATE: <GATE result from gate-check, with ROLLBACK count for this gate>
```

## Success Criteria
- [ ] Every STAGES line from the plan has a corresponding brief and result
- [ ] Every parallel pair was reconciled against its pinned CONTRACT before downstream briefing
- [ ] Every subagent's report was compacted before it entered the next brief
- [ ] A baseline was recorded before the first dispatch, and every stage had a scope check and a gate result
- [ ] The post-specifier pause happened unless `--no-checkpoint` or no implementer in the route
