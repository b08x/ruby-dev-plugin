# Challenge Design

How to pick and shape what a suite asks the evaluated session to build.

## Admission criteria

A challenge is admissible only if all four hold:

1. **Ground truth exists without a model.** Something is planted, counted, parsed, or executed. "A judge will tell us if it's good" is not ground truth.
2. **It has a genuine parallel seam.** Two or more stages that meet at a type. Without one, the gateway's `CONTRACTS:` machinery is never exercised and Tier 2 measures nothing.
3. **It loads ≥3 specialist skills.** A single-skill challenge tests a skill, not the plugin.
4. **It fails informatively.** There is a way to be wrong that is not "didn't finish."

Reject a challenge that only a judge can score. Park it until a deterministic proxy is found, or run it as a Tier-3-only exploration explicitly labelled as not part of the baseline.

## The case ladder

Four cases, each adding exactly one axis of difficulty. Resist adding two.

| Rung | Purpose | Shape |
|---|---|---|
| 1 | Can it produce working, tested Ruby at all | Single input, no ambiguity |
| 2 | Breadth handling | Multiple inputs / formats / sources |
| 3 | Contract adherence | A supplied schema or interface the output must satisfy |
| 4 | Adversarial | Inputs designed to trigger both failure directions — miss and over-correct |

Rung 4 is where the plugin either earns its keep or doesn't. Rungs 1–3 mostly separate "works" from "doesn't."

## Arms

| Arm | Setup | Answers |
|---|---|---|
| `bare` | plugin not installed | Is the plugin worth installing? |
| `plugin` | installed, natural entry point (`rubyist` routes) | Headline number |
| `direct` | installed, prompt names the specialist skill directly | Is the *gateway* worth its tokens, separately from the specialists? |

`bare` is mandatory. `direct` is optional but is the only way to attribute a delta to routing rather than to specialist content — run it whenever a gateway change is on the table.

## Prompt authoring

The case prompt is given to the evaluated session verbatim and hashed into the manifest. Write it as a user would, not as a spec author would.

- **No plugin vocabulary.** Never name a skill, an agent, or a routing concept. If the prompt says "use the data-engineer skill," the eval measures obedience, not routing.
- **No hints at the ground truth.** Don't mention decoys, don't enumerate the categories being planted, don't say "be careful about X."
- **State the acceptance conditions a user would state.** "Must come with tests" is fair — a user would say that. "Must achieve 95% recall" is not; that's the gate, not the request.
- **One prompt per case, one file, never edited in place.** A changed prompt is a new case ID.

## Worked example — `phi-parser`

```
CHALLENGE: Build a Ruby CLI that ingests clinical documents in mixed formats,
           removes protected health information, and emits schema-valid JSON
           of the remaining clinical content.
GROUND TRUTH: PHI spans planted by the fixture generator, recorded as exact
           offsets in *.truth.json; recall/precision computed by string span
           comparison, plus a leakage grep across artifacts, logs and stderr.
SEAM: parser ↔ scrubber ↔ serializer — they meet at the document record type.
SKILLS EXERCISED: data-engineer, ruby-llm, scaffold, refactor, sift
CASE LADDER:
  p1-single-note    one plain-text clinical note
  p2-mixed-formats  .txt / .md / .csv in one directory
  p3-schema-contract  + a supplied JSON Schema the output must validate against
  p4-adversarial    + PHI in awkward positions and near-miss decoys
PRIMARY METRIC: PHI recall
GATE: recall ≥ 0.95, decoy precision ≥ 0.90, zero leakage hits
```

## Rounds two and three (not yet started)

**`agent-flow`** — a CrewAI-style orchestration challenge in Ruby. Ground truth is pattern *presence*, verified by AST inspection rather than a judge:

| Pattern | Deterministic check |
|---|---|
| Sequential process | ordered stage list, each consuming the prior's output type |
| Hierarchical + manager | a coordinating object that dispatches, distinct from the workers |
| Flows with state | state object threaded across steps, persisted between them |
| Fan-out parallel | concurrent entry points that join |
| Router / conditional | branch predicate selecting among ≥2 downstream paths |
| Config-driven team | crew composition read from YAML, not hardcoded |

**`sfl-structure`** — metafunction manipulation (transitivity conversion, thematic progression, modality gradient). Ground truth via dependency parse (process type shift, clause-initial position analysis), judge only for the appraisal-density dimension. Separate rubric, separate report — do not aggregate it with code suites.
