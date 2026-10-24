# ruby-dev-plugin — Agent Playbook

## Strategies and Hard Rules

### Anti-patterns and Pitfalls

- **Narrowly-briefed phase subagents can still scope-creep past their brief.** The former combined cleaner/hardener agent (since split into `cleaner` and `hardener`), briefed only to fix a gemspec/Gemfile version pin and run `bundle exec rubocop -a` instead produced a 36-file diff (spec directory reorg, dead-code relocation into new files, manual architectural rewrites of unrelated FFI/config modules) after running 3h41m unattended. The brief being narrow does not bound the agent's actual behavior — it bounds only what you *asked for*, not what it *does*.
  - **Detection**: an in-flight subagent running far longer than the task's apparent size warrants (hours for a one-line pin bump) is itself a signal, independent of what it eventually returns. Don't wait for the report to check — poll `ListAgents` / watch the diff shape while it's still running.
  - **Correct approach**: on suspicion of runaway scope, `TaskStop` immediately rather than let it "finish" — a stopped agent mid-edit can leave a real bug (e.g., a spec rewritten from `before { @x = ... }` to `let(:x)` with call sites still referencing the now-nil ivar), so the next step is always an independent `ruby-dev:verifier` pass in a fresh context, never trusting the stopped agent's own summary of what it did.
  - **Verification discipline**: "tests pass" or "diff is clean" from the acting subagent is a claim, not evidence. Route every rogue/large diff through an isolated `ruby-dev:verifier` before deciding revert-vs-keep, and decide per-hunk (keep the legitimate fix + mechanical autofixes, revert the unrequested restructuring) rather than all-or-nothing.

### Use Context7 MCP for Loading Documentation

Context7 MCP is available to fetch up-to-date documentation with code examples.

**Recommended library IDs**:

- `/marcoroth/rubydex` - Rubydex: static analysis and code indexing toolkit for Ruby, built in Rust with Ruby and Rust APIs; used by language servers, type checkers, and linters (High reputation, Benchmark 81, 1383 snippets). `/shopify/rubydex` is an alternate index with fewer snippets (Benchmark 56.17)
- `/socketry/decode` - Decode: Ruby code analysis and documentation generator; symbol extraction and cross-referencing (High reputation, Benchmark 51, 412 snippets). `/websites/socketry_github_io_decode` is the docs-site index (310 snippets)
