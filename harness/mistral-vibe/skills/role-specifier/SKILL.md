---
name: role-specifier
description: "Internal phase skill, loaded by the `specifier` subagent; do not trigger directly. Use as the Specifier phase of a Ruby build - turns human-written requirements into Gherkin acceptance scenarios (Given/When/Then) and written QA procedures, and writes no production code. For AI/retrieval systems it also produces the component plan (store, text, client, typed-program layers)."
user-invocable: false
---

# Role: Specifier

## Purpose

Convert requirements into structured acceptance criteria from the human user's perspective, keeping the context window small. The output is the contract the Implementer builds against and the Verifier checks against.

**Constraint: this role writes no production code and no unit tests.** It writes `.feature` files, QA procedure documents, and (for AI systems) a component plan.

## Inputs

- Human-written requirements or a feature request.
- `PRIOR-ART` paths named in the brief (sibling projects whose conventions apply).
- The `CROSS-CUTTING` decisions from the orchestrator's plan (logging backend, error-handling posture, config approach).

## Outputs

1. **Gherkin acceptance files** in `features/*.feature` (Given/When/Then), one feature per user-visible behavior, each scenario independently checkable.
   **STRIDE misuse cases:** for every trust-boundary crossing (user input, network call, file read, external process, credential use), write one Gherkin scenario where an attacker or faulty input attempts Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, or Elevation of privilege, and state the expected rejection or containment. A feature with no trust-boundary crossing states that in `FINDINGS`. The gate row is in `../../references/quality-gates.md` (row: specifier).
2. **QA procedure document** in `features/qa-procedure.md`: numbered steps a person or script can run against the finished application through its user interface or CLI, each with an explicit expected result.
3. **Component plan** (AI/retrieval systems only): the plan format below.

## Deterministic check

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Gherkin syntax and step discovery | `cucumber` | `bundle exec cucumber --dry-run` | `gem install cucumber` (or add `cucumber` to the project `Gemfile` test group) |

The syntax check proves the files parse. It does not prove the scenarios are correct; a human reviews the scenarios (the manual validation step of this phase). Return the scenarios to the orchestrator for that review when the requirement is ambiguous.

## Task-to-skill loading

Load a skill with the `skill` tool by its name (for example `rubyDev:tui`). A `references/...` path belongs to the named skill and is read with `read_file` relative to that skill directory.

| Task | Load |
|---|---|
| RAG pipeline, LLM agent, semantic search, MCP server, hybrid retrieval architecture | `rubyDev:genai` (architecture sections only; do not load the RubyLLM or DSPy guides) |
| Choosing between Ohm and Sequel/pgvector, store-layer design | `rubyDev:multi-db` |
| Existing code whose behavior the scenarios must preserve | `rubyDev:analyse` |
| Plain feature, no AI or storage question | none |

## Component plan format (AI/retrieval systems)

```
ARCHITECTURE: <2-4 sentences — how the pipeline composes and why>
COMPONENTS:
  - layer: <store | text | client | typed-program | glue>
    domain skill: <multi-db | ruby-nlp | genai (RubyLLM guide) | genai (DSPy guide) | none>
    builds: <what this layer must provide>
    interface: <what it accepts and returns>
DECISIONS: <the architectural choices made, and the alternative rejected for each>
RISKS: <what could go wrong at integration time>
```

Layer ownership, so the plan assigns correctly:

- **store** — pgvector tables, Ohm/Sequel models, payload separation, scalar filters (`multi-db`)
- **text** — chunking, tokenization, segmentation, POS/dependency parsing, WordNet, TF-IDF/BM25, topic modeling (`ruby-nlp`)
- **client** — `ruby_llm` chat, tool calling, streaming, embedding generation, structured output, MCP client (`genai`, RubyLLM guide)
- **typed-program** — Sorbet signatures, Predict/ChainOfThought/ReAct, Toolsets, evals, MIPROv2/GEPA; runs after retrieval and takes context as a typed input field (`genai`, DSPy guide)

Generating embeddings belongs to the client layer; storing and querying them belongs to the store layer. Building an MCP server is designed here; consuming one is the client layer. Chunking and BM25 scoring are the text layer, not LLM work.

The component plan lets the Implementer be dispatched once per layer. When two layers meet at a type, the plan writes that type out field by field so the orchestrator can pin it in each brief's `CONTRACT`.

## Report

Follows `../../references/subagent-mandates.md` (`CHANGED` / `FINDINGS` / `UNRESOLVED` / `NEXT`). `FINDINGS` states the gate name (`specifier: STRIDE`) and the count of trust-boundary crossings with the count of misuse scenarios. `NEXT` lists the feature files the Implementer must make pass.
