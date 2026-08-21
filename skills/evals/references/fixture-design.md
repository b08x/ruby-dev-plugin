# Fixture Design

The corpus is the load-bearing part of the whole harness. A judge can be recalibrated; a corpus with wrong truth files silently corrupts every run made against it.

## Generated once, committed forever

```
bin/generate_fixtures --seed 20260819 --suite phi-parser
```

- The generator fills templated documents from a fixed entity pool using a constant seed.
- Run it **once**. Commit the output, the seed, and the generator.
- It exists so the corpus can be audited and regrown — not so it runs during evaluation.
- Regenerating with a different seed produces a different corpus, therefore a different `corpus_hash`, therefore a different baseline. Say so in the corpus README.

## Truth sidecars

Every document ships `<name>.truth.json`:

```json
{
  "doc_id": "p4-note-007",
  "source_sha256": "…",
  "phi_spans": [
    {"start": 41, "end": 54, "text": "Marcus Ellery", "category": "name"},
    {"start": 88, "end": 98, "text": "1962-04-11", "category": "dob"}
  ],
  "decoys": [
    {"start": 210, "end": 219, "text": "Lisinopril", "reason": "drug name reads as surname"},
    {"start": 402, "end": 411, "text": "SN-4471-B", "reason": "device serial reads as MRN"}
  ],
  "clinical_facts": [
    {"field": "chief_complaint", "value": "shortness of breath"},
    {"field": "medication", "value": "lisinopril 10mg daily"}
  ]
}
```

- `phi_spans` — must be removed. Drives **recall**.
- `decoys` — must survive. Drives **precision**; catches over-correction.
- `clinical_facts` — must still be present in the output. Catches the degenerate solution: scrub everything, emit `{}`, score perfect recall.

All three lists are required. A corpus with `phi_spans` alone can be gamed by a tool that deletes the document.

## Offsets are computed, not typed

Generate spans from the template substitution, not by a human counting characters. Then verify: a fixture test asserts that `doc[start...end] == text` for every span in every truth file. That test runs in CI and is the reason the corpus can be trusted.

## Planting rules

**Categories** (PHI suite, minimum): name, DOB, MRN, SSN, address, phone, email, date of service, provider name, facility name.

**Positions** — rung 4 must place entities where naive extraction misses them:

| Position | Why it's hard |
|---|---|
| Inside a CSV cell, with delimiters nearby | tokenization boundary |
| In a filename, not the content | most tools only read bodies |
| Inside a date *range* (`04/11/1962–04/18/1962`) | partial matching |
| Split across a line wrap | span reassembly |
| In a header or footer repeated on every page | dedup logic drops it |
| In an error message path (`/records/ellery_m/…`) | leaks via stderr, not output |

**Decoys** — at least three per rung-4 document, in both directions:

| Decoy | Looks like | Must survive because |
|---|---|---|
| Drug name that is also a surname (Lisinopril, Warfarin) | name | it's clinical content |
| Dosage that parses as a date (`10/325 mg`) | date | it's clinical content |
| Device serial shaped like an MRN | MRN | it's not patient-identifying |
| Facility-adjacent clinical term ("Mercy protocol") | facility | it's a protocol name |
| Ordinary word that is also a common surname (White, Young) | name | over-scrub destroys prose |

## Synthetic only

Nothing in the corpus derives from a real record — not paraphrased, not perturbed, not "anonymized." Entity pools are invented. The corpus README states this in the first paragraph, and the generator's entity pool file is the evidence.

This is a rule about the corpus, not a disclaimer. A "de-identified real note" is a re-identification risk and cannot be committed to a repo.

## Metrics computed from the corpus

| Metric | Formula | Gate role |
|---|---|---|
| Recall | matched `phi_spans` / total `phi_spans` | **primary gate** — false negatives are the costly error |
| Precision (decoy) | surviving `decoys` / total `decoys` | gate |
| F1 | harmonic mean | reported |
| Retention | `clinical_facts` present in output / total | gate — catches scrub-everything |
| Leakage | any `phi_spans.text` found in artifacts, logs, stderr, filenames | **hard fail on any hit** |

Span matching: exact by default. If a tool replaces with a placeholder of different length, match on absence of the original string in the corresponding output field rather than on offsets — record which matcher was used in the manifest, because the two are not comparable.

## Corpus hygiene

- `corpus_hash` = sha256 over the sorted list of `(path, content_sha256)` pairs. It goes in the manifest.
- Adding a document changes the hash and therefore the baseline. Add cases, not documents, once a baseline is published.
- Never `.gitignore` the corpus. Its size is the price of reproducibility.
