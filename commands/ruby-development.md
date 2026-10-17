---
description: Deterministic Ruby dev workflow — survey/plan, subagent dispatch and reconcile, verify/gate/synthesize
argument-hint: <task description> [--path <repo-root>] [--no-checkpoint]
allowed-tools: Task, Agent, Read, Bash
model: sonnet
---

# Ruby Development Workflow

This command is the deterministic counterpart to the `ruby-dev:rubyist` orchestrator agent:
same protocol (Survey → Plan → Dispatch/Reconcile → Verify/Gate), but each stage is a task
file a sub-agent reads on demand, so this orchestrator stays lean regardless of how large
the underlying Ruby task is. The dispatched subagents are the five phase subagents:
`ruby-dev:specifier`, `ruby-dev:implementer`, `ruby-dev:cleaner`, `ruby-dev:hardener`, `ruby-dev:verifier`.

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
  Read ${CLAUDE_PLUGIN_ROOT}/tasks/step-1-survey-plan.md and execute.

  Task request: $ARGUMENTS
  ```

**Capture**: the full `ROUTE:` ... `SCOPE-FLAG:` plan block.

If `SCOPE-FLAG` is not "none", stop and confirm with the user before
continuing — a scope-flagged plan needs a go-ahead before any subagent is dispatched.

### Step 2: Dispatch & Reconcile

For each line in the plan's `STAGES:`, in order (parallel only where `CONTRACTS` pins a
shared type for that pair):

Launch the named phase subagent directly (`ruby-dev:specifier`, `ruby-dev:implementer`,
`ruby-dev:cleaner`, `ruby-dev:hardener`, or `ruby-dev:verifier`) using the brief format from
`${CLAUDE_PLUGIN_ROOT}/tasks/step-2-dispatch-reconcile.md` — read that file once at the
start of this step for the exact brief template and reconciliation rules, then apply it
yourself across all stages rather than re-reading it per stage.

Before the first dispatch, record the baseline (`git rev-parse HEAD` plus the
content-hash snapshot defined in `${CLAUDE_PLUGIN_ROOT}/references/quality-gates.md`).

After each stage returns: compact its report to `CHANGED`/`FINDINGS`/`UNRESOLVED`/`NEXT`.
Reconcile any parallel pair against its pinned `CONTRACT` before briefing anything
downstream. Then run the scope check and the stage's gate (`tasks/gate-check.md`), and
roll back per `${CLAUDE_PLUGIN_ROOT}/references/quality-gates.md` (at most 2 rollbacks per
gate, then ask the user).

**Checkpoint.** When the route contains both `specifier` and `implementer`, pause after
the specifier returns: show the user the Gherkin scenarios and the QA procedure, and wait
for approval before dispatching the implementer. If `$ARGUMENTS` contains
`--no-checkpoint`, skip the pause. A route with no `specifier` has no pause.

### Step 3: Verify & Gate

Launch a `general-purpose` agent (or do this directly — it requires running the actual
`VERIFY` command, so whichever context has repo access):
- **Description**: "Verify and gate route"
- **Prompt**:
  ```
  Read ${CLAUDE_PLUGIN_ROOT}/tasks/step-3-gate-synthesize.md and execute.

  Plan VERIFY/GATE: <from Step 1>
  Step 2 dispatch log: <compacted stage results>
  ```

If `GATE-VERDICT` is NO-GO or `VERIFY-RESULT` failed: roll back per
`${CLAUDE_PLUGIN_ROOT}/references/quality-gates.md` (verifier row, 2-rollback cap), then re-run Step 3 before reporting anything to the user.

## Completion

Report to the user, citing file paths, not replaying full subagent output:
1. What was built/fixed and which subagents ran
2. `VERIFY-RESULT` and `GATE-VERDICT`, verbatim
3. Any known-unresolved Medium/Low findings
