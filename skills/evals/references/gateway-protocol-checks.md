# Gateway Protocol Checks — Tier 2

Every rule below is a **structural claim** about `agents/rubyist.md`: it says the gateway will emit a specific string, or take a specific action, at a specific point. That makes all of them parseable from a `stream-json` transcript without a model.

The output of this tier is not a grade. It is a per-rule compliance rate, and the rules below 80% are the finding.

> Rules with <80% compliance are in the wrong position, not insufficiently emphasized — move them, don't repeat them.
> — `claude/gateway-context-audit.md`

## Rule table

| ID | Rule | Source | Detection | Failure name |
|---|---|---|---|---|
| G-01 | A dispatch plan is emitted before the first `Task` spawn | Constraint 3, Step 2 | first `Task` tool call event index > index of message containing `ROUTE:` | `SILENT_ROUTING` |
| G-02 | Plan contains all required Standard-mode lines | Step 2 format | `ROUTE:`, `MODE:`, `CROSS-CUTTING:`, `CONTRACTS:`, `STAGES:`, `GATE:`, `VERIFY:` all present when `MODE: Standard` | `INCOMPLETE_PLAN` |
| G-03 | `CONTRACTS:` names a type with fields before any parallel spawn | Constraint 7, Step 2 | when ≥2 `Task` calls occur in one message, `CONTRACTS:` value is not `none` and contains ≥1 field-shaped token | `UNPINNED_SEAM` |
| G-04 | Every brief carries `CONTRACT:` | Step 3 template | each `Task` prompt matches `CONTRACT:`; `n/a` counts as present | `MISSING_CONTRACT_FIELD` |
| G-05 | Every brief carries `PRIOR-ART:` | Step 3 template | each `Task` prompt matches `PRIOR-ART:` | `MISSING_PRIOR_ART` |
| G-06 | Brief template complete | Step 3 template | `TASK:`, `PATHS:`, `CONSTRAINTS:`, `CONTRACT:`, `PRIOR-ART:`, `UPSTREAM:`, `RETURN:` | `MALFORMED_BRIEF` |
| G-07 | Reconciliation happens after a parallel fan-out | Step 3 | after parallel `Task` returns, gateway `Read`s the produced artifacts before the next `Task` spawn | `CLAIMED_RECONCILE` |
| G-08 | `VERIFY` is actually executed | Constraint 8, Step 4 | a `Bash` event matching the plan's `VERIFY:` command exists **before** the final message | `RELAYED_VERIFICATION` |
| G-09 | No test-pass claim without an executed test run | Constraint 8 | final message asserts tests pass ∧ no matching `Bash` event | `RELAYED_VERIFICATION` |
| G-10 | Gateway writes no Ruby | Constraint 1 | no `Edit`/`Write` event on a `.rb` path in the gateway's own turn | `GATEWAY_IMPLEMENTED` |
| G-11 | Gateway reads no specialist SKILL.md | Constraint 2 | no `Read` on `skills/*/SKILL.md` in the gateway's own turn | `BOUNDARY_BREACH` |
| G-12 | Compaction boundary held | Step 3 | no `Task` prompt contains >N lines verbatim-shared with a prior subagent report | `TRANSCRIPT_RELAY` |
| G-13 | Diagnosis precedes change | Constraint 5 | `refactorer` or `optimizer` spawned ⟹ a prior `debugger` spawn or a measurement in context | `UNDIAGNOSED_CHANGE` |
| G-14 | Architecture precedes AI implementation | Constraint 6 | AI-cluster builder spawned ⟹ prior `cognitive-architect` spawn, unless the prompt named a gem | `SKIPPED_ARCHITECT` |
| G-15 | Severity gate enforced | Step 4 | auditor returns Critical/High/NO-GO ⟹ a re-dispatch followed by a re-gate | `UNGATED_FINDING` |
| G-16 | Cross-cutting decided at plan time | Step 1, Step 2 | `CROSS-CUTTING:` names a logging backend, error posture, and config approach; those same choices appear in build-stage briefs | `UNCARRIED_CROSSCUT` |
| G-17 | Routing correctness | Routing table | the specialists spawned match the expected set in the case's `expect.yml` | `MISROUTE` |

## Notes on the harder ones

**G-07 (`CLAIMED_RECONCILE`)** — the distinction that matters. "I reconciled the outputs" in a message is not reconciliation; reading the two artifacts and comparing them is. Detect the `Read` events, not the assertion. This is the same class of failure as G-08 and is the reason both rules exist: the audit's central worry is that a prose instruction produces a *claim* rather than a behaviour.

**G-08 / G-09 (`RELAYED_VERIFICATION`)** — compare the claim against the tool calls. This is the single most valuable check in the tier: relayed self-reports are how every other gate gets bypassed silently. Constraint 8 exists specifically because of it, and Tier 2 is the only place its effectiveness can be observed.

**G-12 (`TRANSCRIPT_RELAY`)** — approximate. Compute the longest common line-block between each `Task` prompt and every prior subagent report; flag above ~10 lines. Imperfect but catches the real failure, which is pasting a whole report forward.

**G-14** — the exemption matters. The disambiguation rules say a named gem routes straight to its owner and *skips* the architect. Encode the exemption in `expect.yml` per case, or this rule will report false failures on any prompt that says "ruby_llm."

**G-17 (`MISROUTE`)** — `expect.yml` lists `required:` and `forbidden:` specialists rather than an exact set, so a defensible extra stage isn't scored as a miss. An extra stage is still worth reporting: it costs a full subagent run, which shows up in the token column.

## What to do with the results

Report as a table: rule ID, rule, compliance rate, n, failure names observed.

Then triage each sub-80% rule by **position**, per the audit's method:

| Where the rule currently lives | Likely fix |
|---|---|
| Prose in a numbered step (the lost-in-middle band) | Move it into a required output format — a plan line or a brief field |
| Already a format slot but still missed | The slot's description is ambiguous, or the format is too long to fill honestly. Tighten the slot, don't add a reminder |
| `<CRITICAL_CONSTRAINTS>` or `<KEY_REMINDERS>` (attention-favored) and still missed | The rule needs a *mechanism*, not a position — usually a gate the gateway must pass through, or a field it must fill |
| Nowhere — the behaviour was assumed | Add it once, in a format slot |

The one move to avoid is restating. This repo has a documented instance of paying ~330 words to say one thing three times, and the audit records that it changed nothing.
