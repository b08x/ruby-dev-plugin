# Step 3: Dispatch Specialists & Reconcile

## Context
You are the dispatch/reconcile stage of the `/ruby-development` workflow, mirroring the
`rubyist` gateway agent's Step 3. The orchestrator is running you (or, more likely,
running this logic itself between Task calls — see Note below) after trackboi filing
succeeded in Step 2.

**Note on execution**: because each specialist dispatch and reconciliation decision
depends on the previous one's actual artifact (not a summary), this step is usually best
executed by the orchestrator directly issuing Task calls in plan order, rather than
delegated wholesale to one sub-agent — a sub-agent dispatching further sub-agents cannot
nest. If you are a sub-agent reading this file, your job is to produce the *dispatch
briefs* for each stage; the orchestrator issues the actual Task calls from what you return.

## Goal
Turn each `STAGES:` line from the Step 1 plan into a complete brief, in plan order,
respecting the plan's `CONTRACTS`. Reconcile parallel stages against their pinned
contract before anything downstream is briefed.

## Input
- The full Step 1 plan.
- The trackboi card id from Step 2 (comments get attached to it as stages complete).

## Instructions

1. **Write one brief per stage**, using this exact template:
   ```
   TASK: <one sentence>
   PATHS: <files or directories in scope>
   CONSTRAINTS: <mode, gems in play, anything pinned, the plan's CROSS-CUTTING decisions>
   CONTRACT: <the exact type/method shape this stage must produce and consume — "n/a" if nothing downstream reads this stage's output>
   PRIOR-ART: <sibling repos/files whose convention this stage must match, or "none">
   UPSTREAM: <2-5 bullet summary of relevant prior-stage findings, or "none">
   RETURN: <the specific artifact needed back>
   ```

2. **Respect sequencing.** Stages with no data dependency on each other may be briefed
   for parallel dispatch — but only stages whose shared `CONTRACT` type is already pinned
   in the Step 1 plan. Never brief two parallel peers without that type copied into both.

3. **Diagnosis precedes change.** Never brief `refactorer` or `optimizer` without a prior
   `debugger` finding or a measured hotspot already in `UPSTREAM`.

4. **Architecture precedes AI implementation.** Any stage touching retrieval, RAG,
   agents, or LLM pipelines must have `cognitive-architect`'s component plan in
   `UPSTREAM` before a builder brief is written.

5. **After each specialist returns**, compact its report to `CHANGED` / `FINDINGS` /
   `UNRESOLVED` / `NEXT` before it enters the next brief's `UPSTREAM`. Add that compacted
   report as a comment on the trackboi card (`add_card_comment`).

6. **Reconcile fan-outs immediately.** When a parallel pair returns, check both artifacts
   against the pinned `CONTRACT` field by field yourself — do not take either specialist's
   word for it. A mismatch is a stage failure: re-dispatch the wrong one with the
   corrected shape before anything downstream is briefed.

## Constraints
- Never paste a previous specialist's full raw output into the next brief — summaries only.
- Never write Ruby yourself, at any point in this step.

## Expected Output
A running log, one entry per stage, in this shape:
```
STAGE <n>: <agent-name>
BRIEF: <the brief sent>
RETURNED: CHANGED / FINDINGS / UNRESOLVED / NEXT (compacted)
RECONCILE: <ok | mismatch found + how it was resolved | n/a>
CARD-COMMENT: posted
```

## Success Criteria
- [ ] Every STAGES line from the plan has a corresponding brief and result
- [ ] Every parallel pair was reconciled against its pinned CONTRACT before downstream briefing
- [ ] Every specialist's report was compacted and posted as a trackboi card comment
