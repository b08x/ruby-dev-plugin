---
description: Deterministic Ruby dev workflow — survey/plan, hard-gated trackboi filing, specialist dispatch, verify/gate/close-out
argument-hint: <task description> [--path <repo-root>]
allowed-tools: Task, Read, Bash, mcp__trackboi__get_active_project, mcp__trackboi__switch_project, mcp__trackboi__create_board, mcp__trackboi__list_tracks, mcp__trackboi__create_track, mcp__trackboi__create_card, mcp__trackboi__move_card, mcp__trackboi__add_card_comment
model: sonnet
---

# Ruby Development Workflow

This command is the deterministic counterpart to the `ruby-dev:rubyist` gateway agent:
same protocol (Survey → Plan → Trackboi gate → Dispatch/Reconcile → Verify/Gate/Close),
but each stage is a task file a sub-agent reads on demand, so this orchestrator stays
lean regardless of how large the underlying Ruby task is.

## User Input

```text
$ARGUMENTS
```

## Workflow Execution

### Step 1: Survey & Plan

Launch a `general-purpose` agent:
- **Description**: "Survey and plan Ruby route"
- **Prompt**:
  ```
  Read /home/b08x/WorkspaceV3/ruby-dev-plugin/tasks/step-1-survey-plan.md and execute.

  Task request: $ARGUMENTS
  ```

**Capture**: the full `ROUTE:` ... `SCOPE-FLAG:` plan block.

If `SCOPE-FLAG` is not "none", or `MODE: Lite`, stop and confirm with the user before
continuing — Lite mode skips Step 2 (trackboi) entirely per the plan's own protocol; a
scope-flagged plan needs a go-ahead before any card is filed or specialist dispatched.

### Step 2: File the Route in Trackboi (skip only if MODE: Lite)

Launch a `general-purpose` agent with trackboi tool access:
- **Description**: "File route in trackboi"
- **Prompt**:
  ```
  Read /home/b08x/WorkspaceV3/ruby-dev-plugin/tasks/step-2-trackboi-gate.md and execute.

  Dispatch plan from Step 1:
  <paste the full plan block>

  Repo root: <path from --path or inferred from the task>
  ```

**Hard gate**: if `TRACKBOI-STATUS: blocked`, stop here and report the blocker to the
user. Do not proceed to Step 3. Only `filed` or `unavailable` (tools genuinely absent)
permit continuing.

**Capture**: `CARD` id for later comments/closeout.

### Step 3: Dispatch & Reconcile

For each line in the plan's `STAGES:`, in order (parallel only where `CONTRACTS` pins a
shared type for that pair):

Launch the named specialist agent directly (e.g. `ruby-dev:debugger`,
`ruby-dev:refactorer`, `ruby-dev:auditor`, `ruby-dev:cognitive-architect`, ...) using the
brief format from `/home/b08x/WorkspaceV3/ruby-dev-plugin/tasks/step-3-dispatch-reconcile.md`
— read that file once at the start of this step for the exact brief template and
reconciliation rules, then apply it yourself across all stages rather than re-reading it
per stage.

After each stage returns: compact its report to `CHANGED`/`FINDINGS`/`UNRESOLVED`/`NEXT`
and call `add_card_comment` on the Step 2 card with that compacted report. Reconcile any
parallel pair against its pinned `CONTRACT` before briefing anything downstream.

### Step 4: Verify, Gate, Close Out

Launch a `general-purpose` agent (or do this directly — it requires running the actual
`VERIFY` command, so whichever context has repo access):
- **Description**: "Verify, gate, and close out route"
- **Prompt**:
  ```
  Read /home/b08x/WorkspaceV3/ruby-dev-plugin/tasks/step-4-gate-synthesize.md and execute.

  Plan VERIFY/GATE: <from Step 1>
  Step 3 dispatch log: <compacted stage results>
  Trackboi card: <CARD id from Step 2>
  ```

If `GATE-VERDICT` is NO-GO or `VERIFY-RESULT` failed: re-dispatch the owning stage per
this file's instructions, then re-run Step 4 before reporting anything to the user.

## Completion

Report to the user, citing file paths, not replaying full specialist output:
1. What was built/fixed and which specialists ran
2. `VERIFY-RESULT` and `GATE-VERDICT`, verbatim
3. Trackboi card status (done / blocked / unavailable) and its id
4. Any known-unresolved Medium/Low findings
