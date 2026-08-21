---
name: evals
description: "Use when evaluating the ruby-dev plugin itself — establishing or extending a reproducible baseline, designing eval challenges with planted ground truth, building or running the ruby-dev-evals harness, scoring specialist output, checking rubyist gateway protocol compliance, calibrating an LLM judge, or turning eval findings into prompt fixes. Trigger on 'baseline eval', 'evaluate the plugin', 'eval harness', 'does the plugin beat bare', 'gateway compliance', 'regression test the prompts', 'ruby-dev-evals'."
---

# RubyDev Evals — Evaluating the Plugin Itself

## Overview

Every other skill in this plugin evaluates Ruby. This one evaluates *the plugin*.

`ruby-dev` is prompt-only: 15 agent files (`rubyist` gateway + 14 specialists) and 14 skill directories, no library code, no test suite. Its `AGENTS.md` says so outright — "validate changes by reading the Markdown for coherence." Reading for coherence is how a prompt acquires ten rules that nobody has ever exercised. This skill replaces that with measurement.

What gets measured is not the Markdown. It is whether the prompts **change what Claude Code produces** — on three separable axes:

1. **End-state quality** — does the artifact a session produced actually work and meet spec?
2. **Protocol compliance** — did `rubyist` follow its own dispatch protocol?
3. **Judged quality** — the subjective remainder. Reported, not gating, until calibrated.

The harness lives in a sibling repo, `~/WorkspaceV3/ruby-dev-evals`, as a standalone Ruby application. The plugin repo is **read-only** from this skill.

## When to Use

- Establishing a first baseline before changing any prompt
- Adding a suite or case to an existing baseline
- Re-running a baseline after a prompt edit, to check for regression
- Diagnosing which gateway rules actually hold at runtime
- Deciding whether a proposed prompt change is worth its tokens

**Don't use for:**
- Evaluating Ruby code a user wrote — that is `sift`
- Evaluating an LLM application's outputs — that is `genai` / `dspy-ruby` (`DSPy::Evals`)
- Editing plugin prompts. Findings go in a report; prompt edits are a separate session, with the baseline already in hand.

## Non-Negotiables

1. **Reproducibility outranks every other property.** Two machines, two days, same command, differences attributable and bounded. A number that cannot be reproduced is not a baseline.
2. **Never run against the working tree.** Check the plugin out at a pinned SHA into a temp dir, per run.
3. **Every case runs a `bare` arm.** Plugin not installed. Without that delta you have measured Claude, not the plugin.
4. **Deterministic before judged.** If the question can be answered by reading bytes, it is a script. A model call in the harness is a confession the check wasn't specified precisely enough.
5. **Ground truth is planted, never inferred.** No reference solution, no gem's behaviour, no judge deciding what the right answer was.
6. **Median and spread, never mean.** Default `--repeat 3`. Spread > 1.0 on a 5-point scale ⇒ flag `UNSTABLE`, do not quote the median.
7. **No rubric edits after seeing results.** If a rubric must change, the run ID changes with it and the old run is kept.
8. **`INVALID` is a result.** Harness errors are recorded and reported, never silently retried.

## Lifecycle

Six phases. Each emits a **required output format** — fill the slots; do not replace them with prose.

### Phase 1 — Design the challenge

A challenge earns its place by having ground truth, a genuine parallel seam (so the gateway's contract machinery is exercised), and coverage of ≥3 specialist skills.

```
CHALLENGE: <one sentence, as it will be given to the evaluated session>
GROUND TRUTH: <what is planted, and how it is verified without a model>
SEAM: <the parallel boundary this forces — which stages meet at which type>
SKILLS EXERCISED: <specialist skills expected to load>
CASE LADDER: <3–4 cases, simple → adversarial, one line each>
PRIMARY METRIC: <the single number this suite is about>
GATE: <threshold on that metric, decided before any run>
```

Do not proceed to Phase 2 until `GROUND TRUTH` names a mechanism, not an intention. See `references/challenge-design.md`.

### Phase 2 — Build the corpus

Generated once, committed, hashed, never regenerated at run time. Every document ships a `*.truth.json` sidecar with exact spans and expected retained facts, plus **near-miss decoys** — the things that must *not* be transformed. A corpus that cannot catch over-correction only measures half the failure surface.

See `references/fixture-design.md` for the truth schema and decoy patterns.

### Phase 3 — Build or extend the harness

Ruby, Zeitwerk, dry-rb, methods private by default, `# frozen_string_literal: true` — the plugin's own conventions. The harness being an artifact the plugin would approve of is a cheap standing check on those conventions.

See `references/harness-architecture.md` for the repo layout, class responsibilities, and gem roles.

### Phase 4 — Run

```
bin/eval run --suite <name> --plugin-sha <sha> --repeat 3 --arms bare,plugin
```

Before scoring anything, validate the manifest. Incomplete manifest ⇒ `INVALID`.

```
RUN MANIFEST
plugin_sha: <sha>          harness_sha: <sha>
model: <explicit id>       ruby: <version>
suite: <name>              cases: <ids>
arms: <bare|plugin|direct> repeat: <n>
corpus_hash: <sha256>      prompt_hashes: <case → sha256>
env_names_set: <names only, never values>
tracing: <langfuse trace ids | off>
```

### Phase 5 — Score

Four tiers, gates first. Full definitions in `references/scoring-tiers.md`; the gateway-specific rules in `references/gateway-protocol-checks.md`.

| Tier | What | Gating |
|---|---|---|
| 0 | Run validity — manifest, exit, artifacts, telemetry | pass/fail, `INVALID` |
| 1 | End-state — syntax, boot, tests, schema, primary metric, leakage | **yes** |
| 2 | Gateway protocol compliance, parsed from the transcript | reported per rule |
| 3 | Judge (`ruby_llm-tribunal`) — design, idiom, error posture | **no**, until calibrated |

Tier 1 scorers are pure functions of the artifact tree plus truth files. No LLM call inside Tier 1, ever.

### Phase 6 — Report, then convert findings into prompt work

```
FINDING: <what the data shows>
EVIDENCE: <case, arm, metric, spread — or transcript rule + compliance rate>
LAYER: <gateway prompt | specialist skill | reference file | not a prompt problem>
FIX SHAPE: <format slot | constraint | routing-table row | reference pointer>
COST: <tokens added/removed>
RE-RUN: <which cases must be re-run to confirm>
```

The `LAYER` and `FIX SHAPE` slots exist because of a specific failure this plugin has already had. From the gateway context audit:

> Restating a requirement is the cheapest available response to a miss, and the one least likely to change behavior… convert a requirement into a *slot in a required output format* rather than an *imperative in prose*.

A rule with <80% compliance is **in the wrong position, not insufficiently emphasized.** Move it into a format the model is already filling in. Do not add a sentence.

## Suite Registry

| Suite | Status | Challenge | Primary metric |
|---|---|---|---|
| `phi-parser` | round one | Document parser that scrubs PHI and emits schema-valid JSON | PHI recall (gate ≥ 0.95), decoy precision, zero leakage |
| `agent-flow` | round two, not started | CrewAI-style flow: sequential, hierarchical+manager, stateful flows, fan-out, router, config-driven crew | pattern presence via AST + working end state |
| `sfl-structure` | later, separate rubric | Metafunction manipulation — transitivity conversion, thematic progression, modality gradient | structural adherence via dependency parse |

Do not stub a suite before the one above it is green and calibrated.

## The Determinism Boundary

Two boundaries, and conflating them is the most likely way an eval goes wrong.

**Inside the harness** — everything is a script except Tier 3 judging. Notably, Tier 2 is a *regex over transcript events*, not a judgment: `CONTRACTS:`, `VERIFY:`, `CONTRACT:`, `PRIOR-ART:` are literal strings in a required format, which is exactly why the audit put them there.

**Inside the produced artifact** — a scored design dimension. Reaching for an LLM where a rule belongs is precisely the judgment a good skill prompt should suppress, so the `bare` vs `plugin` delta on it is informative:

| Stage | Should be | Failure signal |
|---|---|---|
| Format detection, file walking, streaming | deterministic | LLM call per document |
| Structured pattern extraction (IDs, dates, phones) | rule-based | model where a regex is 100% |
| Free-text entity recognition | NER or LLM — legitimately probabilistic | pure regex tanks recall on the adversarial case |
| Ambiguity resolution (decoys) | lexicon first, model as fallback | model-only ⇒ non-reproducible output |
| Transformation application | deterministic span replacement | regenerating prose can hallucinate content back in |
| Serialization + schema validation | deterministic, dry-schema | JSON that only usually validates |
| Logging and error paths | deterministic, leak-free by construction | this is where it leaks |

## Gem Roles

Do not improvise substitutes.

| Gem | Role |
|---|---|
| `ruby_llm` | provider-agnostic client for judge and harness-side LLM work |
| `ruby_llm-tribunal` | Tier 3 only. `Tribunal.test_case(input:, actual_output:, context:)` → `Tribunal.evaluate(tc, assertions)` |
| `ruby_llm-test` | stub LLM calls in the harness's **own** RSpec suite — harness tests run offline and free |
| `ruby_llm-top_secret` | wrap any judge call touching fixture content in `with_filtering`. Never expose it to the evaluated session; never let it define ground truth |
| `opentelemetry-instrumentation-ruby_llm` | traces → Langfuse. Optional: absent env vars ⇒ run proceeds, report notes tracing off. A failed export never fails a run |

## Common Pitfalls

1. **Tuning until the plugin wins.** The `bare` arm exists to be lost to. A loss is the most valuable result this harness can produce.
2. **Judging what could be parsed.** Every model call in Tier 1 is a reproducibility leak. Justify any harness-side LLM call in the comment that introduces it.
3. **Generating fixtures at run time.** The corpus is committed and hashed. The generator exists so it can be audited and regrown, not so it runs during evaluation.
4. **Reporting a mean.** The variance is the interesting signal; a mean is designed to hide it.
5. **Trusting an uncalibrated judge.** Run the three-point calibration set (known-good ≥4.5, known-bad <2.5, borderline 3.0–3.5) before the judge scores anything. If calibration fails, fix the rubric — never adjust results after.
6. **Single-pass pairwise comparison.** `bare` vs `plugin` must swap positions; disagreement across passes ⇒ TIE at confidence 0.5, logged as position bias.
7. **Believing a claim in a transcript.** "All tests pass" is a claim. Compare it against the tool calls. Claimed-but-unexecuted verification is its own named failure: `RELAYED_VERIFICATION`.
8. **Editing the plugin from an eval session.** Findings out, prompts untouched. Otherwise the baseline and the change share a session and neither is attributable.

## Verification Checklist

- [ ] Manifest complete — plugin SHA, harness SHA, model ID, ruby version, corpus hash, prompt hashes
- [ ] Plugin checked out at a pinned SHA, not read from the working tree
- [ ] `bare` arm ran for every case
- [ ] `--repeat` ≥ 3; median and spread both reported
- [ ] Tier 1 scorers contain zero LLM calls
- [ ] Scorers tested against a known-good **and** a deliberately-broken artifact tree before trusting them on real output
- [ ] Corpus committed, hashed, and generated from a recorded seed
- [ ] Decoys present and checked — over-correction is measured, not assumed absent
- [ ] Judge calibration set passed before any Tier 3 score is quoted
- [ ] Gateway rules below 80% compliance called out by name in the report
- [ ] Report leads with the manifest and closes with "what this run does not tell you"
- [ ] Plugin repo unmodified — `git status` clean in `~/WorkspaceV3/ruby-dev-plugin`

## References

- `references/challenge-design.md` — choosing a challenge, the case ladder, arms
- `references/fixture-design.md` — truth schema, planting, decoys, corpus hygiene
- `references/harness-architecture.md` — repo layout, class responsibilities, gem wiring, telemetry
- `references/scoring-tiers.md` — Tier 0–3 in full, metric selection, gates, judge calibration
- `references/gateway-protocol-checks.md` — the `rubyist` rules to parse, and what each one's failure means
- `references/reporting-and-iteration.md` — report format, delta tables, findings → prompt fixes
