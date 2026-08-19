# Reporting and Iteration

`bin/eval report <run_id>` emits `report.md` and `scores.json`. The JSON is the record; the markdown is derived from it and never hand-edited.

## Report structure

The order is deliberate — manifest before numbers, caveats before conclusions.

### 1. Manifest block

Before any score. Plugin SHA, harness SHA, model ID, ruby version, corpus hash, suite, cases, arms, repeat count, date, tracing status. A reader who can't reproduce the run shouldn't be able to read the numbers first.

### 2. Results table

Case × arm × { gate result, primary metric, secondary metrics, tokens, tool calls, wall time }. Median with spread in parentheses:

```
| case            | arm    | gate | recall        | precision     | tokens        | tools |
|-----------------|--------|------|---------------|---------------|---------------|-------|
| p4-adversarial  | bare   | FAIL | 0.71 (.66–.78)| 0.94 (.91–.96)| 41k (38–44k)  | 27    |
| p4-adversarial  | plugin | PASS | 0.96 (.95–.97)| 0.92 (.90–.94)| 118k (104–131k)| 63   |
```

### 3. Delta table — plugin vs bare

Per case, per metric, with spreads. **This is the answer to "is the plugin worth installing,"** and it is the only table most readers need. Mark any delta whose spread overlaps zero as `INCONCLUSIVE` rather than reporting a direction.

Report the token cost of the delta in the same table. A recall gain of 0.25 for 3× the tokens is a real result, and a different one from a free gain.

### 4. Gateway protocol compliance

Per-rule table from Tier 2, with rules below 80% called out by name.

### 5. Judge scores

With confidence, position-consistency rate, and length–score correlation stated alongside — not in a footnote. If calibration or the length-correlation check failed, this section says so *instead of* reporting scores.

### 6. Tier 1 ↔ Tier 3 correlation

One number and one sentence. Systematic disagreement is the most interesting output a run can produce: it means either the gate or the rubric measures the wrong thing.

### 7. "What this run does not tell you"

Mandatory, and written specifically for this run. Small-n. One challenge family. One model. One day's provider behaviour. Whatever the corpus doesn't contain. A report without this section overstates itself by construction.

## Findings → prompt work

The eval session does not edit prompts. It emits findings in this shape, and a later session — holding the baseline — does the editing.

```
FINDING: <what the data shows>
EVIDENCE: <case, arm, metric, spread — or rule ID + compliance rate + n>
LAYER: <gateway prompt | specialist skill | reference file | corpus | harness | not a prompt problem>
FIX SHAPE: <format slot | constraint | routing-table row | reference pointer | none>
COST: <tokens added / removed>
RE-RUN: <cases that must be re-run to confirm>
```

`LAYER` is the field that prevents the most common mistake. A missed concern is not automatically a gateway problem: it may belong in a specialist's SKILL.md, in a `references/` file loaded on demand, or in the corpus (a decoy that was never planted can't be missed). Assigning every failure to the gateway is how a 3.2k-token routing prompt becomes a 6k-token one that routes no better.

`FIX SHAPE` enforces the audit's central lesson: prefer a slot in a required output format over an imperative in prose. If the fix shape is "add a sentence," it is probably the wrong fix.

## The iteration loop

1. **Baseline.** Run, record `run_id`, don't touch anything.
2. **One change.** A single prompt edit, addressing one finding. Batched edits make the next delta unattributable.
3. **Re-run the `RE-RUN` set**, plus enough of the rest to catch regression. Same corpus, same model, same repeat count.
4. **Compare.** Did the target rule's compliance rise? Did any other rule or metric fall?
5. **Check the token cost.** A rule fixed by adding 800 tokens to the gateway has to be worth 800 tokens on every route thereafter.
6. **Keep or revert.** Both outcomes are recorded; a reverted change with its evidence is more useful to the next session than an undocumented improvement.

Regression threshold: any gated metric dropping more than the observed spread of the baseline, or any protocol rule dropping >10 points, is a regression and blocks the change.

## Things that invalidate a baseline

Any of these means a new `run_id`, and the old baseline is retained rather than overwritten:

- Rubric or gate threshold changed
- Corpus changed (any document added, removed, or edited)
- Case prompt changed
- Model or model version changed
- Harness scorer logic changed in a way that affects a score

Keeping the old baseline matters more than it seems. The most useful artifact this harness produces over time is not a single number — it is the series, with the reason for each break in it recorded.
