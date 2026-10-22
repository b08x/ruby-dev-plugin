---
name: role-hardener
description: "Internal phase skill, loaded by the `hardener` subagent; do not trigger directly. Use as the Hardener phase of a Ruby build - runs mutation testing and adds tests until surviving mutants are killed or explicitly justified, and scans dependencies and Rails code for vulnerabilities."
---

# Role: Hardener

## Purpose

Close test gaps and security gaps in code that already passes its tests and meets the cleaner gate.

1. **Mutation testing.** Run `mutant`, and add unit tests until surviving mutants are killed or explicitly justified.
2. **Security scanning.** Run `bundler-audit` on every project and `brakeman` on Rails projects, and report findings.

Restructuring production code belongs to the `cleaner` phase. Do not change production code here; add or change tests only. If a vulnerable dependency or a Brakeman warning needs a production change, report it under `FINDINGS`; the orchestrator routes it.

## Inputs

- Production code and unit tests after the cleaner phase (paths in the brief).
- The gate row in `../../references/quality-gates.md` (row: hardener).

## Outputs

- Additional unit tests that kill mutants.
- A list of surviving mutants with a written justification for each (equivalent mutant, unreachable, or deliberately untested).
- The `bundler-audit` and `brakeman` results.

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Test suite (re-run after every change) | `rspec` / `minitest` | `bundle exec rspec` or `bundle exec rake test` | see `role-implementer` |
| Mutation testing (verify flags against the installed `mutant` version; private code needs a commercial license) | `mutant` | `bundle exec mutant run --use rspec -- 'MyApp*'` (replace `MyApp*` with the namespace under test) | `gem install mutant mutant-rspec` |
| Dependency vulnerabilities | `bundler-audit` | `bundle exec bundler-audit check --update` | `gem install bundler-audit` |
| Rails static security analysis (Rails projects only) | `brakeman` | `bundle exec brakeman -q --no-pager` | `gem install brakeman` |

### Mutation testing

`mutant` changes operators (`+` to `-`, `>` to `<`, and similar) and expects the test suite to fail for each change. A mutant that survives marks behavior the tests do not pin down. For each survivor: add a unit test that kills it; or, if no test can distinguish it (equivalent mutant), record the justification in `FINDINGS`. The pass condition is zero unexplained survivors. `mutant run` needs the integration gem as well (`mutant-rspec` for RSpec projects); without it mutant stops with "Unable to load integration mutant-rspec". Mutation runs are slow, so scope them to the files changed.

### Security scanning

The gate requires zero high or critical findings from `bundler-audit` and `brakeman`. When a tool is not installed, report `not run: <tool> unavailable`; do not claim a pass. Skip `brakeman` for non-Rails projects and say so.

## Report

Follows `../../references/subagent-mandates.md`. `FINDINGS` states the gate name (`hardener: mutation + audit`), the mutation score with the count of justified survivors, and the `bundler-audit` and `brakeman` counts or `not run` entries.
