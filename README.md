# ruby-dev

**A task-driven Claude plugin routing Ruby work across 14 specialist subagents — from scaffolding to SIFT audits — through the `rubyist` multi-agent gateway.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugin Version](https://img.shields.io/badge/version-4.0.0-green.svg)](.claude-plugin/plugin.json)
[![Claude Plugin](https://img.shields.io/badge/Claude-Plugin-purple.svg)](.claude-plugin/plugin.json)

## Features

- **Multi-Agent Gateway** — The `rubyist` agent plans a dispatch route and delegates every stage to a specialist subagent in isolated context; no need to know which specialist applies upfront
- **Project Scaffolding** — rubysmith/gemsmith flag presets by archetype (CLI, gem, web service, OSS) with convention hardening
- **Data Pipelines** — Stream-based CSV/JSON parsing, ETL workflows, and Sequel bulk operations
- **Multi-Database Modeling** — Ohm (Redis) and Sequel (PostgreSQL/pgvector) design, ORM porting, dual-database retrieval patterns
- **GenAI & RAG** — Retrieval pipeline architecture, LLM agents, MCP servers, pgvector integration
- **Typed LLM programs (dspy.rb)** — Sorbet-typed signatures, Predict/ChainOfThought/ReAct, Toolsets, `DSPy::Evals`, MIPROv2 & GEPA prompt optimization
- **LLM Client Integration** — RubyLLM gem ecosystem: multi-provider chat, tool calling, streaming, embeddings, structured output
- **Classical NLP** — Tokenization, POS tagging, dependency parsing, WordNet lookup, TF-IDF/BM25 ranking, topic modeling
- **Terminal UIs** — 21 TTY toolkit gems: prompts, tables, progress bars, spinners, pagers, trees, and rich CLI output
- **Desktop GUIs** — Native cross-platform windows with glimmer-dsl-libui and data-bound MVP architecture
- **Diagnostics** — Gemba Walk, Muda Analysis, Root-Cause Tracing, and Five Whys for systematic debugging
- **Surgical Refactoring** — Named pattern catalog (Zeitwerk, async, frozen strings, resilience) with before/after transforms
- **Performance Optimization** — Profile-Benchmark-Optimize cycle with stackprof and benchmark-ips; keeps only measured wins
- **YARD Documentation** — AST-informed type inference generating @param, @return, @example, and @raise tags
- **SIFT Quality Audits** — Structure, Idioms, Functionality, Testing assessment with Toulmin evidence framework

## Architecture

The plugin follows a **gateway + specialist** pattern. `rubyist` is a gateway *agent*, not a skill — it runs in its own context window, so the routing logic and the specialists' instructions never accumulate in the caller's context. It emits a dispatch plan, delegates each stage to a specialist subagent, compacts their reports, and synthesizes the result.

`rubyist` writes no Ruby and never loads a specialist's `SKILL.md`. Each specialist skill also remains directly invocable when a task is single-concern and the routing is obvious.

```
                    ┌──────────────────────────┐
                    │   rubyist (gateway)      │
                    │  survey → plan → dispatch│
                    │  → compact → synthesize  │
                    └────────────┬─────────────┘
      ┌──────────────┬───────────┼───────────┬──────────────┐
      │              │           │           │              │
 ┌────▼─────┐  ┌─────▼────┐ ┌────▼────┐ ┌────▼────┐  ┌──────▼──────┐
 │ scaffold │  │   data   │ │   tui   │ │   gui   │  │  cognitive  │
 │          │  │ engineer │ │ builder │ │ builder │  │  architect  │
 └──────────┘  └──────────┘ └─────────┘ └─────────┘  └──────┬──────┘
                                            plans, does not build
                              ┌──────────────┬──────┴───────┬──────────────┐
                         ┌────▼────┐  ┌──────▼───┐  ┌───────▼──┐  ┌────────▼──┐
                         │multi-db │  │ ruby-nlp │  │ ruby-llm │  │ dspy-ruby │
                         │ (store) │  │  (text)  │  │ (client) │  │  (typed)  │
                         └─────────┘  └──────────┘  └──────────┘  └───────────┘

      ┌──────────┐  ┌────────────┐  ┌───────────┐  ┌──────────────────┐  ┌─────────┐
      │ debugger │→ │ refactorer │  │ optimizer │  │ technical-writer │  │ auditor │
      │(diagnose)│  │   (fix)    │  │ (measure) │  │      (YARD)      │  │ (SIFT)  │
      └──────────┘  └────────────┘  └───────────┘  └──────────────────┘  └─────────┘
```

### Execution Pipeline

1. **Survey** — `rubyist` reads only enough to route. Classifies Lite Mode (scripts < 50 lines, stdlib only) or Standard Mode (multi-file, gem-dependent)
2. **Plan** — A dispatch plan is emitted before any subagent is spawned: which specialists, in what order, what each receives and returns
3. **Dispatch** — Each stage runs as a specialist subagent in isolated context, receiving a compact brief (`TASK` / `PATHS` / `CONSTRAINTS` / `UPSTREAM` / `RETURN`)
4. **Report** — Every specialist returns a structured `CHANGED` / `FINDINGS` / `UNRESOLVED` / `NEXT` block. `rubyist` is the compaction boundary: briefs carry summaries, never transcripts
5. **Audit** — SIFT quality gate by `auditor`, in a fresh context so the audit is independent of the builder's assumptions
6. **Synthesize** — `rubyist` reports what changed, the audit verdict, and anything unresolved

Non-stdlib gem APIs are verified via Context7 MCP or DeepWiki at the point of use, inside whichever specialist writes the code.

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

### Gateway Entry Point

The `rubyist` agent is the primary entry point. Use it for any task spanning more than one concern, or when it is unclear which specialist applies.

```
Use the rubyist agent to scaffold a new CLI application with TUI prompts
```

```
Use the rubyist agent to build a RAG pipeline with pgvector and RubyLLM
```

### Direct Specialist Invocation

Each specialist can be invoked directly when the task is well-scoped:

```
Use the tui-builder agent to create an interactive table with tty-table
```

```
Use the auditor agent to run a SIFT quality audit on lib/my_app.rb
```

```
Use the optimizer agent to profile and reduce allocations in the hot path
```

### Skill Reference

Shared conventions live in `references/` at the plugin root (dry-rb, OOD, logging, env, pry, scaffolding) and are loaded by skills and agents alike.

| Skill | Purpose | Reference Files |
|-------|---------|-----------------|
| `scaffold` | Project scaffolding with rubysmith/gemsmith | 1 (flag presets) |
| `data-engineer` | CSV/JSON parsing, ETL pipelines | — |
| `multi-db` | Ohm/Sequel modeling, dual-database patterns | 2 (ORM idioms, SFL case study) |
| `genai` | RAG pipelines, LLM agents, MCP servers | 2 (component templates, project setup) |
| `ruby-llm` | RubyLLM gem: chat, tools, streaming, embeddings | — |
| `ruby-nlp` | Tokenization, POS tagging, TF-IDF, BM25 | 1 (gem catalog) |
| `tui` | Terminal UIs with TTY toolkit | 21 (one per tty-* gem) |
| `gui` | Desktop GUIs with glimmer-dsl-libui | 4 (area, controls, custom, data-binding) |
| `analyse` | Debugging: Gemba Walk, Muda, Five Whys | 2 (types, examples) |
| `refactor` | Named refactoring pattern catalog | 1 (pattern definitions) |
| `perf` | Profiling, benchmarking, allocation reduction | 1 (optimization catalog) |
| `yardoc` | YARD documentation generation | 6 (patterns, types, errors, logging, dry-struct, Context7) |
| `sift` | SIFT quality audits with Toulmin evidence | 2 (assessment types, examples) |

### Agent Registry

Each specialist agent is a thin wrapper dispatching to its corresponding skill, carrying the core mandates and a structured return contract. `rubyist` is the exception — it has no skill of its own and exists purely to route. Prefer agents whenever isolated context is beneficial (audits that should judge code independently, long diagnostic passes, or any multi-stage build).

| Agent | Role | Dispatches To |
|-------|------|---------------|
| `scaffolder` | Project Scaffolder | `scaffold` |
| `data-engineer` | Data Pipeline Engineer | `data-engineer` |
| `multi-db` | Data Modeler | `multi-db` |
| `cognitive-architect` | Cognitive Architect | `genai` |
| `ruby-llm` | LLM Integrator | `ruby-llm` |
| `ruby-nlp` | The Linguist | `ruby-nlp` |
| `tui-builder` | TUI Builder | `tui` |
| `gui-builder` | GUI Builder | `gui` |
| `debugger` | Stealth Debugger | `analyse` |
| `refactorer` | Surgical Refactorer | `refactor` |
| `technical-writer` | Technical Writer | `yardoc` |
| `auditor` | Pragmatic Auditor | `sift` |
| `optimizer` | The Optimizer | `perf` |

## Code Conventions

When this plugin generates Ruby code, it enforces:

- `# frozen_string_literal: true` on line 1 of every `.rb` file
- Zeitwerk-compliant directory and file naming
- `dry-rb` ecosystem for type safety (`dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`)
- Methods default to `private`; promoted to `public` only for stable interfaces
- Undeclared parameters forwarded with `...` (`def foo(...) = bar(...)`)
- Non-stdlib gem APIs verified via Context7 MCP or DeepWiki at the point of use — never assumed from memory

## Contributing

Contributions welcome. Open an issue or submit a pull request. Skills are pure Markdown — no build step, no tests. Validate changes by reading the Markdown for coherence and checking that agent-to-skill dispatch paths remain correct.

## License

[MIT](LICENSE) — Syncopated Context
