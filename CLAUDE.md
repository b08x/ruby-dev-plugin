# ruby-dev-plugin — Agent Playbook

## Strategies and Hard Rules

### Anti-patterns and Pitfalls

- **Narrowly-briefed specialist subagents can still scope-creep past their brief.** A `ruby-dev:refactorer` briefed only to fix a gemspec/Gemfile version pin and run `bundle exec rubocop -a` instead produced a 36-file diff (spec directory reorg, dead-code relocation into new files, manual architectural rewrites of unrelated FFI/config modules) after running 3h41m unattended. The brief being narrow does not bound the agent's actual behavior — it bounds only what you *asked for*, not what it *does*.
  - **Detection**: an in-flight subagent running far longer than the task's apparent size warrants (hours for a one-line pin bump) is itself a signal, independent of what it eventually returns. Don't wait for the report to check — poll `ListAgents` / watch the diff shape while it's still running.
  - **Correct approach**: on suspicion of runaway scope, `TaskStop` immediately rather than let it "finish" — a stopped agent mid-edit can leave a real bug (e.g., a spec rewritten from `before { @x = ... }` to `let(:x)` with call sites still referencing the now-nil ivar), so the next step is always an independent `ruby-dev:auditor` pass in a fresh context, never trusting the stopped agent's own summary of what it did.
  - **Verification discipline**: "tests pass" or "diff is clean" from the acting subagent is a claim, not evidence. Route every rogue/large diff through an isolated auditor before deciding revert-vs-keep, and decide per-hunk (keep the legitimate fix + mechanical autofixes, revert the unrequested restructuring) rather than all-or-nothing.

### Rubyist gateway: trackboi filing is a hard gate, not bookkeeping

- When integrating a task-tracking system (trackboi) into the Rubyist dispatch protocol, the correct failure mode for "card/track filing failed" is **hard stop and resolve first** (switch project, create the missing board/track, or ask the user) — not "skip silently, it's just bookkeeping." Tracking state that silently drifts from actual work is a worse failure than a blocked dispatch, because it corrupts the record every future session relies on.
  - Narrow exception: if trackboi's MCP tools are genuinely absent from the session (not in the tool list at all — not merely erroring), that's a session-capability gap, not a retryable failure; fall back to running without trackboi and say so plainly in the synthesis.
