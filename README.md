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

This plugin is assembled work. Its skeleton — the pipeline, the audit protocol, the diagnostic discipline — was extracted and adapted from named sources rather than invented, and the assembly deserves its credit. Each of the three principal sources gets its own accounting below: what the source actually says, what survived the extraction, and what this plugin added on top.

### The workflow matrix — from Robert C. Martin, in conversation with Matt Pocock

The plugin's spine is the fixed phase matrix — `specifier` → `implementer` → `cleaner` → `hardener` → `verifier`, each phase doing one kind of work and owning one deterministic check. It was extracted from [a live interview](https://www.youtube.com/watch?v=zcLPGC-tvgk) in which Matt Pocock talks with Robert C. Martin about whether software fundamentals survive the age of AI coding agents.

Martin's position in that conversation: agents write code fast but messy, and they treat detailed written instructions as suggestions — long prompts lose their middles — so the leverage is not in *steering* them with more words but in deterministic tools run *after* they generate: CRAP scoring, mutation testing, acceptance tests. Old analysis tools, too slow to run by hand across a working day, become practical once an agent runs them. On that basis he sketches a five-role pipeline: a specifier that turns human requirements into Gherkin acceptance tests and QA procedures; a coder that writes unit tests and production code to make them pass; a cleaner that runs CRAP analysis and code review; a hardener that mutation-tests until the surviving mutants die; a QA agent that turns the QA procedures into executable scripts. Plus a cross-cutting architectural check — deterministic module-dependency rules — kept because partitioned code stays legible to humans and agents both. The trade he characterizes roughly as an hour of pipeline against five minutes of single-agent output, and the hour is what buys the quality.

The extraction artifacts are checked into this repo: [`Agent Software Development Workflow Matrix - Table 1.csv`](Agent%20Software%20Development%20Workflow%20Matrix%20-%20Table%201.csv) and [`Workflow_matrix_updated.csv`](Workflow_matrix_updated.csv) at the root, with the adaptation decisions recorded in [`goals/workflow-matrix-integration/`](goals/workflow-matrix-integration/).

What survived the extraction is the *shape*: a route through small, single-purpose stages, gated before handoff, in a fixed order with explicit skip rules — rather than one agent improvising a fresh approach per task. What the plugin changed: it split the matrix's combined cleaner/hardener row into two subagents, dropped a separate architect agent by folding module-dependency checking into the verifier's gate, and let the `verifier` inherit the QA agent's job — the written QA procedures become executable acceptance checks — while adding a SIFT audit on top. It added the Ruby-specific machinery at each stop: `cucumber --dry-run` on the spec, a CRAP threshold after refactoring, `mutant` and `bundler-audit` for hardening, a SIFT audit in a fresh context at the end. One invariant is the plugin's own, not the interview's: the `rubyist` orchestrator routes but never writes Ruby. The matrix as shipped lives in the phase sequence table in [`agents/rubyist.md`](agents/rubyist.md), with routing and skip rules formalized in [`tasks/step-1-survey-plan.md`](tasks/step-1-survey-plan.md) and gate thresholds, rollback targets, and escalation triggers in [`references/quality-gates.md`](references/quality-gates.md).

### SIFT — from Mike Caulfield's SIFT method and the SIFT Toolbox

The [`sift`](skills/sift/SKILL.md) skill's quality protocol adapts [the SIFT Toolbox](https://checkplease.neocities.org/sift-toolbox/), Mike Caulfield's April 2025 release: a "Deep Background" prompt for Claude and ChatGPT that fact-checks a claim by searching for conflicting sources, categorizes the evidence through a Toulmin framework, and returns structured reports — verified facts, corrections, source assessments. The acronym is older than the Toolbox. Caulfield's 2019 SIFT method ([SIFT (The Four Moves)](https://hapgood.us/2019/06/19/sift-the-four-moves/), adapted from the *Check, Please!* web-literacy starter course) is a four-move method for evaluating sources: Stop; Investigate the source; Find better coverage; Trace claims to their original context. The Toolbox is that method rebuilt for the LLM era — and it is the Toolbox, with its evidence machinery, that this plugin took from.

What the plugin keeps from the lineage: the compact four-part lens a reviewer can hold in mind — re-expanded for code as **S**tructure, **I**dioms, **F**unctionality, **T**esting — and the insistence that evaluation is evidence work: every finding must arrive as a Toulmin argument before it counts. The Toolbox's "another round" — a second pass that *fact-checks the fact-check*, pushing on the first pass's weakest points — has its descendant in the `verifier`, dispatched in a fresh context so the audit is independent of the builder's assumptions.

One precision note, because honesty is cheaper downstream than a rubric nobody follows: the skill's model is the full six-element chain (claim, data, warrant, backing, qualifier, rebuttal); its per-finding checklist enforces claim, data, warrant, and backing as the floor, with the qualifier riding on the severity scale and the rebuttal appearing where a reasonable one exists ([`skills/sift/SKILL.md`](skills/sift/SKILL.md)). The dimension weights (Functionality 0.35, Structure 0.25, Idioms 0.20, Testing 0.20), the score bands, and the four report modes (Full, System Design Review, Tech Advisory, Backlog) are this plugin's own additions.

### Structured diagnostic analysis — from the context-engineering-kit's Kaizen plugin

The [`analyse`](skills/analyse/SKILL.md) skill's core mandate — *understand before acting, never refactor without diagnosis* — formalizes the diagnosis-first discipline of [Neo Lab's context-engineering-kit](https://github.com/NeoLabHQ/context-engineering-kit), a collection of context-engineering patterns for coding agents, and specifically its [Kaizen plugin](https://neolab.gitbook.io/cek/plugins/kaizen): a "continuous improvement methodology inspired by Japanese philosophy and Agile practices" whose commands include `/analyse` (auto-selects the best Kaizen method for the target), `/why` (iterative Five Whys), and `/root-cause-tracing` (systematically traces bugs backward through the call stack). The wording of the mandate is this plugin's own; the discipline is the kit's.

What the plugin took is the structure: a fixed catalog of diagnostic methods, and selection that routes each problem to a method instead of leaving diagnosis to improvisation. Its additions: the exactly-one-method selection matrix (an unfamiliar codebase routes to Gemba Walk; bloat routes to Muda Analysis; a `NameError` routes to Root-Cause Tracing; a twice-fixed bug routes to Five Whys), findings keyed for handoff in a `<method>:<category>` format — `muda:inventory`, `root-cause:zeitwerk` — so the fixing skill consumes structured findings rather than prose, and the vocabulary re-grounded in Ruby-specific waste (unused gems as Inventory, blocking I/O as Waiting) and Ruby-specific failures (Zeitwerk naming).

The diagnostic vocabulary is older than both the kit and this plugin, and the skill says so in one line: Gemba Walk, Muda Analysis, Root-Cause Tracing, and Five Whys are "four Kaizen-derived methods" ([`skills/analyse/SKILL.md`](skills/analyse/SKILL.md)). Kaizen is the Toyota Production System's continuous-improvement vocabulary, which reached code review by way of manufacturing. Which is the whole story of this plugin, really: assembled from sources that were themselves assembled from sources.

### Also in the mix

- **Kaizen / Toyota Production System** — the waste taxonomy and diagnostic vocabulary behind `analyse`, arriving via the context-engineering-kit
- **Toulmin argumentation** (Stephen Toulmin, *The Uses of Argument*) — the evidence format every SIFT finding must satisfy; Caulfield's Toolbox is where it entered this plugin's lineage
- **Gherkin & Cucumber, STRIDE threat modeling, CRAP scoring, mutation testing, packwerk** — the acceptance and gate mechanics each phase owns
- **The gem ecosystem itself** — dry-rb, rubysmith/gemsmith, the TTY toolkit, glimmer-dsl-libui, RubyLLM, dspy.rb, Ohm, Sequel, pgvector: the reference material documents these projects' own conventions, verified via Context7 MCP or DeepWiki at the point of use rather than recalled from memory

## Contributing

Contributions welcome. Open an issue or submit a pull request. Skills are pure Markdown — no build step, no tests. Validate changes by reading the Markdown for coherence and checking that agent-to-skill dispatch paths remain correct.

## License

[MIT](LICENSE) — Syncopated Context
