# ruby-dev

**A task-driven Claude plugin routing Ruby work through 1 orchestrator (`rubyist`) and 4 phase subagents — specifier, implementer, cleaner-hardener, verifier — that load domain skills on demand.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Plugin Version](https://img.shields.io/badge/version-5.0.0-green.svg)](.claude-plugin/plugin.json)
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
     ┌────────────┬───────────┴──┬───────────────────┬────────────┐
┌────▼─────┐  ┌───▼───────┐  ┌───▼──────────────┐  ┌─▼────────┐
│specifier │→ │implementer│→ │ cleaner-hardener │→ │ verifier │
│ Gherkin, │  │ tests +   │  │ CRAP score,      │  │ packwerk,│
│ QA proc. │  │ code      │  │ mutant           │  │ SIFT,    │
│ (no code)│  │           │  │                  │  │ cucumber │
└──────────┘  └─────┬─────┘  └──────────────────┘  └──────────┘
                    │ loads on demand
   scaffold · data-engineer · multi-db · tui · gui · ruby-nlp · genai · yardoc
```

| Phase subagent | Role skill | Deterministic check | Writes code |
|---|---|---|---|
| `specifier` | `role-specifier` | `bundle exec cucumber --dry-run` | no |
| `implementer` | `role-implementer` | `bundle exec rspec` or `rake test`, `bundle exec cucumber` | yes |
| `cleaner-hardener` | `role-cleaner-hardener` | CRAP score (simplecov + rubocop complexity), `bundle exec mutant run` | yes |
| `verifier` | `role-verifier` | `bundle exec packwerk check` (Rails projects with `package.yml`; otherwise reported not applicable), `bundle exec cucumber`, `bundle exec rubocop`, SIFT audit | no |

### Execution Pipeline

1. **Survey** — `rubyist` reads only enough to route. Classifies Lite Mode (scripts < 50 lines, stdlib only) or Standard Mode (multi-file, gem-dependent)
2. **Plan** — A dispatch plan is emitted before any subagent is spawned: which subagents, in what order, what each receives and returns
3. **Dispatch** — Each stage runs as a phase subagent in isolated context, receiving a compact brief (`TASK` / `PATHS` / `CONSTRAINTS` / `UPSTREAM` / `RETURN`)
4. **Report** — Every subagent returns a structured `CHANGED` / `FINDINGS` / `UNRESOLVED` / `NEXT` block. `rubyist` is the compaction boundary: briefs carry summaries, never transcripts
5. **Verify** — SIFT quality gate by `verifier`, in a fresh context so the audit is independent of the builder's assumptions
6. **Synthesize** — `rubyist` reports what changed, the verifier verdict, and anything unresolved

Non-stdlib gem APIs are verified via Context7 MCP or DeepWiki at the point of use, inside whichever subagent writes the code.

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
Use the cleaner-hardener agent to profile and reduce allocations in the hot path
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
| `rubyist` | Orchestrator | none (dispatches only the four below) |
| `specifier` | Gherkin acceptance scenarios, QA procedures, component plans | `role-specifier` → `genai` (architecture), `multi-db`, `analyse` |
| `implementer` | Unit tests and production code | `role-implementer` → `scaffold`, `data-engineer`, `multi-db`, `tui`, `gui`, `ruby-nlp`, `genai`, `yardoc` |
| `cleaner-hardener` | Diagnose, refactor to a CRAP threshold, mutation-test | `role-cleaner-hardener` → `analyse`, `refactor`, `perf`, `evals` |
| `verifier` | Dependency rules, SIFT audit, acceptance tests; no code | `role-verifier` → `sift`, `analyse` |

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
