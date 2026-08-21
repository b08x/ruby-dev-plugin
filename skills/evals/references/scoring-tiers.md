# Scoring Tiers

Four tiers. Gates are deterministic; the judge is advisory until proven.

## Tier 0 — Run validity

Pass/fail, not scored. Checks: manifest complete, session exited cleanly, artifact tree present, token/cost telemetry captured.

Failure ⇒ `INVALID`. Excluded from aggregates, counted separately in the report, **never silently retried**. An `INVALID` rate above ~10% means the harness is broken, not the plugin.

## Tier 1 — End-state (the gate)

Run against the artifact tree the session produced, in a clean temp dir with only the produced `Gemfile`.

| Check | Method | Gating |
|---|---|---|
| Syntax | `ruby -c` on every `.rb` | hard fail |
| Boots | tool runs against one fixture, exit 0 | hard fail |
| Tests exist and pass | `bundle exec rspec` (or minitest) | hard fail |
| Output parses | every emitted document parses as JSON | hard fail |
| Schema conformance | validate against the supplied schema | hard fail (rungs 3–4) |
| Recall | matched planted spans / total | **primary gate** |
| Precision | surviving decoys / total decoys | gate |
| Retention | expected facts still present | gate |
| Leakage | grep artifacts, logs, stderr, filenames for planted strings | hard fail on any hit |
| Style | `rubocop` vs the plugin's stated conventions | scored, not gating |
| Determinism audit | classify each LLM call in the artifact by pipeline stage | scored, not gating |

**Scorers are pure functions** of (artifact tree, truth files). No LLM call in Tier 1, ever. If a check seems to need judgment, it is under-specified — either specify it or move it to Tier 3 and stop calling it a gate.

### Metric selection

Recall is the headline because false negatives are the costly error in a scrubbing task. Report precision and F1 alongside it, but gate on recall plus decoy precision so both failure directions are bound.

| Task shape | Primary | Secondary |
|---|---|---|
| Detection / extraction with planted truth | Recall, Precision, F1 | per-category breakdown |
| Pattern presence (flow suite) | binary per pattern, via AST | count of patterns present |
| Pass/fail artifact checks | pass rate | which check failed, by frequency |

Per-category recall matters more than the aggregate: 0.95 overall hiding 0.60 on `provider_name` is a specific, fixable finding.

## Tier 2 — Gateway protocol compliance

Parsed from the transcript, reported per rule rather than as a grade. See `gateway-protocol-checks.md` for the rule list and what each failure means.

Also captured per run, and reported next to quality rather than buried: total tokens, tool-call count, wall time, subagent spawn count and identities, which skills actually loaded. Token usage and tool-call count explain most performance variance; a quality win bought with 4× the tokens is a different result from a free one.

## Tier 3 — Judge (advisory)

`ruby_llm-tribunal`, for the subjective slice only: design quality, idiomatic Ruby, error-handling posture, documentation.

Rules:

- **Justification before score**, always. Score-first prompting measurably degrades reliability.
- **Cross-model**: judge model from a different family than the model under evaluation.
- **Position swap** for any `bare` vs `plugin` pairwise comparison. Disagreement across passes ⇒ TIE at confidence 0.5, recorded as position bias detected.
- **Anti-length-bias instruction** in the prompt, plus a logged length–score correlation across the suite. Above 0.4 ⇒ the judge is not trustworthy yet and the report must say so rather than quoting its scores.
- **One criterion = one measurable aspect.** Overloaded criteria are the main source of judge variance.

### Calibration — before any judge score is quoted

Three artifacts, hand-built, committed under `suites/<name>/calibration/`:

| Artifact | Expected |
|---|---|
| known-good (correct, idiomatic, tested) | ≥ 4.5 / 5 |
| known-bad (broken, untested, leaky) | < 2.5 / 5 |
| borderline (works, poor structure) | 3.0–3.5, with a nuanced justification |

Plus a **consistency run**: same artifact three times, variance < 0.5. And a **position-bias probe**: identical text in both slots must return TIE at confidence > 0.9.

Any calibration failure ⇒ fix the rubric and re-calibrate. Never adjust results after the fact.

## Aggregation

- Median across repeats, with min/max spread. Never a mean.
- Spread > 1.0 on a 5-point dimension ⇒ `UNSTABLE`; the median is not quotable as a baseline.
- `INVALID` runs excluded from aggregates and reported as their own count.
- Tier 1 and Tier 3 reported **side by side with their correlation**. If they disagree systematically, that is the most interesting output of the run — it means either the gate or the rubric is measuring the wrong thing.

## Gate arithmetic

A case passes when every hard-fail check passes and every gated metric meets its `suite.yml` threshold. A suite passes when every case passes in the `plugin` arm **and** the `plugin` arm is not worse than `bare` on the primary metric.

That second clause is the point of the whole exercise. Keep it.
