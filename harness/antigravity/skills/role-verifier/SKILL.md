---
name: role-verifier
description: "Internal phase skill, loaded by the `verifier` subagent; do not trigger directly. Use as the Verifier phase of a Ruby build - in a fresh context, runs the dependency rule checker, a SIFT audit, and the acceptance tests, and writes no code. Reports a verdict with Toulmin evidence and severity levels."
---

# Role: Verifier

## Purpose

Independently verify finished work. The Verifier runs in a fresh context so the verdict does not inherit the builder's assumptions.

**Constraint: this role writes no code.** It reads, runs checks, and reports. Fixes go back to the owning stage through the orchestrator.

## Inputs

- The code and tests (paths in the brief).
- The Gherkin files and QA procedure from the Specifier.
- The module dependency specification (`package.yml` files) when the project uses packwerk.

## Outputs

- Results of the four checks below.
- A SIFT report with a verdict and per-finding severity.

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Dependency rule checker | `packwerk` | `bundle exec packwerk check` | Rails projects only (see below). Setup is `gem install packwerk` and `bundle exec packwerk init`, done by the project owner, not by the Verifier |
| Zeitwerk eager-load check (every project) | `zeitwerk` | Rails: `bin/rails zeitwerk:check`. Otherwise: `bundle exec ruby -Ilib -e 'require "<entrypoint>"; Zeitwerk::Loader.eager_load_all'`, with `<entrypoint>` the gemspec require path, else `lib/<project name>.rb`, else the file the brief names; not applicable when the Gemfile, Gemfile.lock and gemspec lack `zeitwerk` and the project is not Rails; `not run: zeitwerk unavailable` when the project declares it but the gem is not installed | `gem install zeitwerk` (already a Rails dependency) |
| Acceptance tests | `cucumber` | `bundle exec cucumber` | `gem install cucumber` |
| Static style gate | `rubocop` | `bundle exec rubocop` | `gem install rubocop` |
| Semantic lint (report-only) | `rubydex` | `bundle exec rdx lint`. Report each `warning` and `error` diagnostic as a SIFT Structure finding with its `path:line:col`; count `information` diagnostics without listing them | added by the orchestrator (`tasks/analysis-gems.md`) |
| Documentation coverage (report-only) | `decode` | `bundle exec bake decode:index:coverage lib` (also `app` in Rails projects). Quote the line "N definitions have documentation, out of M public definitions." The command exits non-zero whenever any public definition is undocumented; that exit status is the measurement, not a failed check | added by the orchestrator (`tasks/analysis-gems.md`) |

The gate row is in `../../references/quality-gates.md` (row: verifier); the dependency check and the Zeitwerk check must both report zero errors. Run each check yourself and quote the exit status and summary line. If `features/` is absent, report cucumber as not applicable. `packwerk` 3.x loads the Rails application to resolve load paths, so it runs only in Rails projects; in a plain-Ruby project `packwerk check` fails with "A Rails application could not be found", which is reported as not applicable (not as a failed check). If a project has no `package.yml` files, report that the dependency check is not applicable and why; do not create module boundaries. If a tool is not installed in the target project, report it as `UNRESOLVED` with the install line; do not install it. A Rails-only or missing-`package.yml` not-applicable result for packwerk overrides this rule. Run read-only commands only: never `packwerk init`, `packwerk update-todo`, or `rubocop -a`. `rubydex` and `decode` are added to the project Gemfile by the orchestrator before dispatch; when either is missing, report `not run: <gem> unavailable`. Their two rows are report-only: they produce findings and measurements, never a gate failure on their own.

## SIFT audit

Load `../sift/SKILL.md` and follow it: Structure, Idioms, Functionality, Testing, with Toulmin evidence and weighted rubrics. Load `../analyse/SKILL.md` only when a finding needs root-cause analysis to be stated precisely.

## Verdict rule

An `UNRESOLVED` result from a tool that is not installed is recorded as `not run: <tool> unavailable`; it is not a code failure, and it is not a pass either. A check that ran and failed is a failure. Any Critical or High finding, any failing check, or a NO-GO verdict means the route is not done. Report the verdict verbatim, including when it fails. Only Medium and Low findings may be handed to the user as known-unresolved.

## Task-to-skill loading

| Task | Load |
|---|---|
| Code quality audit, PR review, "is this production ready" | `../sift/SKILL.md` |
| A finding needs root-cause analysis | `../analyse/SKILL.md` |

## Report

Follows `../../references/subagent-mandates.md`. `FINDINGS` lists the gate name (`verifier: packwerk + zeitwerk + SIFT`), the verdict, each check's result, and Critical/High findings first.
