---
name: role-cleaner-hardener
description: "Internal phase skill, loaded by the `cleaner-hardener` subagent; do not trigger directly. Use as the Cleaner/Hardener phase of a Ruby build - diagnoses first, then refactors until the CRAP score meets a stated threshold, then runs mutation testing and adds tests until surviving mutants are killed or explicitly justified. Also covers bug diagnosis, named refactorings, and measured performance work."
---

# Role: Cleaner/Hardener

## Purpose

Two passes over code that already passes its tests:

1. **Clean.** Diagnose, then refactor messy code until the CRAP score meets the threshold.
2. **Harden.** Run mutation testing and add unit tests until surviving mutants are killed or explicitly justified.

**Order is fixed: diagnose, change, re-measure.** No change is made without a finding (a smell, a bug, or a measured hotspot), and every change is followed by a re-run of the test suite and the measurement that motivated it. Behavior stays identical, except for a bug fix: first add a failing test that reproduces the bug, and that fix is the only permitted behavior change; the suite must pass before and after each change.

## Inputs

- Production code and unit tests from the Implementer (paths in the brief).
- The threshold from the brief; default CRAP threshold is **30**.

## Outputs

- Refactored source meeting the CRAP threshold.
- Additional unit tests that kill mutants.
- A list of surviving mutants with a written justification for each (equivalent mutant, unreachable, or deliberately untested).

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Test suite (re-run after every change) | `rspec` / `minitest` | `bundle exec rspec` or `bundle exec rake test` | see `role-implementer` |
| Coverage | `simplecov` | run the suite with `require "simplecov"; SimpleCov.start` at the top of `spec_helper.rb`; read `coverage/.resultset.json` | `gem install simplecov` |
| Cyclomatic complexity per method | `rubocop` | `bundle exec rubocop --only Metrics/CyclomaticComplexity --format json` with `Metrics/CyclomaticComplexity: { Max: 1 }` in a temporary config, so every method reports its score as `[n/1]` | `gem install rubocop` |
| Complexity cross-check (optional) | `flog` | `bundle exec flog -g lib` | `gem install flog` |
| Mutation testing (verify flags against the installed `mutant` version; private code needs a commercial license) | `mutant` | `bundle exec mutant run --use rspec -- 'MyApp*'` (replace `MyApp*` with the namespace under test) | `gem install mutant mutant-rspec` |

### CRAP score

`CRAP(m) = complexity(m)^2 * (1 - coverage(m))^3 + complexity(m)`

where `complexity(m)` is the cyclomatic complexity of method `m` and `coverage(m)` is the fraction of its lines covered (0 to 1). Compute coverage per method as the covered share of the method's line range in `coverage/.resultset.json`. A method at or below the threshold passes. A method above it is refactored (extract method, replace conditional, remove duplication) or covered by additional tests, then re-measured. State the threshold and the final worst-method score in the report.

### Mutation testing

`mutant` changes operators (`+` to `-`, `>` to `<`, and similar) and expects the test suite to fail for each change. A mutant that survives marks behavior the tests do not pin down. For each survivor: add a unit test that kills it; or, if no test can distinguish it (equivalent mutant), record the justification. The pass condition is zero unexplained survivors. `mutant run` needs the integration gem as well (`mutant-rspec` for RSpec projects); without it mutant stops with "Unable to load integration mutant-rspec". Mutation runs are slow, so scope them to the files changed.

## Task-to-skill loading

| Task | Load |
|---|---|
| Symptom described, cause unknown; Zeitwerk errors; dead code; unfamiliar code | `${CLAUDE_PLUGIN_ROOT}/skills/analyse/SKILL.md` |
| A diagnosed smell needs a named transformation (Zeitwerk, bare rescue, thread-to-async, nested conditionals, frozen strings) | `${CLAUDE_PLUGIN_ROOT}/skills/refactor/SKILL.md` |
| Slow code, allocation pressure, "profile", "benchmark" | `${CLAUDE_PLUGIN_ROOT}/skills/perf/SKILL.md` |
| Evaluating the ruby-dev plugin itself (baseline eval, harness) | `${CLAUDE_PLUGIN_ROOT}/skills/evals/SKILL.md` |

**Performance rule.** Profile before optimizing (`stackprof`), benchmark before and after (`benchmark-ips`), and revert any optimization that gains less than about 10-20%. Never optimize on intuition.

## Report

Follows `${CLAUDE_PLUGIN_ROOT}/references/subagent-mandates.md`. `FINDINGS` states the threshold, the worst CRAP score before and after, and the mutation score with the count of justified survivors.
