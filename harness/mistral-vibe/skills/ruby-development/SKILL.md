---
name: ruby-development
description: Deterministic Ruby dev workflow — survey/plan, phase-subagent dispatch and reconcile, verify/gate/synthesize. Run for any multi-stage Ruby task (build X, document it, and audit it) in a project where this plugin is installed.
user-invocable: true
---

# Ruby Development Workflow

This skill is the deterministic counterpart to the `rubyist` orchestrator agent (`vibe --agent rubyist`):
same protocol (Survey → Plan → Dispatch/Reconcile → Verify/Gate), but each stage is a task
file read on demand, so the orchestrating context stays lean regardless of how large the
underlying Ruby task is. The dispatched subagents are the five phase subagents of this
plugin — `rubyDev:specifier`, `rubyDev:implementer`, `rubyDev:cleaner`, `rubyDev:hardener`,
`rubyDev:verifier` — spawned with the `agents.spawn` tool.

## Locating this plugin's files

This skill lives at `<plugin-root>/skills/ruby-development/SKILL.md`, so the plugin root
is two directories up from this skill's directory. All `tasks/` and `references/` paths
below are relative to that plugin root. (Standard install locations:
`~/.vibe/plugins/ruby-dev/` user-global, or `<project>/.vibe/plugins/ruby-dev/`
project scope.)

## User Input

The task request is the text the user typed after `/rubyDev:ruby-development`, including
any `--path <repo-root>` or `--no-checkpoint` flags. If no task text was given, ask the
user for one before doing anything else.

## Workflow Execution

### Step 1: Survey & Plan

Spawn a generic subagent (an `agents.spawn` call with no `config_name`, so it inherits
your configuration) with this prompt:

```
Read <plugin-root>/tasks/step-1-survey-plan.md and execute.

Task request: <the user's task text>
```

**Capture**: the full `ROUTE:` ... `SCOPE-FLAG:` plan block.

If `SCOPE-FLAG` is not "none", stop and confirm with the user before
continuing — a scope-flagged plan needs a go-ahead before any subagent is dispatched.

### Step 2: Dispatch & Reconcile

For each line in the plan's `STAGES:`, in order (parallel only where `CONTRACTS` pins a
shared type for that pair):

Spawn the named phase subagent directly with the `agents.spawn` tool — `config_name`
`rubyDev:specifier`, `rubyDev:implementer`, `rubyDev:cleaner`, `rubyDev:hardener`, or
`rubyDev:verifier` — with the stage brief as its prompt, using the brief format from
`<plugin-root>/tasks/step-2-dispatch-reconcile.md`. Read that file once at the start of
this step for the exact brief template and reconciliation rules, then apply it yourself
across all stages rather than re-reading it per stage.

Before the baseline, read `<plugin-root>/tasks/analysis-gems.md` and execute it:
it adds `decode`, `bake`, and `rubydex` to the project Gemfile's development group when
they are missing. Capture its `ANALYSIS-GEMS:` line for the completion report.

Then, before the first dispatch, record the baseline (`git rev-parse HEAD` plus the
content-hash snapshot defined in `<plugin-root>/references/quality-gates.md`).

After each stage returns: compact its report to `CHANGED`/`FINDINGS`/`UNRESOLVED`/`NEXT`.
Reconcile any parallel pair against its pinned `CONTRACT` before briefing anything
downstream. Then run the scope check and the stage's gate
(`<plugin-root>/tasks/gate-check.md`), and roll back per
`<plugin-root>/references/quality-gates.md` (at most 2 rollbacks per gate, then ask the
user).

**Checkpoint.** When the route contains both `specifier` and `implementer`, pause after
the specifier returns: show the user the Gherkin scenarios and the QA procedure, and wait
for approval (use `ask_user_question`) before dispatching the implementer. If the
request contains `--no-checkpoint`, skip the pause. A route with no `specifier` has no
pause.

### Step 3: Verify & Gate

Spawn a generic subagent (or do this directly — it requires running the actual `VERIFY`
command, so whichever context has repo access) with this prompt:

```
Read <plugin-root>/tasks/step-3-gate-synthesize.md and execute.

Plan VERIFY/GATE: <from Step 1>
Step 2 dispatch log: <compacted stage results>
```

If `GATE-VERDICT` is NO-GO or `VERIFY-RESULT` failed: roll back per
`<plugin-root>/references/quality-gates.md` (verifier row, 2-rollback cap), then re-run
Step 3 before reporting anything to the user.

## Constraints

- You are the orchestrator in this workflow: never write Ruby yourself at any point.
  Every unit of Ruby work goes to a phase subagent.
- Do not load the role skills (`rubyDev:role-*`) into your own context; each phase
  subagent loads its own.

## Completion

Report to the user, citing file paths, not replaying full subagent output:
1. What was built/fixed and which subagents ran
2. `VERIFY-RESULT` and `GATE-VERDICT`, verbatim
3. Any known-unresolved Medium/Low findings
4. The `ANALYSIS-GEMS:` line (which gems were added to the Gemfile, if any)
