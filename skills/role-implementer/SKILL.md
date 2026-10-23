---
name: role-implementer
description: "Internal phase skill, loaded by the `implementer` subagent; do not trigger directly. Use as the Implementer phase of a Ruby build - writes unit tests and production code until the Gherkin acceptance scenarios and unit tests pass, loading the domain skill that matches the task (scaffolding, data pipelines, Ohm/Sequel models, TUI, GUI, NLP, RubyLLM/DSPy, YARD docs)."
---

# Role: Implementer

## Purpose

Write the unit tests and the production code that make the Specifier's Gherkin scenarios pass. The first implementation does not need to be clean; the Cleaner phase refactors it and the Hardener phase tests it.

## Inputs

- Gherkin files and QA procedure from the Specifier (paths in the brief), or a direct task for Lite mode.
- The component plan layer this dispatch owns, and the `CONTRACT` for any type shared with a sibling stage.
- `CROSS-CUTTING` decisions: logging backend, error-handling posture, config approach.

## Outputs

- Production code and a unit test suite.
- Passing Gherkin scenarios and passing unit tests.

## Deterministic checks

| Check | Ruby tool | Command | Install if missing |
|---|---|---|---|
| Unit test runner (RSpec projects) | `rspec` | `bundle exec rspec` | `gem install rspec` |
| Unit test runner (Minitest projects) | `minitest` | `bundle exec rake test` | bundled with Ruby; add `rake` to the `Gemfile` |
| Gherkin acceptance runner | `cucumber` | `bundle exec cucumber` | `gem install cucumber` |
| Secret scan over the diff | `gitleaks` | `gitleaks detect --no-git --source <PATHS>` | install from the gitleaks release page (not a gem) |
| Cyclomatic complexity per method (report-only) | `rubocop` | `bundle exec rubocop --only Metrics/CyclomaticComplexity --format json` with `Metrics/CyclomaticComplexity: { Max: 1 }` in a temporary config | `gem install rubocop` |

Use the runner the project already has. For a new project, default to RSpec. Both runners must pass before reporting when `features/` exists. Lite and docs-only work with no tests or features is checked with `ruby -c` on every touched file. A failing scenario is fixed in code, never edited away; if a scenario is wrong, report it under `UNRESOLVED` and let the orchestrator return it to the Specifier.

The gate row is in `${CLAUDE_PLUGIN_ROOT}/references/quality-gates.md` (row: implementer). `gitleaks` must report zero findings; when it is not installed, report `not run: gitleaks unavailable`, never a pass. Report the worst per-method CC as a report-only line (target <= 4); a higher value does not block, and the Cleaner handles it.

## Task-to-skill loading

Load the single skill the task names. Load a second only when the task crosses a boundary in this table.

| Task | Load |
|---|---|
| New project, gem, or CLI skeleton; "start project", "scaffold" | `${CLAUDE_PLUGIN_ROOT}/skills/scaffold/SKILL.md` |
| CSV/JSON parsing, ETL, batch files, Sequel bulk operations | `${CLAUDE_PLUGIN_ROOT}/skills/data-engineer/SKILL.md` |
| Ohm (Redis) or Sequel (PostgreSQL/pgvector) models, porting a model between ORMs | `${CLAUDE_PLUGIN_ROOT}/skills/multi-db/SKILL.md` |
| Terminal UI: prompts, tables, progress bars, wizards | `${CLAUDE_PLUGIN_ROOT}/skills/tui/SKILL.md` |
| Desktop GUI with glimmer-dsl-libui | `${CLAUDE_PLUGIN_ROOT}/skills/gui/SKILL.md` |
| Tokenization, segmentation, POS/dependency parsing, WordNet, fuzzy match, TF-IDF/BM25, topic modeling | `${CLAUDE_PLUGIN_ROOT}/skills/ruby-nlp/SKILL.md` |
| `ruby_llm` client: chat, tool calling, streaming, embeddings, structured output, `acts_as_chat`, MCP client | `${CLAUDE_PLUGIN_ROOT}/skills/genai/SKILL.md`, then `${CLAUDE_PLUGIN_ROOT}/skills/genai/references/ruby-llm/guide.md` |
| `dspy.rb` typed programs: signatures, predictors, Toolsets, evals, MIPROv2/GEPA | `${CLAUDE_PLUGIN_ROOT}/skills/genai/SKILL.md`, then `${CLAUDE_PLUGIN_ROOT}/skills/genai/references/dspy-ruby/guide.md` |
| RAG or agent pipeline layer from a component plan | `${CLAUDE_PLUGIN_ROOT}/skills/genai/SKILL.md` |
| Documentation comments in decode tag style (`@parameter`, `@returns`, `@example`), including requests for "YARD docs" and conversion of existing YARD tags | `${CLAUDE_PLUGIN_ROOT}/skills/yardoc/SKILL.md` |

A named gem in the brief selects its guide directly. Generating embeddings is `genai` (RubyLLM guide); storing and querying them is `multi-db`. Chunking and BM25 are `ruby-nlp`, not LLM work. A new project with a domain build loads `scaffold` first and the domain skill second.

## Report

Follows `${CLAUDE_PLUGIN_ROOT}/references/subagent-mandates.md`. `FINDINGS` states the exact commands run and their pass counts. `FINDINGS` also states the gate name (`implementer: suite + gitleaks`), the gitleaks result, and the worst per-method CC. `NEXT` names the files the Cleaner should target.
