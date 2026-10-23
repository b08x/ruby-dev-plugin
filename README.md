# ruby-dev

**A task-driven Claude plugin routing Ruby work through 1 orchestrator (`rubyist`) and 5 phase subagents — specifier, implementer, cleaner, hardener, verifier — that load domain skills on demand.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugin Version](https://img.shields.io/badge/version-5.0.1-green.svg)](.claude-plugin/plugin.json)
[![Claude Plugin](https://img.shields.io/badge/Claude-Plugin-purple.svg)](.claude-plugin/plugin.json)

## Features

- **Phase Orchestration** — The `rubyist` agent plans a dispatch route and delegates each phase (specify, implement, clean/harden, verify) to a subagent in isolated context, with deterministic checks (cucumber, rspec/minitest, CRAP score, mutant, packwerk) at each phase
- **Project Scaffolding** — rubysmith/gemsmith flag presets by archetype (CLI, gem, web service, OSS) with convention hardening
- **Data Pipelines** — Stream-based CSV/JSON parsing, ETL workflows, and Sequel bulk operations
- **Multi-Database Modeling** — Ohm (Redis) and Sequel (PostgreSQL/pgvector) design, ORM porting, dual-database retrieval patterns
- **GenAI, RAG, and LLM clients (`genai`)** — Retrieval pipeline architecture, LLM agents, MCP servers, pgvector integration; the RubyLLM client (multi-provider chat, tool calling, streaming, embeddings, structured output); typed dspy.rb programs (Sorbet-typed signatures, Predict/ChainOfThought/ReAct/CodeAct, Toolsets, `DSPy::Evals`, MIPROv2 & GEPA)
- **Classical NLP** — Tokenization, POS tagging, dependency parsing, WordNet lookup, TF-IDF/BM25 ranking, topic modeling
- **Terminal UIs** — 21 TTY toolkit gems: prompts, tables, progress bars, spinners, pagers, trees, and rich CLI output
- **Desktop GUIs** — Native cross-platform windows with glimmer-dsl-libui and data-bound MVP architecture
- **Diagnostics** — Gemba Walk, Muda Analysis, Root-Cause Tracing, and Five Whys for systematic debugging
- **Surgical Refactoring** — Named pattern catalog (Zeitwerk, async, frozen strings, resilience) with before/after transforms
- **Performance Optimization** — Profile-Benchmark-Optimize cycle with stackprof and benchmark-ips; keeps only measured wins
- **YARD Documentation** — AST-informed type inference generating @param, @return, @example, and @raise tags
- **SIFT Quality Audits** — Structure, Idioms, Functionality, Testing assessment with Toulmin evidence framework

## Architecture

The plugin follows an **orchestrator + phase subagent** pattern. `rubyist` is an orchestrator *agent*, not a skill — it runs in its own context window, so the routing logic and the subagents' instructions never accumulate in one place. It writes no Ruby and never loads a role or domain `SKILL.md`. Each phase subagent loads its own role skill, which names the domain skill to load for each kind of task. Each domain skill also remains directly invocable when a task is single-concern.

```
                 ┌──────────────────────────┐
                 │   rubyist (orchestrator) │
                 │  survey → plan → dispatch│
                 │  → compact → synthesize  │
                 └────────────┬─────────────┘
     ┌────────────┬───────────┴──┬───────────────┬──────────────┬────────────┐
┌────▼─────┐  ┌───▼───────┐  ┌───▼─────┐  ┌──────▼─────┐  ┌─────▼────┐
│specifier │→ │implementer│→ │ cleaner │→ │  hardener  │→ │ verifier │
│ Gherkin, │  │ tests +   │  │ CRAP,   │  │ mutant,    │  │ packwerk,│
│ STRIDE,  │  │ code,     │  │ CC      │  │ bundler-   │  │ Zeitwerk,│
│ QA proc. │  │ gitleaks  │  │         │  │ audit,     │  │ SIFT,    │
│ (no code)│  │           │  │         │  │ brakeman   │  │ cucumber │
└──────────┘  └─────┬─────┘  └─────────┘  └────────────┘  └──────────┘
                    │ loads on demand
   scaffold · data-engineer · multi-db · tui · gui · ruby-nlp · genai · yardoc
```

| Phase subagent | Role skill | Deterministic check | Writes code |
|---|---|---|---|
| `specifier` | `role-specifier` | `bundle exec cucumber --dry-run`, STRIDE misuse scenarios present | no |
| `implementer` | `role-implementer` | `bundle exec rspec` or `rake test`, `bundle exec cucumber`, `gitleaks` | yes |
| `cleaner` | `role-cleaner` | CRAP score and CC (simplecov + rubocop complexity) | yes |
| `hardener` | `role-hardener` | `bundle exec mutant run`, `bundle exec bundler-audit check`, `bundle exec brakeman` (Rails only) | tests only |
| `verifier` | `role-verifier` | `bundle exec packwerk check` (Rails projects with `package.yml`; otherwise reported not applicable), Zeitwerk eager-load check, `bundle exec cucumber`, `bundle exec rubocop`, SIFT audit | no |

### Execution Pipeline

1. **Survey** — `rubyist` reads only enough to route. Classifies Lite Mode (scripts < 50 lines, stdlib only) or Standard Mode (multi-file, gem-dependent)
2. **Plan** — A dispatch plan is emitted before any subagent is spawned: which subagents, in what order, what each receives and returns
3. **Dispatch** — Each stage runs as a phase subagent in isolated context, receiving a compact brief (`TASK` / `PATHS` / `CONSTRAINTS` / `UPSTREAM` / `RETURN`)
4. **Report** — Every subagent returns a structured `CHANGED` / `FINDINGS` / `UNRESOLVED` / `NEXT` block. `rubyist` is the compaction boundary: briefs carry summaries, never transcripts
5. **Gate** — After every stage the orchestrator runs a scope check against a pre-dispatch baseline and the stage's gate from [`references/quality-gates.md`](references/quality-gates.md); a blocking failure rolls back to the named phase (at most 2 rollbacks per gate, then it asks you). The route pauses after the `specifier` for your approval unless you pass `--no-checkpoint`. `/ruby-gate <phase> [--base <ref>]` runs one gate and the scope check on its own
6. **Verify** — SIFT quality gate by `verifier`, in a fresh context so the audit is independent of the builder's assumptions
7. **Synthesize** — `rubyist` reports what changed, the verifier verdict, and anything unresolved

Non-stdlib gem APIs are verified via Context7 MCP or DeepWiki at the point of use, inside whichever subagent writes the code.

Where the workflow matrix, the SIFT protocol, and the diagnostic methods came from is documented in [Sources & Influences](#sources--influences).

## Installation

This is a Claude plugin. Install by cloning into your Claude skills directory or adding via the plugin registry.

<details>
<summary><strong>Manual Install (Recommended)</strong></summary>

```bash
# Clone into your Claude skills directory
git clone https://github.com/syncopated-context/ruby-dev-plugin.git ~/.claude/plugins/ruby-dev-plugin

# Or symlink from an existing checkout
ln -s /path/to/ruby-dev-plugin ~/.claude/plugins/ruby-dev-plugin
```

</details>

<details>
<summary><strong>Development / Local Testing</strong></summary>

```bash
# Clone the repo
git clone https://github.com/syncopated-context/ruby-dev-plugin.git
cd ruby-dev-plugin

# No build step required — pure Markdown plugin
# Validate structure by checking plugin.json
cat .claude-plugin/plugin.json
```

</details>

## Usage

### Orchestrator Entry Point

The `rubyist` agent is the primary entry point. Run it as the session agent (`claude --agent ruby-dev:rubyist`) or use the `/ruby-development` command; a subagent cannot spawn subagents. Use it for any task spanning more than one concern, or when it is unclear which phase applies.

```
Use the rubyist agent to scaffold a new CLI application with TUI prompts
```

```
Use the rubyist agent to build a RAG pipeline with pgvector and RubyLLM
```

### Direct Subagent Invocation

Each phase subagent can be invoked directly when the task is well-scoped:

```
Use the implementer agent to create an interactive table with tty-table
```

```
Use the verifier agent to run a SIFT quality audit on lib/my_app.rb
```

```
Use the cleaner agent to profile and reduce allocations in the hot path
```

### Skill Reference

Shared conventions live in `references/` at the plugin root (dry-rb, OOD, logging, env, pry, scaffolding) and are loaded by skills and agents alike.

| Skill | Purpose | Reference Files |
|-------|---------|-----------------|
| `scaffold` | Project scaffolding with rubysmith/gemsmith | 1 (flag presets) |
| `data-engineer` | CSV/JSON parsing, ETL pipelines | — |
| `multi-db` | Ohm/Sequel modeling, dual-database patterns | 2 (ORM idioms, SFL case study) |
| `genai` | RAG pipelines, LLM agents, MCP servers; RubyLLM client; typed dspy.rb programs | 2 + RubyLLM guide + DSPy guide with API snapshots |
| `ruby-nlp` | Tokenization, POS tagging, TF-IDF, BM25 | 1 (gem catalog) |
| `tui` | Terminal UIs with TTY toolkit | 21 (one per tty-* gem) |
| `gui` | Desktop GUIs with glimmer-dsl-libui | 4 (area, controls, custom, data-binding) |
| `analyse` | Debugging: Gemba Walk, Muda, Five Whys | 2 (types, examples) |
| `refactor` | Named refactoring pattern catalog | 1 (pattern definitions) |
| `perf` | Profiling, benchmarking, allocation reduction | 1 (optimization catalog) |
| `yardoc` | YARD documentation generation | 6 (patterns, types, errors, logging, dry-struct, Context7) |
| `evals` | Evaluation harness for the plugin itself | 6 (challenge design, fixtures, protocol checks, harness, scoring, reporting) |
| `sift` | SIFT quality audits with Toulmin evidence | 2 (assessment types, examples) |

### Agent Registry

`rubyist` has no skill of its own and exists purely to route. Each phase subagent is a thin wrapper that loads its role skill and the shared mandates in `references/subagent-mandates.md`. Prefer agents whenever isolated context is beneficial (audits that should judge code independently, long diagnostic passes, or any multi-stage build).

| Agent | Role | Loads |
|-------|------|-------|
| `rubyist` | Orchestrator | none (dispatches only the five below) |
| `specifier` | Gherkin acceptance scenarios, QA procedures, component plans | `role-specifier` → `genai` (architecture), `multi-db`, `analyse` |
| `implementer` | Unit tests and production code | `role-implementer` → `scaffold`, `data-engineer`, `multi-db`, `tui`, `gui`, `ruby-nlp`, `genai`, `yardoc` |
| `cleaner` | Diagnose, refactor to a CRAP threshold | `role-cleaner` → `analyse`, `refactor`, `perf`, `evals` |
| `hardener` | Mutation-test, `bundler-audit`, `brakeman` | `role-hardener` |
| `verifier` | Dependency rules, SIFT audit, acceptance tests; no code | `role-verifier` → `sift`, `analyse` |

## Code Conventions

When this plugin generates Ruby code, it enforces:

- `# frozen_string_literal: true` on line 1 of every `.rb` file
- Zeitwerk-compliant directory and file naming
- `dry-rb` ecosystem for type safety (`dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`)
- Methods default to `private`; promoted to `public` only for stable interfaces
- Undeclared parameters forwarded with `...` (`def foo(...) = bar(...)`)
- Non-stdlib gem APIs verified via Context7 MCP or DeepWiki at the point of use — never assumed from memory

## Sources & Influences

This plugin is assembled work. Its skeleton — the pipeline, the audit protocol, the diagnostic discipline — was extracted and adapted from named sources rather than invented, and the assembly deserves its credit.

### The workflow matrix — from an interview with Robert C. Martin

The plugin's spine is the fixed phase matrix — `specifier` → `implementer` → `cleaner` → `hardener` → `verifier`, each phase doing one kind of work and owning one deterministic check — which was extracted from [an interview with Robert C. Martin](https://www.youtube.com/watch?v=zcLPGC-tvgk). What survived the extraction is the *shape*: a route through small, single-purpose stages, gated before handoff, in a fixed order with explicit skip rules — rather than one agent improvising a fresh approach per task. What the plugin added is the Ruby-specific machinery at each stop: a `cucumber --dry-run` on the spec, a CRAP threshold after refactoring, `mutant` and `bundler-audit` for hardening, and a SIFT audit in a fresh context at the end — plus the invariant that the orchestrator routes but never writes Ruby. The matrix as shipped lives in the phase sequence table in [`agents/rubyist.md`](agents/rubyist.md), with the routing and skip rules formalized in [`tasks/step-1-survey-plan.md`](tasks/step-1-survey-plan.md).

### SIFT — adapted from the SIFT Toolbox

The [`sift`](skills/sift/SKILL.md) skill's quality protocol is an adaptation of [the SIFT Toolbox](https://checkplease.neocities.org/sift-toolbox/) from the Check, Please! web-literacy course, where SIFT is a four-move method for evaluating sources: Stop; Investigate the source; Find better coverage; Trace claims to their original context. The plugin keeps the scaffold — a compact four-part lens a reviewer can hold in mind — and re-expands the acronym for code: **S**tructure, **I**dioms, **F**unctionality, **T**esting. It also keeps the insistence that evaluation is evidence work: every finding must arrive as a Toulmin argument — claim, data, warrant, backing, qualifier, rebuttal — before it counts. The dimension weights, score bands, and the four report modes (Full, System Design, Tech Advisory, Backlog) are this plugin's own additions.

### Structured diagnostic analysis — adapted from context-engineering-kit

The [`analyse`](skills/analyse/SKILL.md) skill's core mandate — understand before acting, never refactor without diagnosis — was adapted from [Neo Lab's context-engineering-kit](https://github.com/NeoLabHQ/context-engineering-kit). What the plugin took is the structure: a method-selection matrix that routes each problem type to exactly one diagnostic method, and findings keyed for handoff (`muda:inventory`, `root-cause:zeitwerk`) so the fixing phase consumes structured findings rather than prose. The diagnostic vocabulary is older, and the skill names it as such: Gemba Walk, Muda Analysis, Root-Cause Tracing, and Five Whys are Kaizen-derived — lean manufacturing's terms — re-grounded here in Ruby-specific waste (unused gems as Inventory, blocking I/O as Waiting) and Ruby-specific failures (Zeitwerk naming).

### Also in the mix

- **Kaizen / Toyota Production System** — the waste taxonomy and diagnostic vocabulary behind `analyse`
- **Toulmin argumentation** (Stephen Toulmin, *The Uses of Argument*) — the evidence format every SIFT finding must satisfy
- **Gherkin & Cucumber, STRIDE threat modeling, CRAP scoring, mutation testing, packwerk** — the acceptance and gate mechanics each phase owns
- **The gem ecosystem itself** — dry-rb, rubysmith/gemsmith, the TTY toolkit, glimmer-dsl-libui, RubyLLM, dspy.rb, Ohm, Sequel, pgvector: the reference material documents these projects' own conventions, verified via Context7 MCP or DeepWiki at the point of use rather than recalled from memory

## Contributing

Contributions welcome. Open an issue or submit a pull request. Skills are pure Markdown — no build step, no tests. Validate changes by reading the Markdown for coherence and checking that agent-to-skill dispatch paths remain correct.

## License

[MIT](LICENSE) — Syncopated Context
