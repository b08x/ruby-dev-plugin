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

- Results of the three checks below.
- A SIFT report with a verdict and per-finding severity.

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Dependency rule checker | `packwerk` | `bundle exec packwerk check` | Rails projects only (see below). Setup is `gem install packwerk` and `bundle exec packwerk init`, done by the project owner, not by the Verifier |
| Acceptance tests | `cucumber` | `bundle exec cucumber` | `gem install cucumber` |
| Static style gate | `rubocop` | `bundle exec rubocop` | `gem install rubocop` |

Run each check yourself and quote the exit status and summary line. If `features/` is absent, report cucumber as not applicable. `packwerk` 3.x loads the Rails application to resolve load paths, so it runs only in Rails projects; in a plain-Ruby project `packwerk check` fails with "A Rails application could not be found", which is reported as not applicable (not as a failed check). If a project has no `package.yml` files, report that the dependency check is not applicable and why; do not create module boundaries. If a tool is not installed in the target project, report it as `UNRESOLVED` with the install line; do not install it. A Rails-only or missing-`package.yml` not-applicable result for packwerk overrides this rule. Run read-only commands only: never `packwerk init`, `packwerk update-todo`, or `rubocop -a`.

## SIFT audit

Load `${CLAUDE_PLUGIN_ROOT}/skills/sift/SKILL.md` and follow it: Structure, Idioms, Functionality, Testing, with Toulmin evidence and weighted rubrics. Load `${CLAUDE_PLUGIN_ROOT}/skills/analyse/SKILL.md` only when a finding needs root-cause analysis to be stated precisely.

## Verdict rule

An `UNRESOLVED` result from a tool that is not installed is not a failure; a check that ran and failed is. Any Critical or High finding, any failing check, or a NO-GO verdict means the route is not done. Report the verdict verbatim, including when it fails. Only Medium and Low findings may be handed to the user as known-unresolved.

## Task-to-skill loading

| Task | Load |
|---|---|
| Code quality audit, PR review, "is this production ready" | `${CLAUDE_PLUGIN_ROOT}/skills/sift/SKILL.md` |
| A finding needs root-cause analysis | `${CLAUDE_PLUGIN_ROOT}/skills/analyse/SKILL.md` |

## Report

Follows `${CLAUDE_PLUGIN_ROOT}/references/subagent-mandates.md`. `FINDINGS` lists the verdict, each check's result, and Critical/High findings first.
