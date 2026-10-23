# Ruby Development Rules for Antigravity

These workspace rules apply to all Ruby development workflows driven by Antigravity CLI (`agy`) and the `ruby-dev` plugin.

---

## 1. Ruby Coding Standards

When writing, refactoring, or generating Ruby code in this workspace:

- **Frozen String Literals**: Always include `# frozen_string_literal: true` as line 1 of every `.rb` file.
- **Zeitwerk Compliance**: Follow Zeitwerk directory and file naming conventions strictly. File paths must mirror module and class namespaces exactly (e.g. `lib/my_app/user_service.rb` defines `MyApp::UserService`).
- **Type Safety and Error Handling (dry-rb)**:
  - For complex logic, domain models, and public boundaries, use `dry-struct` typing and `dry-monads` (`Success` / `Failure`) rather than unstructured Hashes and bare rescues.
  - Lite scripts (under ~50 lines, standalone) may remain standard library only.
- **Method Visibility**:
  - Default all new methods to `private`.
  - Promote methods to `public` only when they are deliberate, stable parts of the object's published interface.
- **Parameter Forwarding**: Forward undeclared arguments with `...` (`def foo(...) = bar(...)`) rather than re-declaring parameters.
- **Inline Gem API Verification**:
  - Verify non-stdlib gem APIs at the point of use using Context7 MCP (`query-docs` / `resolve-library-id`) or DeepWiki MCP.
  - If MCP tools are unavailable, gracefully fall back to web search (`search_web`) or local codebase discovery (`search_graph`, inspecting existing tests and implementation).
  - Never assume non-stdlib gem API signatures from memory.
- **Ruby Code Structure Discovery**:
  - In Ruby projects, query the rubydex MCP tools first (`search_declarations`, `get_declaration`, `get_file_declarations`, `find_constant_references`, `get_descendants`, `find_dead_code_candidates`, `codebase_stats`).
  - Use codebase-memory discovery (`search_graph`) only when rubydex is not mounted, or for non-Ruby files. Confirm a rubydex "no references" result with `grep`, because rubydex does not see `send`/`method_missing`/DSL dispatch.
- **Documentation Comments**: Write decode tags (`@parameter name [Type]`, `@returns`, `@raises`, `@yields`, `@option`, `@attribute`, `@example`), never YARD tags. decode reads `@param`/`@return` as plain text.

---

## 2. Orchestrator Invariants (`rubyist`)

The `rubyist` orchestrator coordinates multi-phase development:

1. **Never writes Ruby**: The orchestrator must NEVER author, edit, or refactor `.rb` files directly. All code modifications are routed to phase subagents via `invoke_subagent` (with `define_subagent` fallback).
2. **Fixed Phase Sequence**: Routes through the 5 phase subagents in order: `specifier` → `implementer` → `cleaner` → `hardener` → `verifier`, skipping non-applicable phases with an explicit rationale.
3. **Plan Before Spawning**: Emit the structured dispatch plan (`ROUTE`, `MODE`, `CROSS-CUTTING`, `CONTRACTS`, `STAGES`, `GATE`, `VERIFY`) before spawning any subagent.
4. **Pinned Parallel Contracts**: Parallel stages must share a pinned type contract written field-by-field in `CONTRACTS` before dispatch.
5. **Verify, Don't Relay**: Before summarizing or accepting claims (e.g., "all tests pass"), run the verification command (`VERIFY`) in the orchestrator context.
6. **Capped Rollbacks**: Capped at at most 2 rollbacks per quality gate before stopping and asking the user.

---

## 3. Quality Gate Thresholds & Deterministic Checks

| Phase | Gate Name | Deterministic Command / Check | Blocking Threshold | Rollback Target |
|---|---|---|---|---|
| `specifier` | STRIDE | `bundle exec cucumber --dry-run` | 1 misuse scenario per trust boundary crossing; cucumber parses cleanly | `specifier` |
| `implementer` | suite + gitleaks | `bundle exec rspec` / `rake test` && `cucumber` (if `features/`) && `gitleaks detect` | Test runner passes (0 failures); cucumber passes; 0 gitleaks findings; CC <= 4 (report-only) | `implementer` |
| `cleaner` | CRAP | `simplecov` + `rubocop --only Metrics/CyclomaticComplexity` | CRAP <= 6 (or <= 8 if specified); CC <= 6 per method | `cleaner` |
| `hardener` | mutation + audit | `bundle exec mutant run` && `bundler-audit check` && `brakeman` (Rails) | Mutant score >= 80% or 0 unexplained surviving mutants; 0 high/crit `bundler-audit` vulnerabilities; 0 high/crit `brakeman` warnings | `implementer` (for mutant test gaps) |
| `verifier` | packwerk + zeitwerk + SIFT | `packwerk check` (Rails) && Zeitwerk eager load && `cucumber` && `rubocop` && SIFT | 0 packwerk errors; 0 Zeitwerk errors; cucumber passes; rubocop clean; SIFT verdict GO (0 Critical/High findings) | Target named by failing check row |

Report-only analysis checks, which never fail a gate: the verifier runs `bundle exec rdx lint` and `bundle exec bake decode:index:coverage`; the cleaner runs `bundle exec rdx dead_code`. Before the baseline, the orchestrator runs `tasks/analysis-gems.md`, which adds `decode`, `bake`, and `rubydex` to the project Gemfile's development group when they are missing; that Gemfile change is part of the baseline and does not fire the protected-path trigger.

### Escalation Triggers (Working Tree Scope Checks)

After every phase, compare the working tree against the pre-dispatch baseline:

1. **Trigger 1 (Out-of-Scope Files)**: Files modified outside the explicit `PATHS` declared in the brief.
2. **Trigger 2 (File Deletions)**: Unexpected deletion of existing source or test files.
3. **Trigger 3 (Dependency Mutation)**: Modification of `Gemfile` or `Gemfile.lock` not declared in `PATHS`.
4. **Trigger 4 (Untracked Mod)**: Pre-existing tracked files touched when only new files were expected.

When an escalation trigger fires, halt execution and present the diff stat to the user.

---

## 4. Subagent Operational Constraints & Reporting Contract

Each subagent runs in an isolated context and must return a compact report:

```text
CHANGED: <file paths modified/created, or "none">
FINDINGS: <2-5 bullet points of concrete facts, gate name, and measured values>
UNRESOLVED: <blockers, missing tools, or "none">
NEXT: <clear instructions for the subsequent phase, or "none">
```

- `specifier`: Writes NO production code and NO unit tests. Creates `features/*.feature`, `features/qa-procedure.md`, and component plan.
- `implementer`: Writes tests and production code until tests pass.
- `cleaner`: Reduces complexity in already-passing code. Follows fixed order: diagnose → change → re-measure. Does not run mutation tests or security scans.
- `hardener`: Adds tests to kill mutants and identifies security vulnerabilities. Changes NO production code.
- `verifier`: Writes NO code. Runs independent verification checks in a fresh context and produces SIFT audit verdict.
