# Task Flow Paths

How work enters, routes through, and exits the ruby-dev-plugin multi-agent system.

## Architecture

```
User Request
    │
    ▼
┌─────────────────────────────────────────────────┐
│              rubyist (Gateway)                   │
│  Plans dispatch route, delegates to specialists, │
│  compacts reports between stages.                │
│  NEVER writes .rb files itself.                  │
└──────────────────────┬──────────────────────────┘
                       │
        ┌──────────────┼──────────────────┐
        ▼              ▼                  ▼
   ┌─────────┐   ┌──────────┐      ┌──────────┐
   │ Build    │   │ Diagnose │      │ AI/RAG   │
   │ Cluster  │   │ Cluster  │      │ Cluster  │
   └─────────┘   └──────────┘      └──────────┘
        │              │                  │
        ▼              ▼                  ▼
   ┌──────────────────────────────────────────┐
   │              auditor (Gate)              │
   │  Independent quality check via SIFT.     │
   │  Runs at end of Standard-mode routes.    │
   └──────────────────────────────────────────┘
        │
        ▼
   User Report
```

## Dispatch Plan Format

Before spawning any subagent, `rubyist` emits a plan:

```
ROUTE: <one line — what is being built or fixed>
MODE: Lite | Standard
STAGES:
  1. <agent-name> — <what it does> — receives: <inputs> — returns: <expected artifact>
  2. <agent-name> — ...
GATE: <auditor | none, and why>
```

- **Lite** — self-contained script, ~50 lines, stdlib only. One specialist, no audit gate.
- **Standard** — multi-file, gem-dependent, or existing project. Full route through auditor.

## Mode Selection

| Condition | Mode |
|-----------|------|
| Single script, stdlib only, no project structure | Lite |
| Multi-file, gem-dependent, touches existing project | Standard |
| New project + domain build | Standard |
| Review of just-built code | Standard (auditor in fresh subagent) |

## Agent Routing Table

### Build & Structure

| Agent | Routes to when | Returns |
|-------|---------------|---------|
| `scaffolder` | "start project", "create gem", "scaffold", new application skeleton | Project structure, Gemfile, convention pass |
| `data-engineer` | CSV/JSON parsing, ETL, batch file processing, Sequel bulk ops | Stream-based transforms, DB operations |
| `multi-db` | Ohm (Redis) or Sequel (PostgreSQL/pgvector) model design, picking between stores, porting between ORMs | Model classes, schema, storage/retrieval patterns |
| `tui-builder` | Terminal UI — prompts, tables, progress bars, wizards (TTY toolkit) | Terminal interface code |
| `gui-builder` | "desktop app", "GUI", "native window", glimmer, libui | glimmer-dsl-libui MVP application |

### AI / RAG Cluster

`cognitive-architect` plans the architecture; it never writes components. Every AI/retrieval task starts here, then fans out to named builders.

| Agent | Owns | Returns |
|-------|------|---------|
| `cognitive-architect` | Which store, which retrieval strategy, which client, how stages compose | Component plan naming downstream builders — no code |
| `multi-db` | pgvector tables, Ohm/Sequel models, payload separation, scalar filters | Storage layer |
| `ruby-nlp` | Tokenization, segmentation, POS/dependency parsing, WordNet, fuzzy match, TF-IDF/BM25, topic modeling | Chunking, lexical retrieval, linguistic features |
| `ruby-llm` | `ruby_llm` chat, tool/function calling, streaming, embeddings, structured output, `acts_as_chat`, MCP client | Provider-facing integration code |
| `dspy-ruby` | Sorbet signatures, Predict/ChainOfThought/ReAct/CodeAct, `DSPy::Module`, Toolsets, `DSPy::Evals`, MIPROv2/GEPA optimization | Typed programs returning validated Ruby types |

### Diagnose, Document, Judge

| Agent | Routes to when | Returns |
|-------|---------------|---------|
| `debugger` | Bugs, Zeitwerk errors, dead code, "why is this happening" | Diagnosis with root cause — no code changes |
| `refactorer` | A diagnosed smell needs a named transformation applied | Applied pattern fix, syntax-verified |
| `optimizer` | "slow", "profile", "benchmark", GC/memory pressure | Measured wins only (≥10–20%); reverts the rest |
| `technical-writer` | "add docs", "YARD", "@param/@return" | YARD tags with type assertions and examples |
| `auditor` | Code review, PR audit, "is this production ready", SIFT | SIFT report with Toulmin evidence |

## Standard Route Shapes

Each route is a pipeline of specialist stages. Stages with no data dependency may run in parallel.

### Build

```
scaffolder → domain builder → technical-writer → auditor
```

Example: "Build a CLI task manager with a GUI"
```
scaffolder → gui-builder → technical-writer → auditor
```

### Fix (Diagnose + Refactor)

```
debugger → refactorer → auditor
```

The `debugger` produces a diagnosis (root cause, no code changes). The `refactorer` applies a named transformation pattern from the catalog. The `auditor` reviews independently.

### Speed Up (Profile + Optimize)

```
debugger → optimizer → auditor
```

The `debugger` localizes the hotspot. The `optimizer` profiles and applies measured wins only.

### RAG / Retrieval System

```
cognitive-architect (plan)
    → multi-db + ruby-nlp (parallel)
    → ruby-llm
    → dspy-ruby (if typed outputs needed)
    → technical-writer
    → auditor
```

### Review Only

```
auditor
```

### Document Only

```
technical-writer
```

## Disambiguation Rules

### Within the AI Cluster

| Ambiguity | Resolution |
|-----------|-----------|
| "RAG pipeline", "LLM agent", "semantic search" (system-level) | `cognitive-architect` for plan, then named builders |
| Named gem mentioned | Skip architect, go directly: `dspy` → `dspy-ruby`, `ruby_llm` → `ruby-llm`, `Ohm`/`Sequel` → `multi-db` |
| MCP server (building one) | `cognitive-architect` |
| MCP client (consuming one) | `ruby-llm` |
| Embeddings: generating | `ruby-llm` |
| Embeddings: storing/querying | `multi-db` |
| Chunking, BM25, TF-IDF | `ruby-nlp` (not `ruby-llm`) |
| `dspy-ruby` + retrieval in scope | `multi-db`/`ruby-nlp` retrieve first, then `dspy-ruby` reasons |

### Everywhere Else

| Ambiguity | Resolution |
|-----------|-----------|
| Symptom described, cause unknown | `debugger` first, always |
| "Slow" with no measurement | `debugger` to localize, then `optimizer` to profile |
| New project + domain build | `scaffolder`, then the domain agent |
| Review of just-built code | `auditor` in a fresh subagent (independent of builder assumptions) |
| CLI application | `scaffolder` → `tui-builder` |
| Desktop application | `scaffolder` → `gui-builder` |

## Agent-to-Agent Call Graph

Extracted from the codebase graph:

```
rubyist ──calls──► scaffolder
rubyist ──calls──► technical-writer
rubyist ──calls──► tui-builder

debugger ──calls──► refactorer
debugger ──calls──► optimizer
debugger ──calls──► rubyist

auditor ──calls──► rubyist
cognitive-architect ──calls──► rubyist
data-engineer ──calls──► rubyist
dspy-ruby ──calls──► rubyist
gui-builder ──calls──► rubyist
multi-db ──calls──► rubyist
ruby-llm ──calls──► rubyist
ruby-nlp ──calls──► rubyist
refactorer ──calls──► rubyist
```

`rubyist` is the central hub. Specialists call back to it; it never calls specialists directly in the graph — it dispatches via the `Task` tool in the runtime, which creates isolated subagent contexts.

## Specialist Report Format

Every specialist returns a compact structured report:

```
CHANGED: <file paths, or "none">
FINDINGS: <what you determined, 2-5 bullets>
UNRESOLVED: <what you could not do, and why — or "none">
NEXT: <what the next stage must know — or "none">
```

`rubyist` is the compaction boundary: it summarizes specialist output before passing it to the next stage. Briefs carry summaries, never full transcripts.

## Common Path Examples

### "Clean up my old Ruby project"

```
1. debugger — diagnose smells, dead code, Zeitwerk issues
2. refactorer — apply named patterns (zeitwerk_mismatch, missing_frozen_string_literal, etc.)
3. auditor — independent SIFT quality gate
```

### "Add a GUI to my CLI tool"

```
1. scaffolder — set up proper project structure if needed
2. gui-builder — glimmer-dsl-libui native desktop interface
3. technical-writer — document the new interface
4. auditor — independent review
```

### "Build a RAG system with typed outputs"

```
1. cognitive-architect — plan which store, retrieval strategy, client
2. multi-db + ruby-nlp — parallel: storage layer + text processing
3. ruby-llm — provider-facing chat/embeddings integration
4. dspy-ruby — typed LLM programs with validated output
5. technical-writer — document pipeline
6. auditor — SIFT review
```

### "This is slow"

```
1. debugger — localize the hotspot with measurement
2. optimizer — profile, apply ≥10-20% wins, revert the rest
3. auditor — verify the optimization didn't break correctness
```

## Lifecycle Constraints

1. **Diagnosis precedes change.** No `refactorer` or `optimizer` without a `debugger` finding or measurement.
2. **Architecture precedes AI implementation.** Retrieval/RAG/LLM tasks start at `cognitive-architect`.
3. **One specialist per dispatch.** Each gets a compact brief, not a transcript of prior stages.
4. **Isolated contexts.** Each subagent runs in its own context; they don't inherit the parent conversation.
5. **Audit gate.** Standard-mode routes end at `auditor`. Its verdict is reported verbatim, including failures.
