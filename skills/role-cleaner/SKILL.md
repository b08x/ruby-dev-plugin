---
name: role-cleaner
description: "Internal phase skill, loaded by the `cleaner` subagent; do not trigger directly. Use as the Cleaner phase of a Ruby build - diagnoses first, then refactors until the CRAP score meets a stated threshold. Also covers bug diagnosis, named refactorings, and measured performance work."
---

# Role: Cleaner

## Purpose

Diagnose, then refactor code that already passes its tests until the CRAP score and per-method complexity meet the gate.

**Order is fixed: diagnose, change, re-measure.** No change is made without a finding (a smell, a bug, or a measured hotspot), and every change is followed by a re-run of the test suite and the measurement that motivated it. Behavior stays identical, except for a bug fix: first add a failing test that reproduces the bug, and that fix is the only permitted behavior change; the suite must pass before and after each change.

Mutation testing and security scanning belong to the `hardener` phase. Do not run them here.

## Inputs

- Production code and unit tests from the Implementer (paths in the brief).
- The threshold from the brief; default CRAP threshold is **6** (**8** only when the brief states it). The gate row is in `${CLAUDE_PLUGIN_ROOT}/references/quality-gates.md` (row: cleaner).

## Outputs

- Refactored source meeting the CRAP and complexity thresholds.
- A list of methods with CRAP > 30 that could not be reduced (the orchestrator escalates these to the user).

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Test suite (re-run after every change) | `rspec` / `minitest` | `bundle exec rspec` or `bundle exec rake test` | see `role-implementer` |
| Coverage | `simplecov` | run the suite with a scratch preload that does `require "simplecov"; SimpleCov.start` (`RUBYOPT=-r<scratch>/simplecov_preload.rb`), without editing `spec_helper.rb`; read `coverage/.resultset.json` | `gem install simplecov` |
| Cyclomatic complexity per method | `rubocop` | `bundle exec rubocop --only Metrics/CyclomaticComplexity --format json` with `Metrics/CyclomaticComplexity: { Max: 1 }` in a temporary config, so every method reports its score as `[n/1]` | `gem install rubocop` |
| Complexity cross-check (optional) | `flog` | `bundle exec flog -g lib` | `gem install flog` |
| Dead code candidates (report-only) | `rubydex` | `bundle exec rdx dead_code`. Keep only entries whose location is under the project's `lib/` or `app/`, and drop `<anonymous>` entries. Each candidate is a lead, not a verdict: confirm with `grep -rn` (dynamic calls, `send`, and DSL registration are invisible to rubydex) before removing anything | added by the orchestrator (`tasks/analysis-gems.md`) |
| Reference and ancestor queries before a rename, move, or hierarchy change | `rubydex` | rubydex MCP tools `find_constant_references`, `get_descendants`, `get_declaration`; or `bundle exec rdx query "<Cypher>" --format json` (schema: `bundle exec rdx query --schema`) | added by the orchestrator (`tasks/analysis-gems.md`) |

### CRAP score

`CRAP(m) = complexity(m)^2 * (1 - coverage(m))^3 + complexity(m)`

where `complexity(m)` is the cyclomatic complexity of method `m` and `coverage(m)` is the fraction of its lines covered (0 to 1). Compute coverage per method as the covered share of the method's line range in `coverage/.resultset.json`. A method at or below the threshold passes. A method above it is refactored (extract method, replace conditional, remove duplication) or covered by additional tests, then re-measured. The gate also requires CC <= 6 per method. A method with CRAP > 30 that stays above 30 after refactoring is reported under `UNRESOLVED` for escalation.

## Task-to-skill loading

| Task | Load |
|---|---|
| Symptom described, cause unknown; Zeitwerk errors; dead code; unfamiliar code | `${CLAUDE_PLUGIN_ROOT}/skills/analyse/SKILL.md` |
| A diagnosed smell needs a named transformation (Zeitwerk, bare rescue, thread-to-async, nested conditionals, frozen strings) | `${CLAUDE_PLUGIN_ROOT}/skills/refactor/SKILL.md` |
| Slow code, allocation pressure, "profile", "benchmark" | `${CLAUDE_PLUGIN_ROOT}/skills/perf/SKILL.md` |
| Evaluating the ruby-dev plugin itself (baseline eval, harness) | `${CLAUDE_PLUGIN_ROOT}/skills/evals/SKILL.md` |

**Performance rule.** Profile before optimizing (`stackprof`), benchmark before and after (`benchmark-ips`), and revert any optimization that gains less than about 10-20%. Never optimize on intuition.

## Report

Follows `${CLAUDE_PLUGIN_ROOT}/references/subagent-mandates.md`. `FINDINGS` states the gate name (`cleaner: CRAP`), the threshold, and the worst CRAP score and worst CC before and after.
