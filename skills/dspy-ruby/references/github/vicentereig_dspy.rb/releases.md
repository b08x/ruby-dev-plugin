# Releases: vicentereig/dspy.rb

## v1.0.2: DSPy.rb 1.0.2: Claude Can Think. We Added Types Anyway.

**Published**: 2026-07-18

Thanks to [@a-zboon](https://github.com/a-zboon) for opening [#247](https://github.com/vicentereig/dspy.rb/issues/247) and asking for a public reasoning API.

Thanks to [@paulp-aus](https://github.com/paulp-aus) for reporting [#256](https://github.com/vicentereig/dspy.rb/issues/256) and [#259](https://github.com/vicentereig/dspy.rb/issues/259), implementing [#257](https://github.com/vicentereig/dspy.rb/pull/257), testing the live Anthropic API, and carrying the work through two review rounds.

Thanks to [@lennart](https://github.com/lennart) and his cape-and-cowl agent, @paulp-aus—Batman to his Bruce Wayne, Heisenberg to his Walter White. Skyler, wisely, declined involvement in the Anthropic adapter.

DSPy.rb 1.0.2 gives Claude a typed reasoning dial, fixes Anthropic streaming, and makes signature omission explicit. Claude may now think harder. Ruby, naturally, demands paperwork.

## Claude can think on a budget

`DSPy::Reasoning` adds typed levels from `low` through `max`, plus exact token budgets, adaptive reasoning, and an off switch. In this release, `dspy-anthropic` maps those settings to provider parameters and rejects bad model, budget, token, and sampling combinations before they become expensive HTTP requests. Claude can waste tokens on its own time.

```ruby
class ResearchBrief < DSPy::Signature
  description "Answer a research question concisely"

  input do
    const :question, String
    const :context, T.nilable(String), default: nil
  end

  output do
    const :answer, String
  end
end

lm = DSPy::LM.new(
  "anthropic/claude-sonnet-5",
  api_key: ENV.fetch("ANTHROPIC_API_KEY"),
  reasoning: DSPy::Reasoning.high,
  max_tokens: 8_192
)

DSPy.configure { |config| config.lm = lm }

result = DSPy::Predict.new(ResearchBrief).call(
  question: "Why does the sky appear blue?"
)

puts result.answer
```

## Nilable is not optional

A signature field without `default:` is now required, even when its type is `T.nilable`. To permit omission, say so:

```ruby
const :context, T.nilable(String), default: nil
```

`Predict`, `ReAct`, and `CodeAct` now agree on this rule. `T.nilable` means the value may be `nil`. It does not mean the field enjoys sovereign citizenship.

## Anthropic repairs

- Structured outputs use the stable `output_config` API and can share a request with reasoning. “Stable” is a technical term meaning the deprecated one finally frightened us enough.
- Raw streams consume `MessageStream#text`, yield each fragment once, and return the accumulated string. Previously, some streams returned the sort of profound silence usually sold as a retreat.
- Fixed-sampling Claude families no longer receive DSPy.rb's implicit temperature.
- `temperature:` and `max_tokens:` are configurable and validated against model capabilities.

## Smaller, useful things

- ReAct finish actions may omit `tool_input`; actual tool calls may not improvise the shape of reality.
- Standalone Toolset loading now loads its own base class.
- Missing-adapter errors retain the useful installation message.
- The documentation now has one 22-step quality gate, because apparently writing a sentence required an air-traffic-control tower.
- CI adds a complete non-unit RSpec lane and uses inert telemetry credentials. Computers remain the only coworkers eager to prove you wrong at four in the morning.

## Gems

Four gems shipped together, because one version number would have made maintainers dangerously comfortable.

- `dspy` 1.0.2
- `dspy-anthropic` 1.0.6
- `dspy-code_act` 1.0.3
- `dspy-ruby_llm` 0.1.2

Full history: [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/v1.0.2/CHANGELOG.md)


## v1.0.1: DSPy.rb 1.0.1

**Published**: 2026-06-12

DSPy.rb 1.0.1 is a small release with the kind of fix that makes you say, "wait, surely we were already doing that."

The headline is ReAct instructions. Thanks to @devjoaov, ReAct now carries the user's signature description into the actual agent loop, not just the decorative typing layer where hopes go to become comments. If your signature says "be terse", "follow this policy", or "answer like a support agent with a manager standing behind them", the thought prompt and observation prompt now both see it.

Also fixed: the Datasets GitHub Actions job now builds Arrow-backed native gems with C++20 flags, because Apache Arrow started using C++20 APIs and CI responded with the confidence of a laptop from 2017.

### Fixed

- ReAct now preserves signature descriptions across thought generation and tool-observation interpretation. Thanks @devjoaov for catching and fixing the missing instruction path in #253.
- The Datasets CI matrix now compiles `red-arrow` / `red-parquet` against Arrow 23 headers with C++20.

### Verification

- Ruby Tests passed on `main`
- GitHub Pages deploy passed
- `gem build dspy.gemspec` builds `dspy-1.0.1.gem`


## v1.0.0: DSPy.rb 1.0.0

**Published**: 2026-04-11

# DSPy.rb 1.0.0

DSPy.rb 1.0.0 is out.

We’ve reached the ceremonial point in a software project where continuing to call it `0.34.4` starts to seem less “humble” and more like a person refusing to define the relationship.

This release comes after a few months of smaller revisions, which is the least cinematic and most trustworthy way software improves. Not with one brilliant breakthrough, but with a long series of bug fixes, boundary cleanups, sharper abstractions, and contributors choosing, again and again, not to leave the raccoon in the ventilation system for someone else.

On the way here, DSPy.rb picked up:

- TOON/BAML formatting for leaner structured prompting
- RubyLLM support for broader provider coverage
- Anthropic strict and Beta structured outputs
- Langfuse score reporting and better observability
- stronger type coercion and JSON extraction
- multimodal PDF/document support

What lands in `1.0.0` itself:

- Anthropic PDF document support through `DSPy::Document`, `raw_chat`, and `Predict`
- GEPA eval runs that no longer disintegrate because one example decided to become folklore
- safer sanitization for control characters in extracted JSON
- updated adapter SDK floors, with compatibility expressed through dependencies instead of runtime guardrails

Thanks to the contributors who helped drag this into legitimate-software status:

- Francois Buys
- Kieran Klaassen
- Benjamin Jackson
- tleish
- Abdelrahman Alzboon
- Avi Flombaum

Open source is still a bizarre system. People from different places, with fully separate lives, voluntarily spend time improving a library so it can become more stable for strangers on the internet. That is generous, slightly irrational, and deeply appreciated.

If you’ve been on the later `0.3x` releases, `1.0.0` should feel familiar. That’s intentional. This is not a dramatic reinvention. It’s the version where we stop pretending the library is still just a promising young upstart and admit it has become dependable, which is the most flattering thing software can be without becoming a chair.


## v0.34.4: Anthropic Beta structured outputs and safer type coercion

**Published**: 2026-03-07

This patch release lands the Anthropic Beta API structured outputs work, tightens type coercion around structured outputs, and ships the latest sibling gem updates that support the same flow.

## Highlights

- Anthropic Beta API structured outputs are now the default structured-output path, reducing tool-calling overhead and aligning Anthropic with the OpenAI/Gemini flow.
- `TypeCoercion` now handles nilable struct unions, stringified hash fields, and malformed inline-hash fallbacks more safely in enhanced prompting and TOON-style outputs.
- Usage extraction now preserves Anthropic cache token fields, and JSON parsing got extra hardening for trailing-comma edge cases.
- `StructBuilder` now preserves field descriptions correctly, and `dspy` now requires `sorbet-baml >= 0.5.1`.

## Published gems

- `dspy` `0.34.4`
- `dspy-anthropic` `1.0.4`
- `dspy-gemini` `1.0.3`
- `dspy-o11y` `1.0.3`
- `dspy-datasets` `1.0.2`

## Contributor credits

- Benjamin Jackson (@benjaminjackson): delivered the core Anthropic Beta structured outputs work in #230, surfaced cache token usage fields in #231, improved nilable struct coercion in #232, hardened Anthropic parsing in #233, and contributed supporting docs and serialization fixes earlier in the cycle.
- tleish (@tleish): authored the original `coerce_hash_value` hash-as-string fix and the new regression coverage in #237.
- Abdelrahman Alzboon (@a-zboon): fixed `StructBuilder` so field descriptions propagate correctly in #235.

## Pull requests in this release line

- #230 Beta API structured outputs
- #231 Anthropic cache token usage fields
- #232 Smart union handling for nilable structs
- #233 Trailing comma hardening for Anthropic structured outputs
- #235 StructBuilder field description fix
- #237 Hash-as-string coercion fix
- #239 Require `sorbet-baml` 0.5.1+
- #240 Malformed hash-string fallback


## v0.34.3: v0.34.3

**Published**: 2026-02-05

## What's Changed

### Added
- **Anthropic Strict Mode** – Enabled constrained decoding for Anthropic models with proper JSON schema compliance
- **ContentFilterError** – New error type for handling Anthropic content filtering responses gracefully

### Fixed
- **Union Type Schemas** – Changed from `oneOf` to `anyOf` for union type JSON schemas (required for Anthropic strict mode)
- **Struct Field Defaults** – Strip nil values for non-nilable struct fields that have defaults
- **Anthropic Required Properties** – Enforce all properties in `required` array for strict mode compliance
- **Union Type Coercion** – Parse JSON string values correctly in union type coercion
- **T::Enum Deserialization** – Centralized with case-insensitive fallback for robustness
- **Documentation** – Correct `DSPy::Module::Callbacks` reference in Rails integration guide

### Changed
- **Type Coercion Consolidation** – Centralized type introspection into `TypeCoercion` mixin
- **Code Cleanup** – Removed unused Memory System, `SubscriberMixin`, `BaseSubscriber`, and dead code
- **Adapter Refactoring** – Extracted shared multimodal formatting to base adapter class

### Sibling Gem Updates
| Gem | Version |
|-----|---------|
| dspy-anthropic | 1.0.3 |
| dspy-schema | 1.0.2 |
| dspy-openai | 1.0.2 |
| dspy-gemini | 1.0.2 |
| dspy-code_act | 1.0.2 |
| dspy-evals | 1.0.2 |
| dspy-o11y | 1.0.2 |

### Installation

```ruby
gem "dspy", "~> 0.34.3"

# Provider gems (pick one or more)
gem "dspy-openai"
gem "dspy-anthropic"
gem "dspy-gemini"
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.34.2...v0.34.3

## v0.34.2: None

**Published**: 2026-01-02

## Highlights
- Fiber-safe DSPy::Context to avoid shared span/module stacks under Async.
- LM#raw_chat now accepts symbol roles and string-keyed hashes.
- Removed unused LM event consolidation helpers.

## Changes
- Context forks per fiber while preserving trace lineage.
- Raw chat normalization/validation accepts legacy hash formats.
- Cleaned up dead LM event helper methods.

## Testing
- rbenv exec bundle exec rspec
- rbenv exec bundle exec srb tc (failed: srb not found in Ruby 3.4.5 rbenv)


## v0.34.1: v0.34.1

**Published**: 2025-12-30

## Fixed
- **Recursive Schema `$ref` Format** (#201) - Changed JSON Schema `$ref` format from `#/definitions/` to `#/$defs/` for OpenAI and Gemini structured outputs compatibility
  - Recursive types now work correctly with all major LLM providers
  - Schema generator properly tracks and outputs `$defs` section

## Added
- **T::Struct Field Descriptions** - New `description:` kwarg for T::Struct `const`/`prop` fields
  - Field descriptions flow to JSON Schema for better LLM understanding
  - Access via `YourStruct.field_descriptions[:field_name]`
  - Implemented via `DSPy::Ext::StructDescriptions` module prepended to T::Struct

- **HTML to Markdown Example** - Comprehensive example demonstrating:
  - Recursive AST types with `$defs`
  - Field descriptions for complex schemas
  - Hierarchical (two-phase) parsing pattern
  - Comparison of structured vs direct string approaches

## Documentation
- Updated llms.txt and llms-full.txt with recursive types and field descriptions
- New best practice: use `default: []` instead of `T.nilable(T::Array[...])` for OpenAI compatibility

## Install

```ruby
gem 'dspy', '~> 0.34.1'
```

## v0.34.0: v0.34.0 - Score Reporting for Langfuse

**Published**: 2025-12-23

## Score Reporting for Langfuse 📊

This release introduces a comprehensive score reporting system for tracking evaluation metrics in Langfuse.

### Highlights

#### New `DSPy.score()` API
Report evaluation metrics with a single call:

```ruby
DSPy.score("accuracy", 0.95, trace_id: prediction.trace_id)
DSPy.score("sentiment", "positive", data_type: DSPy::Scores::DataType::Categorical)
```

#### Built-in Evaluators
Ready-to-use evaluators for common metrics:
- `Exact` - Exact string matching
- `F1` - Token-level F1 score
- `SemanticSimilarity` - Embedding-based similarity
- `LLMAsJudge` - LLM-powered evaluation
- `NumericRange` - Numeric bounds checking

#### Evals Integration
Automatic score export during evaluation runs:

```ruby
evaluator = DSPy::Evals.new(program, metric: accuracy_metric)
result = evaluator.evaluate(test_examples, export_scores: true)
# All scores automatically exported to Langfuse
```

### Gem Updates
- **dspy** `0.34.0` - Core score reporting API and evaluators
- **dspy-o11y-langfuse** `1.1.0` - Langfuse ScoresExporter (moved from core)

### Documentation
- [Score Reporting Guide](https://oss.vicente.services/dspy.rb/production/observability/#score-reporting)
- [Custom Metrics](https://oss.vicente.services/dspy.rb/advanced/custom-metrics/)
- [AI Needs Its MVC Moment](https://oss.vicente.services/dspy.rb/blog/articles/ai-needs-its-mvc-moment/) - New blog post

### Installation

```ruby
gem "dspy", "~> 0.34.0"
gem "dspy-o11y-langfuse", "~> 1.1.0"  # For Langfuse score export
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.33.0...v0.34.0

## v0.33.0: v0.33.0

**Published**: 2025-12-12

## What's Changed

### Added
- **LM Configuration Propagation** (#193) - `Module#configure` now propagates LM settings to child predictors
  - New `configure_predictor` method for fine-grained control
  - Recursive propagation respects explicit child configurations

### Fixed
- ReAct type safety improvements
- Eliminated `T.untyped` from ReAct and CodeAct struct fields
- Test reliability fixes

### Documentation
- Added hoverable anchor links to documentation headers

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.32.0...v0.33.0

## v0.32.0: v0.32.0 - RubyLLM Integration: 12+ Providers, One Interface

**Published**: 2025-12-10

# DSPy.rb v0.32.0

## RubyLLM Integration by [@kieranklaassen](https://github.com/kieranklaassen)

This release is defined by **Kieran Klaassen's** outstanding contribution: the `dspy-ruby_llm` adapter that brings **12+ LLM providers** to DSPy.rb through a single, elegant interface.

### Why This Matters

Before this release, accessing providers like AWS Bedrock, VertexAI, DeepSeek, or Perplexity required custom adapters or wasn't possible at all. Now, with one gem and zero configuration:

```ruby
gem 'dspy-ruby_llm'

# That's it. Uses your existing RubyLLM.configure setup.
DSPy.configure do |c|
  c.lm = DSPy::LM.new('ruby_llm/gpt-4o')
end
```

### Supported Providers

| Provider | Example | Provider | Example |
|----------|---------|----------|---------|
| OpenAI | `ruby_llm/gpt-4o` | AWS Bedrock | `ruby_llm/anthropic.claude-3-5-sonnet` |
| Anthropic | `ruby_llm/claude-sonnet-4` | VertexAI | `ruby_llm/gemini-pro` |
| Google Gemini | `ruby_llm/gemini-1.5-pro` | OpenRouter | `ruby_llm/anthropic/claude-3-opus` |
| Ollama | `ruby_llm/llama3.2` | Perplexity | `ruby_llm/llama-3.1-sonar-large` |
| DeepSeek | `ruby_llm/deepseek-chat` | Mistral | `ruby_llm/mistral-large` |
| GPUStack | `ruby_llm/model-name` | | |

### What Kieran Built

- **800+ lines of tests** - Unit, integration, and VCR-backed specs
- **Pure convention-based design** - Auto-detects provider from RubyLLM's model registry
- **Full DSPy compatibility** - Structured outputs, streaming, vision support
- **Comprehensive documentation** - README with examples for every provider

---

## Other Improvements

### Skeptical Evaluator Loop
The evaluator loop now produces more critical, actionable feedback with the new `EvaluatorMindset` enum.

### Bug Fixes
- **Rails double-loading fix** - Prevent ObservationType enum from loading twice (#191)
- **Cross-gem require paths** - Fixed require_relative issues in dspy-miprov2 and dspy-gepa gems (#189)
- **Dependency conflicts** - Relaxed gem dependencies to resolve version conflicts

### Documentation
- Chain of Thought vs Predict comparison
- Ephemeral Memory Chat Router tutorial
- CodeAct Research Agent tutorial
- Evaluator Loop deep dive

---

## Contributors

This release features **130 commits** with contributions from:

| Contributor | Commits | Highlights |
|-------------|---------|------------|
| [@kieranklaassen](https://github.com/kieranklaassen) | 16 | **RubyLLM adapter**, Rails fixes, cross-gem require fixes |
| [@vicentereig](https://github.com/vicentereig) | 114 | Documentation, evaluator improvements, maintenance |

---

## Getting Started

```ruby
# Gemfile
gem 'dspy', '~> 0.32.0'
gem 'dspy-ruby_llm'  # For 12+ provider access

# config/initializers/dspy.rb
DSPy.configure do |c|
  c.lm = DSPy::LM.new('ruby_llm/claude-sonnet-4')
end
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.31.1...v0.32.0

## dspy-ruby_llm-v0.1.0: dspy-ruby_llm v0.1.0 - Unified LLM Provider Access

**Published**: 2025-12-10

# dspy-ruby_llm v0.1.0

Unified access to **12+ LLM providers** through a single adapter using [RubyLLM](https://rubyllm.com).

## Highlights

- **Zero-config integration** - Automatically uses your existing `RubyLLM.configure` setup
- **Lightweight** - RubyLLM has only 3 dependencies (Faraday, Zeitwerk, Marcel)
- **500+ models** with capability detection and auto provider resolution
- **Full DSPy compatibility** - Structured outputs, streaming, vision support

## Supported Providers

| Provider | Example Model ID |
|----------|------------------|
| OpenAI | `ruby_llm/gpt-4o` |
| Anthropic | `ruby_llm/claude-sonnet-4` |
| Google Gemini | `ruby_llm/gemini-1.5-pro` |
| AWS Bedrock | `ruby_llm/anthropic.claude-3-5-sonnet` |
| Ollama | `ruby_llm/llama3.2` |
| DeepSeek | `ruby_llm/deepseek-chat` |
| Mistral | `ruby_llm/mistral-large` |
| OpenRouter | `ruby_llm/anthropic/claude-3-opus` |
| VertexAI | `ruby_llm/gemini-pro` |
| Perplexity | `ruby_llm/llama-3.1-sonar-large` |
| GPUStack | `ruby_llm/model-name` |

## Quick Start

```ruby
gem 'dspy-ruby_llm'
```

```ruby
# Uses your existing RubyLLM configuration
DSPy.configure do |c|
  c.lm = DSPy::LM.new('ruby_llm/gpt-4o')
end

# Or with explicit API key
DSPy.configure do |c|
  c.lm = DSPy::LM.new('ruby_llm/claude-sonnet-4', api_key: ENV['ANTHROPIC_API_KEY'])
end
```

## Dependencies

- `dspy` (>= 0.32)
- `ruby_llm` (~> 1.3)

## Contributors

- [@kieranklaassen](https://github.com/kieranklaassen) - Implementation, tests, and documentation

**Full Changelog**: https://github.com/vicentereig/dspy.rb/commits/dspy-ruby_llm-v0.1.0

## dspy-miprov2-v1.0.2: dspy-miprov2 v1.0.2

**Published**: 2025-12-04

## Bug Fix

Fixes dspy-miprov2 load failure when installed as a standalone gem (#188).

### Changes
- Changed `require_relative` to `require` for cross-gem dependencies that exist in the core dspy gem (#189)

### What was broken
When `dspy-miprov2` was installed as a gem, `require_relative` statements resolved relative to the gem's directory structure. The files `teleprompter.rb`, `utils.rb`, `instruction_updates.rb`, and `grounded_proposer.rb` don't exist in the `dspy-miprov2` gem - they're in the core `dspy` gem.

cc @kieranklaassen

## sibling-gems-1.0.2: New Blog Articles, dspy-gepa Minor Updates

**Published**: 2025-11-28

### Dependency Fixes

Resolves version conflicts in the optimizer gems:

- **gepa 1.0.2**: Changed `dspy` dependency from exact version match to `< 1.0.0`
- **dspy-gepa 1.0.3**: 
  - Changed `gepa` dependency from exact version match to `>= 1.0.0`
  - Fixed broken `require_relative` in version file that caused LoadError when installed standalone

This allows `dspy 0.31.x` to work seamlessly with both optimizer gems.

---

### New Blog Articles

#### [Let the Model Write Your Tools](https://vicentereig.github.io/dspy.rb/blog/articles/codeact-research-agent/)
Build a research agent with CodeAct where the LLM generates Ruby code on the fly. Instead of defining tools upfront, the agent writes and executes code to fetch data from web APIs.

#### [Building Chat Agents with Ephemeral Memory](https://vicentereig.github.io/dspy.rb/blog/articles/ephemeral-memory-chat-router/)
A step-by-step guide to lightweight context engineering in Ruby. Build a chat agent with ephemeral memory and cost-based routing.

#### [Evaluator Loops in Ruby: Ship Sales Pitches with Confidence](https://vicentereig.github.io/dspy.rb/blog/articles/evaluator_loop_in_ruby/)
Turn LLM calls into composable building blocks with the evaluator-optimizer pattern. Use a cheap model for drafting and a smarter model for critique.

#### [Build a Workflow Router in Ruby](https://vicentereig.github.io/dspy.rb/blog/articles/workflow-routing-with-dspy.rb/)
Route tickets to the right Language Model with a lightweight classifier plus specialized predictors.

#### [What TOON Gets That CSV Doesn't](https://vicentereig.github.io/dspy.rb/blog/articles/toon-vs-csv-nested-relationships/)
Token-Oriented Object Notation keeps your nested Sorbet structs intact for LLM prompts.

## sibling-gems-1.0.1: Sibling gems 1.0.1

**Published**: 2025-11-21

Loosened dspy dependency to >=0.30 across sibling gems; bumped versions to 1.0.1 and published to RubyGems.

## v0.31.1: None

**Published**: 2025-11-07

## 0.31.1
- Updated the TOON launch article with the richer TaskDecomposition benchmark (≈9.5k schema + 2.4k data tokens saved per call) plus cost/latency notes, so teams know what to expect when enabling `schema_format: :baml` / `data_format: :toon` on complex payloads.


## v0.31.0: DSPy.rb 0.31.0 – TOON everywhere

**Published**: 2025-11-07

## Highlights

- **Token-Oriented Object Notation (TOON)** lands for every Enhanced Prompting flow. Flip `schema_format: :baml` and `data_format: :toon` to cut schema + payload tokens without rewriting signatures or prompts.
- **ReAct + tools speak TOON**. Iteration history, available tools, and observation payloads render as TOON tables so loops stay readable and cheap.
- **Benchmark + docs refresh**. `examples/baml_vs_json_benchmark.rb` now compares every schema/data combination and ships `.json/.csv/.txt` artifacts for decks. A new article (`docs/src/_articles/toon-data-format.md`) spells out savings, FAQs, and the Sorbet::Toon roadmap.
- **CI + dependency hygiene**. Sorbet::Toon specs run in GitHub Actions with the same feature toggles as the DSPy core job, and `DSPy::Evals#to_polars` now lazy-loads Polars so lightweight bundles stop erroring.

## Upgrade checklist

1. **Update gems** – `bundle update dspy dspy-openai dspy-anthropic dspy-gemini sorbet-toon` (install only the adapters you need). The new provider gems live in their own READMEs:
   - [OpenAI/OpenRouter/Ollama](https://github.com/vicentereig/dspy.rb/blob/main/lib/dspy/openai/README.md)
   - [Anthropic](https://github.com/vicentereig/dspy.rb/blob/main/lib/dspy/anthropic/README.md)
   - [Gemini](https://github.com/vicentereig/dspy.rb/blob/main/lib/dspy/gemini/README.md)
   - [Sorbet::Toon codec](https://github.com/vicentereig/dspy.rb/blob/main/lib/sorbet/toon/README.md)
2. **Flip Enhanced Prompting defaults** – set `schema_format: :baml` and `data_format: :toon` globally or per-LM:

   ```ruby
   DSPy.configure do |config|
     config.lm = DSPy::LM.new(
       'openai/gpt-4o-mini',
       api_key: ENV.fetch('OPENAI_API_KEY'),
       schema_format: :baml,
       data_format: :toon
     )
   end
   ```

3. **ReAct/tooling** – If you extend `DSPy::ReAct`, make sure history/tool rendering uses the built-in helpers (now TOON-aware) instead of hand-built JSON.
4. **Benchmarks (optional)** – Point stakeholders to `examples/baml_vs_json_benchmark.rb` for reproducible token savings across schema/data combinations.

## Example snippets

### Structured outputs with TOON payloads

```ruby
class TaskDecomposition < DSPy::Signature
  input  { const :goal, String }
  output { const :tasks, T::Array[T::Hash[String, String]] }
end

predictor = DSPy::Predict.new(TaskDecomposition)
result = predictor.call(goal: "Draft a DSPy smoke test plan")
```

`DSPy::Prompt` now renders the signature guidance + user inputs in TOON blocks and expects TOON replies, so the JSON keys stop repeating and the LM stays anchored to the schema.

### ReAct loop with TOON history + tools

```ruby
class ToonReActSignature < DSPy::Signature
  input  { const :question, String }
  output { const :answer, String }
end

class CityFact < T::Struct
  const :city, String
  const :population, Integer
end

class ToonLookupTool < DSPy::Tools::Base
  tool_name 'lookup_city'
  tool_description 'Return structured population data for a given city'

  sig { params(city: String).returns(CityFact) }
  def call(city:)
    CityFact.new(city: city, population: 2_148_000)
  end
end

agent = DSPy::ReAct.new(ToonReActSignature, tools: [ToonLookupTool.new], max_iterations: 2)
agent.forward(question: "What is the population of Paris?")
```

Each iteration serializes the history, available tools, and observations as TOON tables (see `spec/integration/toon_react_spec.rb` for the full flow), so tool arguments/results round-trip through Sorbet structs without DTO glue.

## Useful links

- Launch article: `docs/src/_articles/toon-data-format.md`
- Sorbet::Toon README + roadmap: `lib/sorbet/toon/README.md`
- Benchmark artifacts: see the latest `schema_data_benchmark_*.{json,csv,txt}` files in `examples/`
- GitHub compare: https://github.com/vicentereig/dspy.rb/compare/v0.30.1...v0.31.0


## v0.30.1: dspy 0.30.1

**Published**: 2025-10-26

## Highlights
- **Module-scoped listeners** – `DSPy::Module.subscribe` now registers per-instance subscriptions with a `SubcriptionScope` enum. DeepSearch/DeepResearch agents can meter tokens or watch `search.result` events without touching the global bus.
- **Module context metadata** – every `DSPy.event` payload now carries `module_path`, `module_root`, `module_leaf`, and `module_scope.ancestry_token`, making Langfuse/LF-CLI filters trivial.
- **Always-on spans** – even modules that override `forward` now run inside `instrument_forward_call`, so Langfuse/OpenTelemetry traces stay intact.
- **Docs** – new [Event System](https://github.com/vicentereig/dspy.rb/blob/main/docs/src/core-concepts/events.md) page that answers “how do I listen globally?” with examples for `DSPy.events.subscribe('*')` and module-scoped subscriptions.

## Example
```ruby
class DeepSearch < DSPy::Module
  subscribe 'llm.tokens', :meter_tokens # defaults to descendants
  subscribe 'search.result', :self_only,
             scope: DSPy::Module::SubcriptionScope::SelfOnly

  def meter_tokens(_event, attrs)
    @token_count += attrs.fetch(:total_tokens, 0)
  end
end

DSPy.events.subscribe('*') do |event, attrs|
  next unless attrs[:module_leaf]
  puts "[#{event}] leaf=#{attrs[:module_leaf][:class]} tokens=#{attrs[:total_tokens]}"
end
```

Upgrade with:
```
gem update dspy
```


## v0.30.0: v0.30.0

**Published**: 2025-10-25

## Highlights
- **GEPA extraction**: `dspy-gepa` now hosts `DSPy::Teleprompt::GEPA` plus telemetry helpers, so the teleprompter installs only when you add that sibling gem (or set `DSPY_WITH_GEPA=1` inside this repo). Docs and CI cover the new toggle.
- **Observability split**: `dspy-o11y` and `dspy-o11y-langfuse` (both 1.0.0) provide the core observability API + Langfuse adapter. Add those gems—or set `DSPY_WITH_O11Y=1 DSPY_WITH_O11Y_LANGFUSE=1`—before reporting spans.
- **Ruby 3.3 compatibility**: Patched `Warning.warn` delegation so DSPy loads cleanly on Ruby 3.3.6 (#170).
- **Version alignment**: DSPy core is now `0.30.0`; optional siblings (`dspy-code_act`, `dspy-datasets`, `dspy-evals`, `dspy-miprov2`, `dspy-gepa`, `gepa`) each ship at 1.0.0. `dspy-schema` remains a required dependency so downstream projects like `exa-ruby` can reuse the converter, but its code now lives in its own gem.

## Installation Cheat Sheet
```ruby
# GEPA optimizer
gem "dspy"
gem "dspy-gepa", "~> 1.0"   # or export DSPY_WITH_GEPA=1 when bundling locally

# Observability → Langfuse
 gem "dspy"
 gem "dspy-o11y", "~> 1.0"
 gem "dspy-o11y-langfuse", "~> 1.0"   # or set DSPY_WITH_O11Y=1 DSPY_WITH_O11Y_LANGFUSE=1

# MIPROv2 optimizer
gem "dspy"
gem "dspy-miprov2", "~> 1.0"
```

See `adr/012-modular-sibling-gems-roadmap.md` and `adr/013-dependency-tree.md` for the full dependency map. LLM provider adapters (openai/anthropic/gemini) remain bundled in core until the next ADR.

## Fixes & Docs
- `lib/dspy/support/warning_filters.rb` mirrors Ruby 3.3’s signature to unblock `Warning.warn`.
- README, observability/GEPA guides, and ADR-013 call out which sibling gems to install for Langfuse, GEPA, MIPROv2, evals, and CodeAct.


## v0.29.1: v0.29.1

**Published**: 2025-10-20

## What’s New
- Hardened the ADE MIPROv2 example with stratified splits, honest precision accounting, and new integration coverage.
- Restored enum-driven auto presets (light/medium/heavy) for MIPROv2 and surfaced the `--auto` flag in the ADE CLI.
- Candidate deduplication ensures optimization logs show unique instructions.

## Changelog
### Added
- Integration coverage for the ADE optimization example (`spec/integration/examples/ade_optimizer_integration_spec.rb`) guaranteeing malformed model outputs reduce precision below 100%.

### Changed
- The ADE MIPROv2 CLI now stratifies train/val/test splits and treats malformed predictions as false positives/negatives, eliminating misleading perfect-precision runs.
- Restored enum-driven MIPROv2 auto presets (`light`, `medium`, `heavy`) and surfaced the `--auto` flag in `examples/ade_optimizer_miprov2/main.rb`.
- Candidate generation deduplicates repeated instructions so trial logs and optimization history highlight unique prompt variants.

### Documentation
- Refreshed ADE optimization docs (`examples/`, `docs/src/optimization/miprov2.md`) to describe preset usage, stratified splits, and the new error handling defaults.


## v0.29.0: v0.29.0

**Published**: 2025-10-19

## Highlights
- GEPA teleprompter (Genetic-Pareto Reflective Prompt Evolution, Phase 0) lands on Ruby with merge proposer, reflective mutation utilities, experiment tracking shims, and a new ADE optimizer example. (#148)
- MIPROv2 optimizer catches up with the Python reference: bootstrap strategies, dataset summary generation, and Layer 3 utilities for multi-predictor programs. (#147, #146, #145, #144)
- OTLP exporter now runs on a single-thread executor to prevent frozen SSL contexts while keeping span queuing non-blocking. (#154)

## Examples
- `bundle exec ruby examples/ade_optimizer_gepa/main.rb --limit 1200 --trials 6`
- `bundle exec ruby examples/gepa_snapshot.rb`

## Docs
- New GEPA guide (`docs/src/optimization/gepa.md`) walks through feedback maps, logging, and reflection LM setup.
- Observability articles note the executor-driven exporter so telemetry stays off the hot path.

## Upgrading
- No breaking changes. Update to `gem "dspy", "~> 0.29.0"` and run `bundle install`.


## v0.28.2: v0.28.2 - BAML Schema Format & MIPROv2 Enhancements

**Published**: 2025-10-13

## 🚀 BAML Schema Format Support

DSPy.rb v0.28.2 introduces **BAML schema format support** for dramatically reduced token consumption in complex signatures.

### Key Highlights

- **85% Token Reduction**: Rich 6-field signatures drop from 345 to 50 tokens
- **Universal Compatibility**: Works with all providers in Enhanced Prompting mode
- **Zero Training Required**: Drop-in replacement for JSON Schema
- **Production Ready**: Comprehensive integration tests with real-world benchmarks

### Quick Start

```ruby
DSPy.configure do |c|
  c.lm = DSPy::LM.new(
    'openai/gpt-4o-mini',
    schema_format: :baml  # Enable BAML format
  )
end
```

📖 **Read the full story**: [Rich Signatures, Lean Schemas](https://vicentereig.github.io/dspy.rb/blog/articles/baml-schema-format/)

## 🔧 MIPROv2 Python Parity Enhancements

Advanced optimizer improvements for better DSPy ecosystem compatibility:

- Dataset summary generator (Layer 4.1)
- Python-compatible instruction handling with awareness flags (Layer 4.2)
- New utility functions: `get_signature`, `set_signature`, `save_candidate_program`
- Type-safe `BootstrapStrategy` enum
- Enhanced few-shot demo set creation

## 🎯 Additional Features

- **Module Lifecycle Callbacks**: Rails-style before/after hooks for `forward` method
- **Module#save**: Lightweight program state persistence
- **GPT-5 Support**: Extended JSON modes benchmark with latest OpenAI models
- **Better Test Organization**: Separated unit and integration tests

## 📚 Documentation Updates

- New BAML article with charts.css visualizations
- Updated JSON modes comparison with October 2025 data
- Enhanced ADR-008 with Ruby-specific design decisions
- Fixed code examples across documentation

## 🔒 Security

- OpenRouter API keys now redacted in VCR cassettes
- Consistent API key protection across all providers

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/blob/v0.28.2/CHANGELOG.md#0282---2025-10-13

## v0.28.1: v0.28.1 - Bug fix release

**Published**: 2025-10-03

## What's Changed

**Bug Fixes**
- Fix Gemini union type discriminators by converting `const` to `enum` for API compatibility
  - Gemini's `responseJsonSchema` doesn't support the JSON Schema `const` keyword
  - Solution: Convert to single-value `enum` arrays (functionally equivalent)
  - Fixes union type discrimination for Gemini structured outputs

**Performance Improvements**
- Reduce input tokens by 42-51% when using structured outputs
  - Optimized prompts no longer include redundant schema information
  - Schema is sent once via API parameters instead of twice (prompt + parameters)
  - Example: OpenAI sentiment analysis reduced from ~350 to 202 prompt tokens

**Additional Fixes**
- Fix test fixture paths
- Fix require_relative paths after test reorganization

**Features**
- Add GPT-5 and GPT-5-mini model support to JSON modes benchmark

**Documentation**
- Update json-modes article with GPT-5 models and token efficiency insights
- Fix code examples in core-concepts guide
- Fix code examples in quick-start guide
- Remove fictional APIs and fix documentation accuracy
- Update json-modes benchmark with October 2025 results

**Refactoring**
- Reorganize test structure (move to spec/unit and spec/integration)

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.28.0...v0.28.1

## v0.28.0: v0.28.0

**Published**: 2025-10-02

## What's New

### ⚠️ Breaking Changes: Proper Error Handling

ReAct agents and tools now raise explicit exceptions instead of silently masking errors with default values.

**New Exception Classes:**
- `DSPy::ReAct::MaxIterationsError` - raised when agent hits max iterations
- `DSPy::ReAct::InvalidActionError` - raised when LLM chooses unknown action  
- `DSPy::ReAct::TypeMismatchError` - raised when type conversion fails

**Migration:**
```ruby
# Before (0.27.6)
result = agent.forward(query: "...")
if result.answer.nil?
  handle_failure
end

# After (0.28.0)
begin
  result = agent.forward(query: "...")
rescue DSPy::ReAct::MaxIterationsError => e
  handle_max_iterations(e)
rescue DSPy::ReAct::TypeMismatchError => e
  handle_type_error(e)
end
```

### Fixed: ReAct Type Preservation (#133)

ReAct agents no longer stringify structured tool outputs:
- Tool results (T::Struct, arrays, hashes) preserve their types through the agent pipeline
- LLM sees JSON representation while code retains proper Ruby types
- Enables elegant structured data workflows with agents

### Added: Anthropic Structured Outputs Control

New `structured_outputs` parameter for Anthropic adapter:
```ruby
# Tool-based extraction (default, most reliable)
DSPy.configure do |c|
  c.lm = DSPy::LM.new(
    'anthropic/claude-sonnet-4-5-20250929',
    api_key: ENV['ANTHROPIC_API_KEY'],
    structured_outputs: true  # Default
  )
end

# Enhanced prompting extraction (alternative)
DSPy.configure do |c|
  c.lm = DSPy::LM.new(
    'anthropic/claude-sonnet-4-5-20250929',
    api_key: ENV['ANTHROPIC_API_KEY'],
    structured_outputs: false
  )
end
```

### Documentation Updates

- Added comprehensive provider access section showing 200+ models across 5 providers
- Fixed invalid configuration examples across documentation
- Added `examples/basic_search_agent.rb` demonstrating structured output preservation

## Installation

```ruby
gem 'dspy', '~> 0.28.0'
```

## Full Changelog

https://github.com/vicentereig/dspy.rb/compare/v0.27.6...v0.28.0

## v0.27.6: v0.27.6

**Published**: 2025-10-01

## What's New

### Recursive Type Support 🔄

JSON schema generation now handles self-referencing types, fixing stack overflow errors with recursive T::Struct types like tree structures and mind maps.

- Fixed stack overflow errors with recursive T::Struct types (e.g., tree structures, mind maps)
- Proper `$ref` generation following JSON Schema standards
- Support for nilable and array-wrapped recursive types
- Comprehensive test coverage for recursive patterns

### Unified Type System 🔧

Refactored Anthropic tool use strategy to use centralized type conversion:

- Removed 60 lines of duplicate type conversion code
- All strategies now use `DSPy::TypeSystem::SorbetJsonSchema` for consistency
- Anthropic tool use strategy gains support for recursive types, enums, and union types

### Fixed

- Recursive type handling in JSON schema generation preventing infinite loops

## Installation

```ruby
gem 'dspy', '~> 0.27.6'
```

## Full Changelog

https://github.com/vicentereig/dspy.rb/compare/v0.27.5...v0.27.6

## v0.27.5: v0.27.5

**Published**: 2025-09-30

## What's Fixed

- **ReAct agents now handle typed output fields correctly when max iterations reached** (#129)
  - Fixed TypeError with `T.nilable(T::Array[...])` and other typed outputs
  - Now returns appropriate default values: `nil` for nilable types, `[]` for arrays, `{}` for hashes
  - Added comprehensive test coverage for both nilable and non-nilable typed outputs

## Documentation Improvements

- Updated getting started guides to show proper Sorbet type signatures for Tools
- Emphasized importance of type signatures for reliable LLM tool usage

Closes #129

## v0.27.4: DSPy.rb v0.27.4

**Published**: 2025-09-25

## DSPy.rb v0.27.4

### 🎉 Contributors

Special thanks to **@kovyrin** for their first contribution to DSPy.rb! They implemented the complete OpenRouter integration, bringing support for 100+ LLMs to our library.

### What's New

**OpenRouter Integration** - Complete support for OpenRouter models with intelligent fallback (contributed by @kovyrin):
```ruby
lm = DSPy::LM.new("openrouter/meta-llama/llama-3.3-70b-instruct")
# Automatically falls back to prompting when structured outputs aren't supported
```

**Enhanced Gemini Flash Support** - Extended structured outputs for Gemini 2.0 Flash models with improved reliability

**Security & Infrastructure** - Enhanced test security and CI/CD improvements

### Installation
```bash
gem install dspy -v 0.27.4
```

### Key Features Added
- OpenRouter adapter with automatic structured output fallback (@kovyrin)
- Gemini 2.0 Flash structured outputs support
- Full telemetry coverage for OpenRouter through OpenAIAdapter
- Comprehensive VCR test coverage for new integrations
- Enhanced documentation with OpenRouter setup guide

### Security Improvements
- Fixed NewRelic license key exposure in VCR cassettes
- Improved test infrastructure with standard VCR usage

### Documentation Updates
- New OpenRouter setup and configuration guide
- Updated JSON modes comparison with Gemini 2.0 benchmarks
- Enhanced clarity in technical documentation

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for complete details.

## v0.27.3: DSPy.rb v0.27.3

**Published**: 2025-09-20

## DSPy.rb v0.27.3

### What's New

**GitHub CLI Toolset** - Analyze GitHub repos with natural language:
```ruby
toolset = DSPy::Tools::Toolsets::GitHubCLI.new
agent = DSPy::ReAct.new(tools: toolset.tools)
result = agent.forward("Show me open PRs with failing tests")
```

**ReAct Agent Improvements** - Better reliability with dynamic tool constraints and proper field descriptions (#114)

**Documentation Enhancements** - SEO improvements, OG images, and Charts.css visualizations

### Installation
```bash
gem install dspy -v 0.27.3
```

### Key Features Added
- GitHub CLI toolset with comprehensive read-only operations
- Enhanced ReAct agent with ActionEnum constraints
- AvailableTool struct for better type safety
- Automatic OG image generation for documentation
- Charts.css data visualizations

### Bug Fixes
- Fixed ReAct agent field descriptions not being included
- Improved tool name handling in ReAct processing
- Enhanced security with read-only GitHub operations

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for complete details.

## v0.27.2: DSPy.rb v0.27.2 - Unified Sorbet Type Support

**Published**: 2025-09-16

## 🎉 DSPy.rb v0.27.2 - Unified Sorbet Type Support

### 🚀 Key Features

**Comprehensive Sorbet Type Support for Tools and Toolsets (Resolves #113)**
This release brings Tools and Toolsets to full type parity with Signatures, eliminating the need for manual type conversion and making DSPy.rb significantly more developer-friendly.

- **Automatic JSON-to-Ruby Type Conversion**: All Sorbet types are now automatically converted from JSON parameters
- **T::Enum Support**: String values like `"add"` automatically convert to `Operation::Add` enum instances  
- **T::Struct Support**: Nested hash structures automatically convert to T::Struct instances with recursive conversion
- **Collection Types**: T::Array and T::Hash support with proper element and value type coercion
- **Advanced Types**: T.nilable and T.any (union) type handling with automatic type resolution
- **Consistent Schema Generation**: Identical JSON schema generation across Tools, Toolsets, and Signatures

### 🔧 Improvements

- **Enhanced Type Coercion System**: Comprehensive error handling and validation
- **Unified Type System Architecture**: Consistent behavior across all DSPy components  
- **Improved Documentation**: Enhanced LLM template documentation with comprehensive typed tooling examples
- **Developer Experience**: Better automatic type conversion examples and real-world usage patterns

### 🐛 Bug Fixes

- **Test Infrastructure**: Updated test schema structure for LLM tool compatibility
- **Documentation**: Corrected observability guide inaccuracies
- **Test Isolation**: Resolved issues in Gemini schema converter tests

### 📊 Technical Details

- Implemented `DSPy::TypeSystem::SorbetJsonSchema` module for unified type conversion
- Enhanced `DSPy::Mixins::TypeCoercion` with comprehensive Sorbet type support  
- Updated Tools::Base and Tools::Toolset to use unified type system architecture
- Full backward compatibility maintained with existing tool implementations
- 1941/1942 tests passing (1 non-critical GitHub CLI integration test pending)

### 🔗 Links

- [Full Changelog](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md#0272---2025-09-16)
- [Closes GitHub Issue #113](https://github.com/vicentereig/dspy.rb/issues/113)
- [Documentation](https://vicentereig.github.io/dspy.rb/)

This release represents a significant advancement in DSPy.rb's type safety and developer experience, making tools as type-safe and easy to use as signatures.

## v0.27.1: v0.27.1: Fix OpenTelemetry Context Propagation

**Published**: 2025-09-14

## What's Fixed

### OpenTelemetry Context Propagation for Non-Concurrent Execution

Fixed span nesting issues where `llm.generate` spans appeared as orphaned root traces instead of properly nesting under their parent DSPy module spans.

The issue occurred because OpenTelemetry uses Fiber-local storage for context, which wasn't properly maintained in non-async Ruby execution.

### Solution
- Use thread-specific context keys for proper thread isolation
- Synchronize Fiber storage with Thread storage for OpenTelemetry compatibility
- Ensure context propagates correctly in both async and non-async modes

### Result
Traces now properly nest in Langfuse and other OpenTelemetry consumers:

```
Trace: abc-123-def
├─ ChainOfThought.forward [2000ms]
│  ├─ Module: ChainOfThought
│  └─ llm.generate [1000ms]
│     ├─ Model: gpt-4
│     ├─ Temperature: 0.7
│     └─ Tokens: 100 in / 50 out / 150 total
```

## Installation

```ruby
gem 'dspy', '~> 0.27.1'
```

## Full Changelog
https://github.com/vicentereig/dspy.rb/compare/v0.27.0...v0.27.1

## v0.27.0: DSPy.rb v0.27.0 - Native Gemini Structured Outputs

**Published**: 2025-09-13

## 🎯 Native Gemini Structured Outputs

This release brings **native structured output support for Google Gemini AI**, achieving feature parity with OpenAI and Anthropic providers. DSPy.rb now leverages Gemini's controlled generation capabilities for reliable, type-safe outputs.

### ✨ Key Features

#### Native Gemini Structured Outputs
- **Zero-config integration** - Works automatically with any DSPy signature
- **High reliability** - Uses Gemini's native JSON generation with schema validation
- **Smart fallbacks** - Automatically selects best strategy based on model capabilities
- **Full model support** - Optimized for gemini-1.5-pro and gemini-1.5-flash

### 📝 Usage Example

```ruby
# Enable structured outputs for Gemini
lm = DSPy::LM.new('gemini/gemini-1.5-flash', 
                  api_key: ENV['GEMINI_API_KEY'], 
                  structured_outputs: true)

DSPy.configure { |config| config.lm = lm }

# Define sentiment enum for type safety
class Sentiment < T::Enum
  enums do
    Positive = new
    Negative = new
    Neutral = new
  end
end

# Works automatically with any DSPy signature
class MovieReview < DSPy::Signature
  input :text, desc: "Movie review text"
  output :sentiment, type: Sentiment, desc: "Movie sentiment classification"
  output :score, type: Integer, desc: "Rating from 1-10"
end

predictor = DSPy::Predict.new(MovieReview)
result = predictor.call(text: "This movie was amazing!")
# => { sentiment: Sentiment::Positive, score: 9 }
```

### 🔧 What's New

#### Added
- **Native Gemini Structured Outputs** - Comprehensive support for Google Gemini AI structured generation
  - Uses Gemini's controlled generation with `response_mime_type: "application/json"` and `response_schema`
  - High-priority strategy (priority 100) for optimal selection with Gemini models
  - Full support for `gemini-1.5-pro` and `gemini-1.5-flash` models
  - Automatic schema conversion from DSPy signatures to OpenAPI 3.0 format
  - Seamless fallback to EnhancedPromptingStrategy for unsupported models
  - Zero breaking changes with optional `structured_outputs: true` parameter

#### Improved
- **Type Safety Enhancements** - Better code maintainability and reliability
  - Refactored StrategySelector to use T::Enum for type-safe strategy names
  - Enhanced unit test isolation for schema converter
  - Added comprehensive integration test suite with VCR cassettes

#### Fixed
- **Test Infrastructure** - Improved reliability and isolation
  - Fixed unit test isolation issues in schema converter
  - Updated VCR cassettes with proper SSEVCR format
  - Enhanced evaluation test expectations for validation set length

#### Documentation
- Added comprehensive documentation for Gemini structured outputs usage
- Updated troubleshooting guide with Gemini-specific information
- Enhanced JSON extraction documentation with Gemini examples

### 🔧 Technical Details
- Implemented `DSPy::LM::Adapters::Gemini::SchemaConverter` for OpenAPI 3.0 schema generation
- Added `DSPy::LM::Strategies::GeminiStructuredOutputStrategy` with provider-optimized selection
- Full test coverage: 24 new unit tests and integration test suite
- Performance optimized with schema caching and priority ordering

### 📚 Documentation
- [Gemini Structured Outputs Guide](https://vicentereig.github.io/dspy.rb/_articles/under-the-hood-json-extraction/)
- [Quick Start Guide](https://vicentereig.github.io/dspy.rb/getting-started/quick-start/)
- [Troubleshooting](https://vicentereig.github.io/dspy.rb/production/troubleshooting/)

### 🙏 Acknowledgments
Thanks to all contributors and users for their feedback and support!

### 📦 Installation
```bash
gem install dspy -v 0.27.0
```

Or add to your Gemfile:
```ruby
gem 'dspy', '~> 0.27.0'
```

## v0.26.1: v0.26.1 - MIPROv2 dry-configurable Refactoring

**Published**: 2025-09-10

## 🎯 MIPROv2 Configuration Modernization

This release modernizes the MIPROv2 optimizer with a clean, dry-configurable-based configuration system, removing configuration classes in favor of Ruby-idiomatic configuration blocks.

### ✨ New Features

**🔧 Modern Configuration Pattern**
- **Class-level configuration** affects all instances:
  ```ruby
  DSPy::Teleprompt::MIPROv2.configure do |config|
    config.optimization_strategy = :bayesian
    config.num_trials = 30
    config.bootstrap_sets = 10
  end
  ```
- **Instance-level configuration** overrides class defaults:
  ```ruby
  optimizer = DSPy::Teleprompt::MIPROv2.new(metric: metric)
  optimizer.configure do |config|
    config.num_trials = 15
    config.optimization_strategy = :adaptive
  end
  ```

**🎛️ Type-Safe Optimization Strategies**
- Use symbols instead of strings: `:greedy`, `:adaptive`, `:bayesian`
- Automatic coercion to T::Enum values with validation
- Better IDE support and type safety

**📊 Simplified Data Structures**
- Replaced `CandidateConfig` with `EvaluatedCandidate` Data class
- Immutable, type-safe candidate representation
- Cleaner serialization and debugging

### 🚨 Breaking Changes

- **REMOVED: `MIPROv2Config` class** - Use `DSPy::Teleprompt::MIPROv2.configure` blocks
- **CHANGED: optimization_strategy values** - Use symbols (`:greedy`) instead of strings (`"greedy"`)
- **RENAMED: `CandidateConfig` → `EvaluatedCandidate`** - Now a simple Data class

### 🔧 Migration Guide

**Old Pattern:**
```ruby
config = DSPy::Teleprompt::MIPROv2Config.new
config.num_trials = 15
config.optimization_strategy = "adaptive"
optimizer = DSPy::Teleprompt::MIPROv2.new(config: config)
```

**New Pattern:**
```ruby
optimizer = DSPy::Teleprompt::MIPROv2.new(metric: metric)
optimizer.configure do |config|
  config.num_trials = 15
  config.optimization_strategy = :adaptive
end
```

### 🛠️ Internal Improvements

- Enhanced test coverage for configuration patterns
- Fixed test state isolation issues
- Added New Relic to VCR ignore list
- Improved error messages and validation
- Better documentation examples

### 📚 Documentation

All documentation has been updated to reflect the new configuration patterns:
- [MIPROv2 Optimization Guide](https://vicentereig.github.io/dspy.rb/optimization/miprov2/)
- [LLM-friendly API docs](https://vicentereig.github.io/dspy.rb/llms.txt)

---

**What's Next:** This modernization sets the foundation for enhanced optimization features and better Ruby ecosystem integration as we approach v1.0.

## v0.26.0: v0.26.0: Real Bayesian Optimization in MIPROv2

**Published**: 2025-09-09

## 🚀 Major Release: Real Bayesian Optimization in MIPROv2

DSPy.rb v0.26.0 brings state-of-the-art Bayesian optimization to the MIPROv2 prompt optimizer, making it one of the most sophisticated prompt optimization tools available in any language.

### ✨ Highlights

#### Real Bayesian Optimization with Gaussian Processes
- **Pure Ruby Implementation**: Zero external dependencies - no LAPACK, OpenBLAS, or complex system libraries required
- **Intelligent Exploration**: Upper Confidence Bound (UCB) acquisition function balances exploration and exploitation
- **Robust Fallbacks**: Gracefully degrades to adaptive selection when GP fails or has insufficient data
- **Production Ready**: Comprehensive test coverage ensures reliability

#### Cleaner, More Ruby-Idiomatic API
```ruby
# New dry-configurable pattern
optimizer = DSPy::Teleprompt::MIPROv2.new
optimizer.configure do |config|
  config.optimization_strategy = :bayesian  # Use real Bayesian optimization
  config.num_trials = 30
  config.population_size = 10
end
```

### 🎯 What's New

- **Gaussian Process Implementation** (`DSPy::Optimizers::GaussianProcess`)
  - Sophisticated kernel functions and matrix operations
  - Pure Ruby implementation with numo-narray for numerical computations
  - No external LAPACK/OpenBLAS dependencies

- **Three Optimization Strategies**
  - `greedy`: Fast, deterministic selection
  - `adaptive`: Balanced exploration/exploitation with epsilon-greedy
  - `bayesian`: State-of-the-art GP-based optimization with UCB

- **Improved Dependencies**
  - Replaced unused polars-df with lightweight numo-narray
  - Faster installation, fewer conflicts
  - Simpler deployment with no system dependencies

### 📚 Documentation Updates

Comprehensive documentation updates including:
- New Bayesian optimization examples
- Configuration patterns with dry-configurable
- Performance benchmarks and comparisons
- Migration guide for existing MIPROv2 users

### 🔧 Technical Details

The Bayesian optimization implementation uses:
- Radial Basis Function (RBF) kernel for similarity measurement
- Cholesky decomposition for efficient matrix inversion
- Upper Confidence Bound (UCB) acquisition function
- Automatic hyperparameter tuning for kernel parameters

### 💪 Backward Compatibility

All existing MIPROv2 code continues to work without changes. The new features are opt-in through configuration.

### 📦 Installation

```bash
gem install dspy
# or in your Gemfile
gem 'dspy', '~> 0.26.0'
```

No additional system dependencies required!

### 🙏 Acknowledgments

This release represents a significant advancement in prompt optimization technology, bringing research-grade Bayesian optimization to production Ruby applications.

---

For detailed usage examples and migration guide, see the [documentation](https://dspy.ai/optimization/miprov2/).

## v0.25.1: v0.25.1: Telemetry Optimization

**Published**: 2025-09-08

## 🚀 Highlights

- **60-second telemetry export interval** (60x reduction in network calls)
- **Aligned with New Relic's proven harvest cycle pattern**
- **Comprehensive architecture documentation** with industry comparisons
- **Production-ready memory protection** with acceptable trade-offs

## What's Changed

### Telemetry Optimization
- Changed default export interval from 1 second to 60 seconds
- Matches New Relic's 60-second harvest cycle exactly
- Reduces network overhead while maintaining observability
- Configurable via `DSPY_TELEMETRY_EXPORT_INTERVAL` environment variable

### Enhanced Documentation  
- Added production trade-offs section explaining memory protection
- Documents FIFO span dropping under extreme load scenarios
- Updated architectural comparison table with New Relic patterns
- Acknowledges acceptable sample loss prioritizing application stability

### Technical Details
- `DEFAULT_EXPORT_INTERVAL` changed from 1.0 to 60.0 seconds in AsyncSpanProcessor
- Queue size limits (1000 spans) prevent unbounded memory growth
- FIFO span dropping with `observability.span_dropped` logging
- Maintains backward compatibility for all existing configurations

## 📊 Performance Impact

- **60x reduction** in telemetry network calls (from every 1s to every 60s)
- **Improved batch efficiency** with larger span collections per export
- **Industry alignment** with New Relic's battle-tested approach
- **<50ms overhead** maintained while reducing network chatter

## 🛠️ Migration

No breaking changes - existing applications work unchanged. To customize:

```bash
# Optional: Configure export interval (default is now 60 seconds)
export DSPY_TELEMETRY_EXPORT_INTERVAL=30.0  # seconds

# Optional: Configure queue size (default 1000)  
export DSPY_TELEMETRY_QUEUE_SIZE=2000

# Optional: Configure batch size (default 100)
export DSPY_TELEMETRY_BATCH_SIZE=200
```

## Complete Changelog

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for full details including all releases from v0.22.1 through v0.25.1.

## v0.25.0: v0.25.0: Async Telemetry & Enhanced Observability

**Published**: 2025-09-07

## 🚀 DSPy.rb v0.25.0: Async Telemetry & Enhanced Observability

This release introduces significant performance improvements and enhanced observability features that make DSPy.rb even more production-ready.

## ✨ Features

### 🔄 **Async Telemetry & Non-Blocking Observability**
- **AsyncSpanProcessor**: Non-blocking telemetry exports that don't slow down your application
- **True Async Retry Handling**: LLM retries now happen in the background without blocking request threads
- **Enhanced Performance**: Rails controllers stay responsive even during LLM failures and retries

### 📊 **Comprehensive Langfuse Integration** 
- **Zero-Config Setup**: Just set environment variables and telemetry flows automatically
- **Rich Span Reporting**: Complete input/output capture, hierarchical nesting, accurate timing
- **Proper Observation Types**: Correctly maps to Langfuse `generation`, `chain`, and `span` types
- **Token Usage Tracking**: Detailed cost and performance monitoring

### ⚡ **Concurrent LLM Processing**
- **Performance Optimizations**: New concurrent processing patterns for LLM operations
- **GEPA Optimizer Improvements**: Eliminated simple_mode, always uses full optimization for better results

## 🐛 Fixes

- **Span Nesting**: Fixed proper span nesting with hybrid Thread/Fiber context storage
- **GEPA Test Stability**: Resolved test failures and type errors in the GEPA optimizer
- **ChainOfThought Duration**: Fixed 0.00s duration issue by improving observation type mapping  
- **Async Functionality**: Improved async operation test coverage and reliability
- **Observability Serialization**: Fixed issues with serialized structs in telemetry

## 📚 Documentation

- **New Article**: [Observability in Action with Langfuse](https://vicentereig.github.io/dspy.rb/blog/articles/observability-in-action-langfuse/)
- **New Article**: [Concurrent LLM Processing Performance Gains](https://vicentereig.github.io/dspy.rb/blog/articles/concurrent-llm-processing-performance-gains/)
- **New Article**: [True Concurrency: Async Retry System](https://vicentereig.github.io/dspy.rb/blog/articles/async-telemetry-optimization/)
- **Updated**: GEPA optimizer documentation to match implementation
- **Updated**: Async retry documentation with new behavior

## 🔄 Dependencies

- Bumped `async` to ~> 2.29
- Updated various development dependencies for improved compatibility

## 🛠️ Breaking Changes

None! This is a feature release that maintains full backward compatibility.

## 📦 What's Next

- Enhanced toolset system improvements
- Additional observability provider integrations
- Performance optimizations for large-scale deployments

---

**Installation:**
```bash
gem install dspy -v 0.25.0
```

**Upgrade:**
```bash
bundle update dspy
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.24.2...v0.25.0

## v0.24.2: 🔧 DSPy.rb v0.24.2 - Langfuse Timing Fix

**Published**: 2025-09-05

## 🔧 Langfuse Timing Improvements

This patch release addresses the 0.00s duration issue in Langfuse traces with enhanced timing attributes.

### ✨ Improvements

**🕐 Enhanced Span Timing:**
- **Explicit Duration Attributes**: Added `duration.ms` attribute to all spans for accurate timing display
- **ISO8601 Timestamps**: Added `langfuse.observation.startTime` and `langfuse.observation.endTime` for precise timing correlation
- **Better Langfuse Integration**: Spans now show actual durations instead of 0.00s placeholders

**📝 Operation Naming Consistency:**
- **Fixed ChainOfThought Naming**: Now uses `DSPy::ChainOfThought.forward` instead of hardcoded `ChainOfThought.forward`
- **Consistent Namespacing**: All module operations now follow the same `#{self.class.name}.forward` pattern

### 🚀 Getting Started

```bash
gem update dspy
```

### 🛡️ Backward Compatibility

**Zero breaking changes** - this is a patch release that enhances existing functionality without API changes.

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.24.1...v0.24.2

## v0.24.1: 🚀 DSPy.rb v0.24.1 - Enhanced Langfuse Integration

**Published**: 2025-09-05

## 🎯 Enhanced Langfuse Integration

This release brings **comprehensive OpenTelemetry span reporting improvements** to DSPy.rb, delivering production-ready observability with zero configuration.

### ✨ Key Improvements

**🔍 Enhanced Span Reporting:**
- **Proper Input/Output Capture**: LLM calls and module executions now include complete input/output data
- **Hierarchical Span Nesting**: Clear parent-child relationships showing the complete execution flow  
- **Accurate Timing**: Real span durations instead of 0.00s placeholders
- **Correct Observation Types**: Proper Langfuse observation types (`generation`, `chain`, `span`, `event`)
- **Trace Naming**: Meaningful trace names for better organization

**🛠 Technical Enhancements:**
- **GPT-5 Model Support**: Full support for OpenAI's GPT-5 models with proper temperature constraints
- **Temperature Auto-Configuration**: Automatic temperature=1.0 for GPT-5/GPT-4o models per API requirements
- **Fixed Langfuse Endpoint**: Corrected OTLP endpoint to `/api/public/otel/v1/traces`
- **Enhanced Context Management**: Improved OpenTelemetry context handling and span lifecycle

### 🖼️ What You'll See in Langfuse

The release includes screenshots showing the dramatic improvement in trace visibility:

**Before v0.24.1:**
- Empty trace names
- 0.00s durations  
- Missing input/output data
- Flat span structure

**After v0.24.1:**
- Named traces with clear hierarchy
- Accurate timing measurements
- Complete input/output capture
- Proper observation types for each operation

### 🚀 Getting Started

```bash
gem update dspy
```

Set your Langfuse environment variables and enjoy comprehensive observability:

```bash
export LANGFUSE_PUBLIC_KEY=pk-lf-your-public-key
export LANGFUSE_SECRET_KEY=sk-lf-your-secret-key
export LANGFUSE_HOST=https://cloud.langfuse.com  # Optional
```

### 📚 Documentation

- **[Enhanced Langfuse Integration Guide](https://vicentereig.github.io/dspy.rb/production/observability/)**
- **[OpenTelemetry Semantic Conventions](https://vicentereig.github.io/dspy.rb/production/observability/#genai-semantic-conventions)**

### 🛡️ Backward Compatibility

**Zero breaking changes** - all existing DSPy.rb applications automatically benefit from enhanced observability without any code modifications.

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.23.0...v0.24.1

## v0.24.0: v0.24.0 - GEPA Optimization Fixes

**Published**: 2025-09-05

## 🔧 Fixes

### GEPA Optimization
- **Fixed GEPA to work with any signature field names** - No longer hard-coded to expect 'answer' field
- **Fixed DSPy::Example.new calls** throughout examples to use `signature_class:` parameter  
- **Fixed optimizer constructors** and OptimizationResult handling for MIPROv2 and GEPA
- **Fixed ChainOfThought compatibility** with signatures that already have reasoning fields

### Examples Organization  
- **Moved GEPA examples to `examples/gepa/`** for better organization
- **Added dotenv loading** to all examples that require API keys
- **Updated examples README** with clear, concise documentation
- **Fixed all example scripts** to work correctly with the latest API

## 🚀 What's Working

- ✅ **GEPA minimal test** - Basic optimization workflow  
- ✅ **GEPA simple benchmark** - MIPROv2 vs GEPA comparison
- ✅ **All examples load environment variables** from project root `.env`
- ✅ **Signature-agnostic optimization** works with any field names

## 🏃 Quick Start

```bash
# Install
gem install dspy

# Set up API keys in .env file
echo "OPENAI_API_KEY=your-key" > .env

# Run GEPA example
bundle exec ruby examples/gepa/minimal_gepa_test.rb
```

All GEPA examples now work correctly with proper optimization comparisons!

## v0.23.0: v0.23.0 - GEPA Optimizer

**Published**: 2025-09-05

## 🚀 GEPA Phase 2: Advanced AI Optimization

This major release completes **GEPA (Genetic-Pareto) Phase 2**, introducing production-ready genetic algorithm-based optimization for LLM applications.

## ✨ Major Features

### 🧬 Genetic Algorithm Optimization
- **Multi-objective optimization** with Pareto-optimal solution selection
- **Advanced crossover strategies** for prompt evolution
- **Mutation engines** for exploration of solution spaces
- **Fitness evaluation** with comprehensive metrics

### 📊 Production-Ready Examples
- Complete benchmark suite in `examples/` directory
- Real-world optimization scenarios
- Performance comparison tools

### 🛠️ Enhanced GEPA Infrastructure
- **Reflection Engine** improvements for deeper analysis
- **Module Evaluator** with advanced scoring
- **Crossover Engine** for genetic operations
- **Pareto Selector** for multi-criteria optimization

## 🐛 Bug Fixes
- Fixed memory compaction batch processing with informers gem compatibility
- Resolved CI test failures in embedding engine

## 📈 Performance Improvements
- Optimized genetic algorithm convergence
- Enhanced evaluation pipeline efficiency
- Improved memory usage in batch operations

## 🔬 Research & Development

**GEPA Phase 3 Development Continues:**
- See issues #92, #91, #90 for ongoing advanced optimization research
- Neural architecture evolution
- Adaptive hyperparameter tuning
- Distributed optimization strategies

## 🎯 What's Next

GEPA Phase 3 will introduce even more advanced optimization techniques including:
- **Neural Evolution** - Automated model architecture optimization
- **Hyperparameter Evolution** - Self-tuning optimization parameters  
- **Distributed GEPA** - Multi-node optimization clusters

## 📖 Documentation

- New [GEPA Optimization Guide](https://vicentereig.github.io/dspy.rb/optimization/gepa/)
- Complete API reference for genetic algorithms
- Production deployment examples

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.22.1...v0.23.0

## v0.22.1: v0.22.1 - Type Coercion Bug Fix

**Published**: 2025-09-05

## Fixed
- **Type Coercion Bug** - Direct T::Struct fields now properly handle `_type` discriminator filtering (by [@liorbrauer](https://github.com/liorbrauer))
  - Previously only union types (T.any) correctly filtered out DSPy's internal `_type` field
  - Direct struct fields would fail with "Can't set field to {\"_type\"=>...}" errors
  - Added recursive type coercion for nested structs at any depth
  - Smart filtering preserves legitimate user-defined `_type` fields

## Documentation
- **Type Discriminator Pattern** - Comprehensive documentation of DSPy's `_type` field handling
  - Explains automatic discriminator field injection for JSON schemas
  - Documents reserved `_type` field name and filtering behavior
  - Shows real JSON schema structure with `oneOf` and `const` constraints
  - Covers both union types and direct struct fields

## Technical Details
- Enhanced `coerce_struct_value` method to match `coerce_union_value` behavior
- Added 15+ comprehensive tests covering direct struct coercion scenarios
- Maintains backward compatibility - no breaking changes

## Contributors
Special thanks to [@liorbrauer](https://github.com/liorbrauer) for identifying and fixing this critical bug that was affecting direct struct field usage in DSPy signatures.

## v0.22.0: v0.22.0

**Published**: 2025-09-03

## Event-Driven Observability System

This release adds a new event system that replaces complex monkey-patching approaches with a simple, Rails-like API.

### What's New

**Event System API**
- `DSPy.event(name, attributes)` - Simple event emission 
- `DSPy.events.subscribe(pattern) { |name, attrs| }` - Pattern-based listening
- `DSPy::Events::BaseSubscriber` - Foundation for custom subscribers

**Type-Safe Events**  
- `DSPy::Events::LLMEvent` with OpenTelemetry semantic conventions
- `DSPy::Events::ModuleEvent` for tracking module execution
- `DSPy::Events::OptimizationEvent` for training progress
- Sorbet T::Struct validation

**Automatic Benefits**
- All existing `DSPy.log()` calls now emit events (no code changes needed)
- Events create OpenTelemetry spans when observability is enabled
- Seamless Langfuse export via existing integration
- Thread-safe event processing

### For Developers

**Before** (complex monkey-patching):
```ruby
module ContextInterceptor
  def with_span(operation:, **attributes)
    # complex override logic
    super
  end
end
DSPy::Context.singleton_class.prepend(ContextInterceptor)
```

**After** (clean subscribers):
```ruby
class TokenTracker < DSPy::Events::BaseSubscriber
  def subscribe
    add_subscription('llm.*') { |name, attrs| track_tokens(attrs) }
  end
end
```

### Examples
- `examples/event_system_demo.rb` - Working demonstration
- `spec/support/event_subscriber_examples.rb` - Token budget and optimization tracking
- Updated documentation with practical patterns

### Backward Compatibility
- Zero breaking changes
- All existing DSPy.log() calls work unchanged but get enhanced capabilities
- Existing Langfuse integration preserved and enhanced

### References
- Addresses GitHub issue #69
- Pull request #85

## v0.21.0: v0.21.0: Type Alias Support

**Published**: 2025-09-01

## What's Changed

### 🚀 New Features
- **Comprehensive Type Alias Support** - DSPy.rb now fully supports Sorbet type aliases (T.type_alias)
  - LLMs receive proper JSON schemas with realistic examples instead of generic placeholders
  - Enhanced example generation for complex nested structures, arrays, and union types
  - Enables cleaner code organization with reusable type definitions

### 📚 Documentation
- **Improved Attribution** - Clarified DSPy.rb's relationship as an idiomatic Ruby port of Stanford's DSPy framework
- Added Stanford attribution to documentation homepage
- Updated README with explicit port relationship explanation

### 🔧 Technical Details
- Type aliases are now properly resolved to their underlying T::Types::FixedHash structures
- Enhanced prompting strategy generates proper examples for complex nested structures
- Added 9 comprehensive tests covering schema generation and example generation scenarios
- Maintains backward compatibility with existing DSPy.rb applications

### Contributors
This release features a major contribution from:
- **[@TheDumbTechGuy](https://github.com/TheDumbTechGuy)** (Stefan Froelich) - Complete type alias support implementation

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.20.1...v0.21.0

## v0.20.1: v0.20.1: Documentation Fixes and Improvements

**Published**: 2025-08-27

## What's Changed

### 🐛 Bug Fixes
- Fixed canonical URLs for 16 blog articles
- Corrected article layout configuration for proper SEO
- Removed non-existent Gemini models from vision_models.rb

### 📚 Documentation
- Added v0.20.0 release announcement blog post
- Corrected misleading raw_chat API documentation
- Various documentation improvements

### Commits
- fix(docs): correct canonical URLs and documentation accuracy (43d5363)
- docs: edits (6e5f3e8)
- docs: add v0.20.0 release announcement blog post (b9089a6)

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.20.0...v0.20.1

## v0.20.0: v0.20.0: Google Gemini Integration & Fiber-Local Contexts

**Published**: 2025-08-26

## 🚀 Major Release: Google Gemini Integration & Fiber-Local Contexts

DSPy.rb v0.20.0 brings powerful new capabilities with Google Gemini API support, fiber-local language model contexts, and enhanced program serialization. This release represents significant progress on our roadmap with contributions from [@TheDumbTechGuy](https://github.com/TheDumbTechGuy) and continued development efforts.

### ✨ New Features

#### 🤖 Google Gemini API Integration
- **Complete Gemini Support** - All models: `gemini-1.5-flash`, `gemini-1.5-pro`, `gemini-1.0-pro`
- **Native Multimodal** - Text and image processing with type-safe structs
- **Dual Client Architecture** - Streaming and non-streaming support
- **Advanced Error Handling** - Gemini-specific error messages and recovery
- **Token Usage Tracking** - Cost monitoring and response metadata
- **Provider Validation** - Clear compatibility warnings

#### 🧵 Fiber-Local LM Context Management  
- **DSPy.with_lm Method** - Temporary language model overrides
- **Ruby Fiber-Local Storage** - Clean, thread-safe context management
- **Nested Context Support** - Multiple levels with automatic cleanup
- **Exception Safety** - Guaranteed cleanup on errors
- **Concurrent Patterns** - Perfect for A/B testing and environment switching

#### 💾 Program Serialization & Persistence
- **Enhanced from_h Method** - Restore saved programs from serialized data
- **Complete State Preservation** - Instructions, examples, and configuration
- **Version Compatibility** - DSPy and Ruby version tracking
- **Import/Export Support** - Cross-environment program migration
- **Automatic State Reconstruction** - All module types supported

#### 🔧 MIPROv2 Optimizer Improvements
- **Bootstrap Phase Fix** - Resolved infinite loop hanging issues
- **Metric Parameter Support** - Flexible optimization configuration  
- **Enhanced Serialization** - Better JSON output for debugging
- **Improved Error Recovery** - More robust optimization phases
- **Better Observability** - Enhanced tracking and monitoring

### 📚 Documentation & Community

#### New Guides
- **[Fiber-Local LM Contexts Guide](https://dspy.services/articles/fiber-local-lm-contexts)** - Comprehensive usage patterns
- **[Google Gemini Provider Documentation](https://dspy.services/articles/introducing-google-gemini-support)** - Complete integration guide  
- **[Program Persistence Guide](https://dspy.services/articles/program-persistence-and-serialization)** - Save and load optimized programs

#### Enhanced Documentation
- **CONTRIBUTORS.md** - Recognizing Stefan Froelich's transformational contributions
- **Updated Multimodal Docs** - Gemini provider information and examples
- **Installation Guide Updates** - Removed pre-release warnings, gem availability
- **Provider Comparison Matrix** - OpenAI vs Anthropic vs Gemini features

### 🛠 Fixed Issues
- **CodeAct/ReAct Signature Tracking** - Improved agent observability
- **Grounded Proposer Enum Extraction** - Better instruction generation
- **Optimization Trace Serialization** - Enhanced JSON output for debugging

### 🎯 Roadmap Progress
This release advances several key priorities:
- ✅ **Provider Expansion** - Google Gemini integration complete
- ✅ **Better Context Management** - Fiber-local LM contexts implemented  
- ✅ **Improved Persistence** - Enhanced program serialization system
- ✅ **Optimizer Reliability** - MIPROv2 stability improvements

### 🔄 Breaking Changes
**None** - Full backward compatibility maintained with existing DSPy.rb applications.

### 📦 Installation

```bash
gem install dspy
# or add to Gemfile
gem 'dspy', '~> 0.20.0'
```

### 🙏 Contributors

Special recognition for this release:
- **[@TheDumbTechGuy](https://github.com/TheDumbTechGuy)** (Stefan Froelich) - 9 major commits including Gemini integration, fiber-local contexts, program persistence, and MIPROv2 improvements
- **[@vicentereig](https://github.com/vicentereig)** - Documentation, multimodal enhancements, and site improvements

### 🔗 Quick Start

```ruby
require 'dspy'

# Configure with Gemini
DSPy.configure do |c|
  c.lm = DSPy::LM.new('gemini/gemini-1.5-flash', api_key: ENV['GEMINI_API_KEY'])
end

# Use fiber-local contexts for temporary model switching
DSPy.with_lm(fast_model) do
  result = analyzer.call(text: "Amazing new features!")
end

# Multimodal with type safety
result = analyzer.forward(
  image: DSPy::Image.new(base64: image_data),
  text: "Analyze this image"
)
```

### 📈 What's Next
- Enhanced optimization algorithms
- Additional provider integrations  
- Advanced agentic workflows
- Production tooling improvements

**Full Changelog**: [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md)

## v0.19.1: v0.19.1: Fix Integration Test

**Published**: 2025-08-11

## 🔧 Bug Fix Release

Fixed a failing integration test that was causing CI issues.

### What's Fixed
- Integration test for error formatting now properly triggers the expected TypeError
- Test was simplified to directly create structs instead of relying on dynamic struct creation from predict.rb

### No Functional Changes
This is purely a test fix - the error formatting functionality from v0.19.0 remains unchanged and working perfectly.

### Installation
```bash
gem install dspy
```

## v0.19.0: v0.19.0: Human-Readable Error Messages

**Published**: 2025-08-11

## 🎯 Better Error Messages

No more cryptic Sorbet type errors\! This release transforms confusing type validation messages into clear, actionable feedback.

### Before
```
Parameter 'drug_symptom_pairs': Can't set .drug_symptom_pairs to [...] (instance of Array) - need a T::Array[DrugSymptomPair]
```

### After
```
Type Mismatch in 'drug_symptom_pairs'

Expected: T::Array[DrugSymptomPair] 
Received: Array (plain Ruby array)

The LLM returned a plain Ruby array with hash elements, but your signature requires an array of DrugSymptomPair struct objects.

Suggestions:
• Check your signature uses proper T::Array[DrugSymptomPair] typing
• Verify the LLM response format matches your expected structure
• Ensure your struct definitions are correct and accessible
```

### What's New
- **Human-readable error formatting** for type validation failures
- **Actionable suggestions** based on the specific error type  
- **Clean output** - removes internal stack traces
- **Backward compatible** - existing rescue patterns still work
- Handles Array/Struct mismatches, missing fields, enum errors

### For Developers
Debugging DSPy applications just got way easier. No more digging through Sorbet internals to understand what went wrong\!

### Installation
```bash
gem install dspy
```

## v0.18.1: v0.18.1: ChainOfThought Observability Fix

**Published**: 2025-08-10

## 🐛 Bug Fix

### Fixed ChainOfThought Signature Name Tracking

This patch release fixes an observability issue where `dspy.signature=nil` appeared in logs when using ChainOfThought modules.

## What's Changed

- **Fixed**: Enhanced signature classes created by ChainOfThought now preserve the original signature name
- **Fixed**: Properly tracks signature names in span tracking and reasoning analysis events  
- **Fixed**: Logging now shows actual signature name (e.g., `MathProblemSolver`) instead of `nil`
- **Added**: Comprehensive test coverage for signature name preservation

## Technical Details

The issue occurred because ChainOfThought creates anonymous enhanced signature classes that didn't have a proper `.name` method. The fix stores and returns the original signature name, ensuring proper tracking throughout the observability pipeline.

### Example
Before: `dspy.signature=nil`
After: `dspy.signature="MathProblemSolver"`

## Installation

```bash
gem install dspy -v 0.18.1
```

Or in your Gemfile:
```ruby
gem 'dspy', '~> 0.18.1'
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.18.0...v0.18.1

## v0.18.0: v0.18.0: Zero-Config Langfuse Integration

**Published**: 2025-08-08

## Zero-Config Langfuse Integration

DSPy.rb 0.18.0 introduces automatic Langfuse integration via OpenTelemetry. Set your API keys and get production-ready observability without any configuration.

### What's New

**Zero-Configuration Observability**
```bash
# Just set these environment variables
export LANGFUSE_PUBLIC_KEY=pk-lf-your-key
export LANGFUSE_SECRET_KEY=sk-lf-your-key

# DSPy automatically exports traces to Langfuse\!
```

**Dual Output System**
- **Structured logs** (as before): JSON in production, key=value in development  
- **OpenTelemetry spans** (new): Automatic export to Langfuse when configured
- **GenAI conventions**: Proper `gen_ai.*` attributes for LLM operations
- **Graceful fallback**: Works with logging-only if OTEL setup fails

### How It Works

Your existing DSPy code automatically gets rich traces in Langfuse:

```ruby
# This code now creates both logs AND Langfuse traces
classifier = DSPy::Predict.new(SentimentSignature)
result = classifier.call(sentence: "This is awesome\!")

# In Langfuse you'll see:
# ├─ DSPy::Predict.forward [1200ms]
# │  ├─ Model: gpt-4o-mini  
# │  ├─ Tokens: 45 in / 12 out / 57 total
# │  └─ Cost: $0.0034 (calculated by Langfuse)
```

### Benefits

- **No code changes required** - existing applications work immediately
- **Production ready** - proper authentication, error handling, compression  
- **Standards compliant** - uses OpenTelemetry GenAI semantic conventions
- **Non-invasive** - logging continues to work without Langfuse
- **Minimal overhead** - ~100 lines of new code, lazy initialization

### Implementation Details

The new `DSPy::Observability` module:
- Auto-detects Langfuse environment variables
- Configures OpenTelemetry SDK with proper OTLP exporter  
- Uses Basic Auth with correct Langfuse endpoints
- Filters nil attributes (required by OpenTelemetry)
- Handles network failures and missing dependencies gracefully

Enhanced `DSPy::Context.with_span` now:
- Maintains all existing logging functionality
- Additionally creates OpenTelemetry spans when configured
- Preserves parent-child span relationships
- Includes proper GenAI semantic attributes

### Observability System Evolution

This release completes the observability system modernization:
- **v0.15.x**: Removed complex 4,000-line instrumentation system
- **v0.16.x-v0.17.x**: Built simple 150-line Context-based logging  
- **v0.18.0**: Added zero-config Langfuse integration via OpenTelemetry

### Migration

**From old instrumentation system (removed in v0.15.x):**
```ruby
# Old (no longer works)
DSPy.configure do |config|
  config.instrumentation.enabled = true
  config.instrumentation.subscribers = [:langfuse]
end

# New (automatic)
export LANGFUSE_PUBLIC_KEY=pk-lf-your-key
export LANGFUSE_SECRET_KEY=sk-lf-your-key
```

**No migration needed from v0.17.x** - logging continues to work, Langfuse integration is additive.

### Documentation

- Complete [Langfuse integration guide](/docs/production/observability/)
- Updated all examples to reflect new observability system
- Removed outdated instrumentation references

### What's Next

This solid observability foundation enables future enhancements like sampling, custom attributes, and additional OTEL exporters while maintaining the zero-config developer experience.

### Full Changelog

- feat: add zero-config Langfuse integration via OpenTelemetry
- feat: add DSPy::Observability module for automatic OTEL setup  
- feat: enhance Context.with_span to dual-export logs and OTEL spans
- feat: include opentelemetry-sdk and opentelemetry-exporter-otlp dependencies
- feat: auto-configure when LANGFUSE_PUBLIC_KEY and LANGFUSE_SECRET_KEY present
- feat: support proper GenAI semantic conventions for LLM operations
- feat: graceful degradation when OTEL gems missing or config fails
- docs: update all documentation to remove old instrumentation references
- docs: add comprehensive zero-config Langfuse integration guide
- docs: update observability examples throughout documentation

**Previous observability modernization (v0.15.x-v0.17.x):**
- Complete removal of complex 4,000+ line instrumentation system
- Simple 150-line Context-based observability system  
- Thread-local span tracking with proper parent-child relationships
- Environment-aware logging (JSON for production, key=value for development)
- Integration with all DSPy modules (LM, Predict, ChainOfThought, ReAct, etc.)

## v0.17.0: v0.17.0: Anthropic SDK Upgrade

**Published**: 2025-08-08

# 🚀 DSPy.rb v0.17.0 - Anthropic SDK Upgrade

## 🎯 What's New

### **📦 Anthropic SDK Upgraded: 1.1.1 → 1.5.0**
- **Search Result Content Blocks API** support for enhanced ReAct agents
- **AWS Bedrock** base URL compatibility fixes for enterprise users
- **Performance improvements** and bug fixes from SDK updates
- **Foundation established** for reasoning model integration ([#60](https://github.com/vicentereig/dspy.rb/issues/60))

## 🔧 Under the Hood
- All existing functionality remains 100% compatible
- Zero breaking changes for existing code
- VCR test cassettes work without modification
- Comprehensive test coverage maintained (1367 examples pass)

## 📚 Documentation Enhanced
- Added **Testing Philosophy** section to CLAUDE.md
- Clear guidance on API key management in tests
- Updated installation instructions with latest SDK versions

## 🎉 Benefits for Users
- **Enterprise Ready**: AWS Bedrock compatibility for corporate deployments
- **Future-Proof**: Ready for upcoming reasoning model features
- **More Reliable**: Latest SDK bug fixes and performance optimizations
- **Enhanced Agents**: New content block types for richer ReAct workflows

## 🔗 Related Work
- Closes [#63](https://github.com/vicentereig/dspy.rb/issues/63) - Anthropic SDK upgrade
- Connects to [#60](https://github.com/vicentereig/dspy.rb/issues/60) - Reasoning model integration roadmap

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.16.0...v0.17.0

**Installation**: 

## v0.16.0: v0.16.0: Provider Compatibility Validation

**Published**: 2025-08-08

# 🛡️ Provider Compatibility Validation for Multimodal Images

Version 0.16.0 introduces **comprehensive provider compatibility validation** to prevent silent failures when using provider-specific image features with incompatible LLM providers.

## 🚨 Problem Solved

Previously, users could accidentally mix provider-specific features without clear feedback:

```ruby
# Before: Silent failures and confusion
image = DSPy::Image.new(
  url: 'https://example.com/photo.jpg',  # Only works with OpenAI
  detail: 'high'                         # Only works with OpenAI  
)

# This would fail mysteriously with Anthropic
anthropic_lm = DSPy::LM.new('anthropic/claude-3-5-sonnet-20241022')
response = anthropic_lm.raw_chat do |messages|
  messages.user_with_image('What is this?', image)
end
# ❌ NotImplementedError: URL fetching for Anthropic not yet implemented
# ❌ detail parameter silently ignored
```

## ✅ Solution: Clear Validation with Actionable Errors

```ruby
# After: Immediate, helpful feedback
image = DSPy::Image.new(
  url: 'https://example.com/photo.jpg',
  detail: 'high'
)

anthropic_lm = DSPy::LM.new('anthropic/claude-3-5-sonnet-20241022')
response = anthropic_lm.raw_chat do |messages|
  messages.user_with_image('What is this?', image)
end
# ✅ IncompatibleImageFeatureError: 
# "Anthropic doesn't support image URLs. Please provide base64 or raw data instead."
```

## 📋 Provider Compatibility Reference

### OpenAI (Full Feature Support)
```ruby
# ✅ URLs supported
image = DSPy::Image.new(url: 'https://example.com/image.jpg')

# ✅ Base64 supported  
image = DSPy::Image.new(
  base64: 'iVBORw0KGgo...',
  content_type: 'image/png'
)

# ✅ Detail parameter supported
image = DSPy::Image.new(
  url: 'https://example.com/image.jpg',
  detail: 'high'  # 'low', 'high', or 'auto'
)

# ✅ Works with all OpenAI vision models
openai_lm = DSPy::LM.new('openai/gpt-4o')
```

### Anthropic (Base64/Raw Data Only)
```ruby
# ✅ Base64 supported
image = DSPy::Image.new(
  base64: 'iVBORw0KGgo...',
  content_type: 'image/png'
)

# ✅ Raw data supported
image_data = File.read('image.png', mode: 'rb').bytes
image = DSPy::Image.new(
  data: image_data,
  content_type: 'image/png'
)

# ❌ URLs not supported
image = DSPy::Image.new(url: 'https://...')  # Will raise error

# ❌ Detail parameter not supported  
image = DSPy::Image.new(base64: '...', detail: 'high')  # Will raise error

# ✅ Works with all Claude 3+ models
anthropic_lm = DSPy::LM.new('anthropic/claude-3-5-sonnet-20241022')
```

## 🎯 Quick Migration Guide

### If you're using URLs with Anthropic:
```ruby
# Before: 
image = DSPy::Image.new(url: 'https://example.com/image.jpg')

# After: Convert to base64
require 'net/http'
require 'base64'

response = Net::HTTP.get_response(URI('https://example.com/image.jpg'))
base64_data = Base64.strict_encode64(response.body)
image = DSPy::Image.new(
  base64: base64_data,
  content_type: 'image/jpeg'  # or appropriate type
)
```

### If you're using detail parameter with Anthropic:
```ruby
# Before:
image = DSPy::Image.new(base64: '...', detail: 'high')

# After: Remove detail parameter (Anthropic doesn't support it)
image = DSPy::Image.new(base64: '...')  # detail removed
```

## 🔧 Technical Details

### New Error Class
- **DSPy::LM::IncompatibleImageFeatureError**: Raised when provider-specific features are used with incompatible providers
- Clear, actionable error messages guide users to solutions
- Inherits from DSPy::LM::AdapterError for proper error hierarchy

### Validation Architecture  
- **Provider-agnostic core**: DSPy::Image remains neutral
- **Boundary validation**: Errors caught at adapter level before API calls
- **Fail-fast approach**: Immediate feedback prevents wasted API calls
- **Extensible design**: Easy to add new providers and capabilities

### Provider Capability Registry
```ruby
DSPy::Image::PROVIDER_CAPABILITIES = {
  'openai' => {
    sources: ['url', 'base64', 'data'],
    parameters: ['detail']
  },
  'anthropic' => {
    sources: ['base64', 'data'],
    parameters: []
  }
}
```

## 📦 Installation & Upgrade

```bash
# Install
gem install dspy

# Or add to Gemfile
gem 'dspy', '~> 0.16.0'
```

## 🧪 What's Tested

- ✅ 21 comprehensive test cases covering all validation scenarios
- ✅ Integration tests with both OpenAI and Anthropic adapters  
- ✅ Clear error message validation
- ✅ Backward compatibility with existing valid usage
- ✅ All existing multimodal functionality preserved

## 🚀 Benefits

1. **No More Silent Failures**: Immediate feedback when mixing incompatible features
2. **Better Developer Experience**: Clear guidance on how to fix issues
3. **Faster Debugging**: Errors caught before expensive API calls
4. **Future-Proof**: Easy to extend for new providers and capabilities
5. **Backward Compatible**: Existing valid code continues to work unchanged

## 📚 Related Documentation

- [Multimodal Support Guide](https://src.vicente.services/dspy.rb/multimodal/)
- [Provider Compatibility Reference](https://src.vicente.services/dspy.rb/providers/)
- [Error Handling Best Practices](https://src.vicente.services/dspy.rb/error-handling/)

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.7...v0.16.0

## v0.15.7: v0.15.7: SDK Dependencies Update

**Published**: 2025-08-07

## What's Changed

### 🔧 Dependencies Updated
- **OpenAI SDK**: Updated from `~> 0.13.0` to `~> 0.16.0`
  - Access to latest OpenAI features including improved structured outputs
  - Webhook verification support for production deployments
  - Enhanced error handling and file upload improvements
  
- **Anthropic SDK**: Updated from `~> 1.1.0` to `~> 1.1.1`
  - Minor patch release with bug fixes
  - Maintains full backward compatibility

### ✅ Compatibility
- All existing code continues to work without changes
- Full test suite passes with updated SDKs
- No breaking changes in this release

### 📦 Installation
```ruby
gem 'dspy', '~> 0.15.7'
```

Or update existing installation:
```bash
bundle update dspy
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.6...v0.15.7

## v0.15.6: v0.15.6: Union Type Resilience Against LLM Hallucinations

**Published**: 2025-08-05

## 🛡️ Union Types Now Resilient to LLM Hallucinations

This release fixes a critical issue where union type coercion would fail when LLMs return extra fields not defined in your T::Struct classes. This is particularly important for building robust AI agents that can handle unpredictable LLM outputs.

### 🐛 The Problem

When building AI agents with union types, LLMs sometimes get creative and add extra fields that aren't part of your struct definition. For example:

```ruby
# You define this clean struct:
class ReflectAction < T::Struct
  const :reasoning, String
  const :thoughts, String
end

# But the LLM returns this:
{
  "_type" => "ReflectAction",
  "reasoning" => "Need to analyze further",
  "thoughts" => "Considering multiple angles",
  "synthesis" => "Extra field\!"  # 💥 Not in ReflectAction\!
}
```

Previously, this would throw: `ArgumentError: ReflectAction: Unrecognized properties: synthesis`

### ✨ The Solution

DSPy.rb now automatically filters out extra fields during type coercion. Only fields defined in your struct are included when creating instances. This makes your agents more resilient to:

- 🤖 LLM hallucinations
- 🔄 Model version changes
- 📝 Prompt variations
- 🎭 Cross-model compatibility issues

### 🚀 Real-World Context

This issue was discovered in a research agent where the LLM confused similar concepts:
- `ReflectAction` (for deciding to reflect) has fields: `reasoning`, `thoughts`
- `ReflectionKnowledge` (for storing results) has fields: `thoughts`, `synthesis`

The LLM saw "reflect" and mistakenly added the `synthesis` field from the wrong struct type.

### 📦 What's Changed

- Modified `TypeCoercion#coerce_union_value` to filter fields
- Updated `Prediction#convert_union_type` for field filtering
- Fixed `convert_to_struct` to skip undefined fields
- Added comprehensive test coverage
- Updated documentation with robustness section

### 🔧 Upgrade Guide

No breaking changes\! Simply update to 0.15.6 and your union types become more resilient:

```bash
gem update dspy
```

Your existing code continues to work, but now handles LLM quirks gracefully.

### 📚 Learn More

- [Issue #59](https://github.com/vicentereig/dspy.rb/issues/59) - Original bug report
- [Union Types Article](https://vicentereig.github.io/dspy.rb/blog/union-types-agentic-workflows/) - Updated with robustness section
- [PR #607f63d](https://github.com/vicentereig/dspy.rb/commit/607f63d) - Implementation details

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.5...v0.15.6

## v0.15.5: v0.15.5: Nilable Array Union Type Fix

**Published**: 2025-08-03

## What's Changed

### Fixed
- **Nilable Arrays with Union Types** (#56) - Fixed type conversion for nilable arrays containing union types
  - `T.nilable(T::Array[T.any(StructA, StructB)])` now properly converts array elements to struct instances
  - Previously elements remained as hashes instead of being converted to their respective types
  - Updated `needs_array_conversion?` and `convert_array_elements` to handle nilable wrapper types
  - Added comprehensive test coverage for nilable array edge cases

### Example
```ruby
# Before: elements remained as hashes
prediction.items[0] # => { type: 'a', value_a: 'test' }

# After: elements converted to proper structs
prediction.items[0] # => #<TypeA type="a" value_a="test">
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.4...v0.15.5

## v0.15.4: v0.15.4: Enum Coercion Fix for Union Types

**Published**: 2025-08-02

## 🐛 Bug Fix

### Enum Coercion in Union Types

Fixed an edge case discovered in the coffee shop example where enum fields within union types weren't being properly coerced from strings.

**Before (broken):**
```ruby
# LLM returns: {"_type" => "MakeDrink", "size" => "large", ...}
# Error: Can't set MakeDrink.size to "large" - need a DrinkSize
```

**After (working):**
```ruby
# Automatically converts "large" string to DrinkSize::Large enum
result.action.size  # => DrinkSize::Large ✅
```

### What Changed

- Union type conversion now recursively applies type coercion to all struct fields
- Properly handles enums, floats, integers, and nested structs within union types
- Added comprehensive test coverage for these edge cases

This completes the union type support, making predictors work seamlessly with complex type hierarchies.

## Full Changelog

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md#0154---2025-08-02) for complete details.

## v0.15.3: v0.15.3: Union Type Support for Predictors

**Published**: 2025-08-02

## 🐛 Bug Fixes

### Union Type Conversion in Predictors (#54)

Fixed a critical issue where predictors (, ) couldn't handle union types properly. LLM responses with `_type` discriminators are now correctly converted to appropriate struct instances.

**Before (broken):**
```ruby
# This would throw: Can't set .action to {"_type"=>"AnswerAction", ...} - need a T.any(...)
result = predictor.call(question: "What is 2+2?")
```

**After (working):**
```ruby
result = predictor.call(question: "What is 2+2?")
puts result.action.class  # => AnswerAction
puts result.action.content  # => "2 + 2 = 4"
```

This enables the elegant union type patterns shown in our documentation and examples like the coffee shop agent.

## 📚 Documentation

- Added dotenv loading to coffee shop example for easier testing

## Full Changelog

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md#0153---2025-08-02) for complete details.

## v0.15.2: v0.15.2: CI Test Fixes

**Published**: 2025-07-28

## What's Changed

### Fixed
- **CI Test Failures** - Resolved test failures in continuous integration
  - Fixed class name collision between CodeAct and Ollama integration tests
  - Re-recorded VCR cassettes to match updated TypeSerializer request format
  - Renamed `MathProblem` to `CodeActMathProblem` in CodeAct specs to avoid conflicts

This release fixes test failures that were occurring in CI due to class name collisions and outdated VCR cassettes.

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.1...v0.15.2

## v0.15.1: v0.15.1: CodeAct Input Flexibility Fix

**Published**: 2025-07-28

## What's Changed

### Fixed
- **CodeAct Input Flexibility** - Fixed CodeAct to handle any input signature structure
  - Removed hardcoded assumption about input fields (similar to ReAct fix in v0.9.1)
  - Now uses `TypeSerializer.serialize` to properly handle all input types
  - Supports array inputs, non-string fields, and complex signatures
  - Maintains backward compatibility with existing CodeAct agents

### Documentation
- Fixed Ollama blog post frontmatter to use `description` instead of `summary` for proper display
- Removed duplicate title from Ollama blog post body

This is a patch release that fixes issues discovered after the v0.15.0 Ollama support release.

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.15.0...v0.15.1

## v0.15.0: v0.15.0: Ollama Support

**Published**: 2025-07-28

## 🎉 Ollama Support for Local LLM Development

DSPy.rb v0.15.0 brings full support for running LLMs locally with Ollama\! Develop with zero API costs while maintaining all the type safety and structured outputs you love.

### ✨ What's New

**Ollama Integration**
- 🏠 Run models locally with no API costs
- 🔒 Complete data privacy - nothing leaves your machine
- ⚡ Same type-safe structured outputs as cloud providers
- 🌐 Support for remote Ollama instances with authentication
- 📊 Full instrumentation and token tracking

### 🚀 Quick Start

```ruby
# Install Ollama and pull a model
brew install ollama
ollama pull llama3.2

# Use in DSPy.rb - no API key needed\!
DSPy.configure do |c|
  c.lm = DSPy::LM.new('ollama/llama3.2')
end

# Type-safe structured outputs work seamlessly
class ProductAnalysis < DSPy::Signature
  output do
    const :category, T::Enum
    const :keywords, T::Array[String]
  end
end

analyzer = DSPy::Predict.new(ProductAnalysis)
result = analyzer.forward(description: "Laptop stand...")
```

### 📚 Documentation

- [Installation Guide](https://vicentereig.github.io/dspy.rb/getting-started/installation/) - Updated with Ollama setup
- [Blog Post](https://vicentereig.github.io/dspy.rb/blog/articles/ollama-support-type-safe-local-llms/) - Deep dive into local LLM development

### 🔄 Full Changelog

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for complete details.

### 🙏 Thanks

Special thanks to everyone who requested local LLM support\!

## v0.14.0: v0.14.0: LLM Documentation & Anthropic Improvements

**Published**: 2025-07-28

## What's New in DSPy.rb v0.14.0

This release focuses on making DSPy.rb more accessible to AI agents through machine-readable documentation and improves Anthropic integration reliability.

### 🤖 llms.txt Documentation (#51)

DSPy.rb now provides machine-readable documentation specifically designed for LLMs:

- **llms.txt** - Core information about DSPy.rb for quick AI agent understanding
- **llms-full.txt** - Comprehensive library details including all features and examples
- Easy access via documentation footer and README links

This enables AI coding assistants to better understand and work with DSPy.rb's modular approach to prompt engineering.

### 🔧 Anthropic Integration Improvements

- **AnthropicToolUseStrategy** - Enhanced handling of Claude's tool_use response format
- Better JSON extraction from Anthropic's structured outputs
- Improved compatibility with latest Claude models
- Comprehensive test coverage for various response patterns

### 🐛 Bug Fixes

- Fixed Anthropic tool_use response format handling
- Resolved Sorbet type checking issues
- Updated playwright-ruby-client for reliable OG image generation
- Fixed OG image URLs for GitHub Pages deployment

### 📚 Documentation

- Simplified language across documentation articles
- Updated gemspec description for clarity
- Improved test examples focusing on behavior over implementation

## Full Changelog

See the [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md#0140---2025-07-28) for complete details.

## Installation

```bash
gem install dspy -v 0.14.0
```

Or add to your Gemfile:

```ruby
gem 'dspy', '~> 0.14.0'
```

## v0.13.0: v0.13.0: Type-Safe Token Usage

**Published**: 2025-07-25

## What's Changed

### 🚀 Token Usage Type Safety with T::Struct
Convert token usage data to typed structs for better reliability and type safety.

### 🐛 Fixed Token Tracking with VCR (#48)
Token usage events are now properly emitted during VCR playback, fixing a critical issue for testing token consumption.

### 💔 Breaking Changes
**Response#usage now returns a struct instead of a hash**

```ruby
# Before (0.12.0)
response.usage[:input_tokens]   # or response.usage['input_tokens']
response.usage[:output_tokens]  # or response.usage['output_tokens']

# After (0.13.0)
response.usage.input_tokens
response.usage.output_tokens
response.usage.to_h  # if you need hash format
```

### Features
- New `DSPy::LM::Usage` and `DSPy::LM::OpenAIUsage` structs for type-safe token usage
- `UsageFactory` handles conversion from various formats (hashes, API response objects)
- Automatic handling of OpenAI's nested details objects with proper type conversion
- Enhanced TokenTracker to handle both symbol and string keys defensively

### Testing
- Added comprehensive integration tests for token tracking with VCR
- Added unit tests for usage struct conversions

### Internal
- Normalized usage data keys to symbols in both OpenAI and Anthropic adapters
- Improved response object handling for better VCR compatibility

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.12.0...v0.13.0

## v0.12.0: v0.12.0: Raw Chat API

**Published**: 2025-07-24

## 🚀 Raw Chat API for Benchmarking and Migration

This release introduces the `raw_chat` API, enabling teams to benchmark their existing monolithic prompts and facilitate gradual migration to DSPy's modular approach.

### ✨ Key Features

#### New `DSPy::LM#raw_chat` Method
Run legacy prompts through DSPy's instrumentation pipeline without structured output features:

```ruby
# Array format
result = lm.raw_chat([
  { role: 'system', content: 'You are a helpful assistant.' },
  { role: 'user', content: 'What is 2+2?' }
])

# DSL format
result = lm.raw_chat do |m|
  m.system "You are a changelog generator."
  m.user "Generate changelog for: #{commits}"
end
```

#### Full Instrumentation Support
- Emits `dspy.lm.request` and `dspy.lm.tokens` events
- Works with all observability integrations (DataDog, OTEL, etc.)
- Enables accurate token usage comparison

#### Message Builder DSL
Clean syntax for building conversations:
```ruby
lm.raw_chat do |m|
  m.user "My name is Alice"
  m.assistant "Nice to meet you, Alice\!"
  m.user "What's my name?"
end
```

### 📊 Benchmarking Example

```ruby
# Benchmark legacy prompt
legacy_result = lm.raw_chat do |m|
  m.system MONOLITHIC_PROMPT
  m.user data
end

# Compare with modular approach
modular_result = dspy_module.forward(data)

# Access token usage for comparison
puts "Legacy: #{legacy_tokens[:total_tokens]} tokens"
puts "Modular: #{modular_tokens[:total_tokens]} tokens"
```

### 📚 Documentation
- [Comprehensive benchmarking guide](https://www.dspy.rb.dev/docs/optimization/benchmarking-raw-prompts/)
- [Blog article on raw_chat API](https://www.dspy.rb.dev/blog/raw-chat-api/)
- Updated core concepts documentation

### 🔧 Internal Improvements
- Extracted common instrumentation logic for code reuse
- Refactored existing `chat` method to use extracted logic
- Maintains full backward compatibility

### 🎯 Use Cases
- Benchmark monolithic prompts against modular implementations
- Compare token usage and costs across approaches
- Gradual migration from legacy prompt systems
- Quick prototyping without signatures

See the [full changelog](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for all changes.

## v0.11.0: v0.11.0: Single-Field Union Types

**Published**: 2025-07-21

## 🚀 Single-Field Union Types with Automatic Type Detection

This release introduces a major simplification for working with union types in DSPy.rb. You can now use a single `T.any()` field and DSPy automatically handles type detection through an injected `_type` field.

### ✨ What's New

**Simplified Union Types** (#45)
- Automatic `_type` field injection in JSON schemas for T::Struct types
- TypeSerializer automatically adds `_type` field during struct serialization
- DSPy::Prediction uses `_type` field for automatic type detection in union types
- No need for manual discriminator fields - just use `T.any()` with structs
- Supports anonymous structs with fallback to "AnonymousStruct" type name
- Clean pattern for AI agents that need to choose between different action types

### 🔄 Migration

**Before (v0.10.x):**
```ruby
# Two fields needed - manual discriminator
output do
  const :action_type, ActionType  # Discriminator enum
  const :action_data, T.any(CreateTask, UpdateTask, DeleteTask)
end
```

**Now (v0.11.0):**
```ruby
# Just one field - automatic type detection\!
output do
  const :action, T.any(CreateTask, UpdateTask, DeleteTask)
end
```

### 📚 Documentation

- **Coffee Shop Agent Example**: See the new pattern in action with a fun example
- **Updated Complex Types Guide**: Learn about single-field unions
- **Architecture Decision Record**: ADR-004 documents the design decisions

### 🙏 Thanks

Special thanks to all contributors and users who provided feedback on union type patterns\!

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.10.1...v0.11.0

## v0.10.1: v0.10.1: Improved Error Handling & Gem Conflict Detection

**Published**: 2025-07-20

## What's Changed

### 🎯 Better Developer Experience

This release focuses on improving error messages and preventing common configuration issues.

### ✨ New Features

- **Clear Configuration Error Messages** (#34)
  - New `DSPy::ConfigurationError` with actionable guidance
  - No more cryptic `NoMethodError: undefined method 'model' for nil`
  - Examples included for both global and module-level configuration

- **Ruby-OpenAI Gem Conflict Detection** (#29)
  - Automatic detection of incompatible `ruby-openai` gem
  - Clear warning with migration steps to official OpenAI SDK
  - Prevents namespace conflicts and unexpected behavior

### 📚 Documentation

- New comprehensive troubleshooting guide at `docs/src/production/troubleshooting.md`
- Covers configuration errors, gem conflicts, and debugging tips

### 🐛 Fixes

- Instrumentation helpers now validate LM configuration early
- Better error messages throughout the framework

### 💡 Example

```ruby
# Before: Cryptic error
module.forward(input: "test")
# => NoMethodError: undefined method 'model' for nil

# After: Clear, actionable error
module.forward(input: "test")
# => DSPy::ConfigurationError: No language model configured for MyModule module.
#    
#    To fix this, configure a language model either globally:
#    
#      DSPy.configure do |config|
#        config.lm = DSPy::LM.new("openai/gpt-4", api_key: ENV["OPENAI_API_KEY"])
#      end
#    
#    Or on the module instance:
#    
#      module_instance.configure do |config|
#        config.lm = DSPy::LM.new("anthropic/claude-3", api_key: ENV["ANTHROPIC_API_KEY"])
#      end
```

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.10.0...v0.10.1

## v0.10.0: v0.10.0: Automatic Type Conversion for Union Types

**Published**: 2025-07-20

## 🎉 Highlights

This release introduces **automatic Hash-to-struct type conversion**, making it easier to work with complex types and union types in DSPy.rb. LLM JSON responses are now automatically converted to proper Ruby objects!

## ✨ Key Features

### Automatic Type Conversion (#42)
- 🔄 **Enum conversion**: Strings → T::Enum instances
- 📦 **Struct conversion**: Hashes → T::Struct objects (recursive)
- 📚 **Array handling**: Elements converted based on declared types
- 🛡️ **Default values**: Missing fields use struct defaults
- 🎯 **Smart unions**: Discriminated union support with T::Enum
- 🔙 **Graceful fallback**: Original hash preserved if conversion fails

### Union Types with T.any()
- Clean handling of multiple possible struct types
- Automatic type selection based on discriminator fields
- Support for both String and T::Enum discriminators
- See the new [blog post](https://vicentereig.github.io/dspy.rb/blog/union-types-agentic-workflows/) for examples!

## 📚 Documentation
- Comprehensive "Automatic Type Conversion" section added
- Blog post: "Union Types: The Secret to Cleaner AI Agent Workflows"
- Architecture Decision Records (ADR) directory established

## 🐛 Fixes
- Unicode characters display correctly in Example#to_s
- GitHub Actions now generate OG images in production

## 🔗 Links
- [Full Changelog](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md#0100---2025-01-20)
- [Union Types Blog Post](https://vicentereig.github.io/dspy.rb/blog/union-types-agentic-workflows/)
- [Documentation](https://vicentereig.github.io/dspy.rb/advanced/complex-types/#automatic-type-conversion-with-dspy-prediction)

## v0.9.1: v0.9.1: ReAct Agent Input Flexibility Fix

**Published**: 2025-07-16

## 🐛 Bug Fix Release

This release fixes a critical bug in ReAct agents where they failed when given non-string first inputs or array inputs.

### 🔧 Fixed Issues

**ReAct Agent Input Flexibility (#41)**
- Fixed bug where ReAct agents assumed the first input field was always a String "question"
- ReAct now works with any input signature structure
- Supports array inputs, non-string first inputs, and complex nested structures

### 📝 Example Usage

Before this fix, ReAct agents would fail with signatures like:

```ruby
# ❌ This would fail before v0.9.1
class TaskProcessing < DSPy::Signature
  input do
    const :tasks, T::Array[Task]      # Array as first input
    const :query, String
  end
  
  output do
    const :result, String
  end
end

# ❌ This would also fail
class Calculation < DSPy::Signature  
  input do
    const :number, Integer            # Non-string first input
    const :operation, String
  end
  
  output do
    const :answer, String
  end
end
```

Now these work perfectly:

```ruby
# ✅ Array inputs work
tasks = [
  Task.new(id: "1", name: "Buy groceries"),
  Task.new(id: "2", name: "Call dentist")
]

agent = DSPy::ReAct.new(TaskProcessing, tools: tools)
result = agent.forward(tasks: tasks, query: "What tasks do I have?")

# ✅ Non-string first inputs work
agent = DSPy::ReAct.new(Calculation, tools: tools)
result = agent.forward(number: 42, operation: "Add 58 to this number")

# ✅ Complex nested structures work
agent = DSPy::ReAct.new(DataProcessing, tools: tools)
result = agent.forward(values: [10, 20, 30], multiplier: 2)
```

### 🔄 Technical Changes

- Removed hardcoded "question" field assumption in ReAct implementation
- ReAct now serializes all input fields as JSON and passes as `input_context` to LLM
- Updated internal Thought and ReActObservation signatures to use generic `input_context`
- Added comprehensive integration tests for edge cases
- Maintains full backward compatibility with existing ReAct agents

### 🧪 Test Coverage

Added integration tests covering:
- Array inputs as first field
- Non-string first inputs (Integer, Float, etc.)
- Signatures with no string fields at all
- Complex nested structures
- Backward compatibility with existing patterns

### 📚 Documentation

No documentation updates were needed - the documentation already correctly showed ReAct's flexibility. The implementation now matches the documented behavior.

### 🔗 Links

- **Issue**: #41
- **Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.9.0...v0.9.1
- **Documentation**: https://vicentereig.github.io/dspy.rb/core-concepts/predictors/

---

**Installation**: `gem install dspy -v 0.9.1`

**Upgrade**: Update your Gemfile to `gem 'dspy', '~> 0.9.1'` and run `bundle update dspy`

## v0.9.0: v0.9.0: Simplified Strategy Configuration

**Published**: 2025-07-11

## Breaking Changes

**Strategy Configuration API** - Simplified strategy configuration using type-safe enums:

- Replaced complex strategy name strings with `DSPy::Strategy::Strict` and `DSPy::Strategy::Compatible` enum values
- `DSPy::Strategy::Strict` selects provider-optimized strategies (OpenAI structured outputs, Anthropic extraction)  
- `DSPy::Strategy::Compatible` uses enhanced prompting that works with any provider
- **BREAKING**: String strategy names like `"enhanced_prompting"` are no longer supported

## Migration Guide

Replace this:
```ruby
config.structured_outputs.strategy = "enhanced_prompting"
```

With this:
```ruby  
config.structured_outputs.strategy = DSPy::Strategy::Compatible
```

## Added Features

- **User-Friendly Strategy Categories** - Two clear strategy options instead of three internal implementations
- Automatic fallback from Strict to Compatible when provider-specific features are unavailable
- Type-safe enum values with Sorbet integration
- Clearer documentation and error messages

## Documentation Updates

- Updated all documentation to use new enum-based strategy configuration
- Improved blog post with correct version references and enum examples
- Clarified strategy selection behavior and fallback logic

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.8.1...v0.9.0

## v0.8.1: v0.8.1: OpenAI Structured Outputs Fixes

**Published**: 2025-07-11

## Fixed
- **OpenAI Structured Outputs with Nested Arrays** (#33) - Re-enabled test for nested arrays after OpenAI fixed API bug
  - OpenAI API now correctly handles `additionalProperties` for nested arrays of primitive types
  - Re-recorded VCR cassette showing successful API response for complex nested structures
  - Restored original `tags: T::Array[String]` field in test cases
- **Test Infrastructure Improvements** - Fixed class naming conflicts in test adapters

## Added
- **Comprehensive Edge Case Testing** - Added extensive test coverage for OpenAI structured outputs
  - Deeply nested objects (5+ levels) with depth validation warnings
  - Mixed required/optional fields with `T.nilable` support
  - Arrays with varying object complexity
  - Schema depth validation and compatibility checks

## Documentation
- Updated issue #33 with findings showing OpenAI API bug resolution
- Enhanced test coverage for structured output edge cases

## Installation

```bash
gem install dspy
```

Or add to your Gemfile:

```ruby
gem 'dspy', '~> 0.8.1'
```

## v0.8.0: v0.8.0: JSON Parsing Reliability

**Published**: 2025-07-11

## Highlights

This release brings comprehensive JSON parsing reliability improvements to DSPy.rb, making structured output extraction from LLMs actually reliable.

### 🎯 Key Features

- **OpenAI Structured Outputs** - Native support for OpenAI's JSON schema mode with guaranteed valid JSON
- **Automatic Strategy Selection** - Provider-optimized extraction that just works
- **Smart Retry Logic** - Progressive fallback with exponential backoff 
- **Performance Caching** - Faster repeated operations with schema caching

### 📖 Read More

Check out the [blog post](https://vicentereig.github.io/dspy.rb/blog/json-parsing-reliability) for a detailed walkthrough of these features.

### 🚀 Quick Example

```ruby
# Just add structured_outputs: true for OpenAI
lm = DSPy::LM.new('openai/gpt-4o-mini', 
                  api_key: ENV['OPENAI_API_KEY'],
                  structured_outputs: true)

# Automatic strategy selection for other providers
lm = DSPy::LM.new('anthropic/claude-3-haiku', 
                  api_key: ENV['ANTHROPIC_API_KEY'])
```

### 📋 Full Changelog

- **JSON Parsing Reliability Features** (#18)
  - OpenAI structured outputs support
  - Automatic strategy selection based on provider
  - Retry mechanisms with progressive fallback
  - Schema and capability caching
- **Enhanced Error Recovery** - Better handling of transient failures
- **Improved Error Messages** - Detailed context for debugging

See [CHANGELOG.md](https://github.com/vicentereig/dspy.rb/blob/main/CHANGELOG.md) for complete details.

## v0.7.0: v0.7.0: Default Values, API Validation, and Enhanced Documentation

**Published**: 2025-07-11

This release brings significant improvements to DSPy.rb with a focus on developer experience, Ruby idioms, and comprehensive documentation.

## ✨ Major Features

### Default Values for Signatures (#32)
Input and output fields can now have default values, reducing boilerplate and handling missing LLM responses gracefully:

```ruby
class SmartSearch < DSPy::Signature
  input do
    const :query, String
    const :max_results, Integer, default: 10
  end
  
  output do
    const :results, T::Array[String]
    const :cached, T::Boolean, default: false
  end
end
```

### API Key Validation (#27)
Immediate validation at initialization with helpful error messages:

```ruby
# Now raises DSPy::LM::MissingAPIKeyError with clear instructions
DSPy::LM.new('openai/gpt-4o-mini', api_key: nil)
# => "API key is required. Provide via api_key parameter or OPENAI_API_KEY environment variable"
```

### Enhanced Documentation
- **CodeAct Module**: Comprehensive documentation for dynamic code generation
- **Ruby-Idiomatic Examples**: Collections, blocks, method chaining patterns
- **Blog Section**: In-depth posts on Ruby APIs, CodeAct, and ReAct agents
- **Rails Integration Guide** (#30): Enum handling, service objects, ActiveJob patterns

## 🐛 Bug Fixes
- Default values now properly work with T::Struct for both input and output fields
- API key validation prevents runtime errors from nil or empty keys
- Rails enum handling confusion resolved with comprehensive documentation

## 📚 Documentation
- Added CodeAct module documentation with safety considerations
- Created Rails integration guide with practical examples
- Enhanced signatures documentation with default values section
- Three new blog posts for deeper understanding

## 🔄 Breaking Changes
- API keys are now validated at initialization instead of runtime. This helps catch configuration errors early but may break code that relied on lazy validation.

## 📦 Installation

Add this to your Gemfile:

```ruby
gem 'dspy', '~> 0.7.0'
```

Or install directly:

```bash
gem install dspy -v 0.7.0
```

## 🙏 Acknowledgments

Thanks to all contributors who helped make this release possible\!

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.6.4...v0.7.0

## v0.6.4: v0.6.4: Documentation Website Launch

**Published**: 2025-07-09

# 🚀 Documentation Website Launch - v0.6.4

We're excited to announce the launch of the official DSPy.rb documentation website\! This release brings comprehensive documentation for Ruby developers looking to build programmatic LLM applications.

## 📖 New Documentation Website

Visit **[vicentereig.github.io/dspy.rb](https://vicentereig.github.io/dspy.rb)** to explore our comprehensive documentation covering:

### Getting Started
- **Installation** - Quick setup for Ruby developers
- **Quick Start** - Your first DSPy program in minutes
- **Core Concepts** - Understanding the DSPy paradigm
- **First Program** - Step-by-step tutorial
- **Transformation** - From prompts to programs

### Core Concepts
- **Signatures** - Define what you want, not how to ask
- **Modules** - Composable LLM components
- **Predictors** - The building blocks of reasoning
- **Examples** - Real-world applications

### Advanced Features
- **Complex Types** - Work with structured data
- **Pipelines** - Chain multiple operations
- **RAG** - Retrieval-Augmented Generation
- **Custom Metrics** - Measure what matters

### Optimization
- **Evaluation** - Test your LLM applications
- **Prompt Optimization** - Automatic prompt improvement
- **Simple Optimizer** - Get started with optimization
- **MIPRO v2** - Advanced optimization techniques

### Production
- **Observability** - Monitor your LLM applications
- **Registry** - Version and manage your programs
- **Storage** - Persist your optimized models

## 🔧 What's New in v0.6.4

- Complete documentation overhaul with interactive examples
- Type-safe signature definitions with comprehensive guides
- Production-ready observability and monitoring documentation
- Advanced optimization techniques and best practices
- Real-world examples and use cases

## 🎯 Why DSPy.rb?

Stop fighting with prompts. Start building with code:

```ruby
# Define what you want with types
class ClassifyEmail < DSPy::Signature
  description "Classify customer support emails"
  
  input do
    const :email, Email
  end
  
  output do
    const :category, EmailCategory
    const :priority, Priority
  end
end

# Let DSPy handle the rest
classifier = DSPy::ChainOfThought.new(ClassifyEmail)
result = classifier.call(email: email)
```

## 🚀 Get Started

```bash
gem install dspy
```

Then visit [vicentereig.github.io/dspy.rb](https://vicentereig.github.io/dspy.rb) to start building\!

## 🙏 Community

- **Documentation**: [vicentereig.github.io/dspy.rb](https://vicentereig.github.io/dspy.rb)
- **GitHub**: [github.com/vicentereig/dspy.rb](https://github.com/vicentereig/dspy.rb)
- **Issues**: Report bugs and request features

Happy coding\! 🎉

## v0.6.3: v0.6.3: Bug Fixes and Improvements

**Published**: 2025-07-08

## What's Changed

### Dependencies
- Upgraded official OpenAI Ruby SDK from v0.9.0 to v0.12.0
  - Includes improved streaming helpers and better handling of partial JSON in structured output
  - No breaking changes - all existing functionality remains compatible

### Full Changelog
https://github.com/vicentereig/dspy.rb/compare/v0.6.2...v0.6.3

## v0.6.2: v0.6.2: Minor Improvements

**Published**: 2025-07-08

## What's Changed

### Bug Fixes
- Fixed type coercion for T::Array[T::Struct] output fields (#28)
  - LLM responses containing arrays of hashes are now properly coerced into arrays of T::Struct objects
  - Enables proper support for complex nested data structures in DSPy signatures
  - Added comprehensive tests for struct array coercion

### Technical Details
- Enhanced type coercion logic in `DSPy::Mixins::TypeCoercion` to handle nested struct arrays
- Added `coerce_struct_value` method to properly instantiate T::Struct objects from hash data
- Improved array coercion to recursively handle element type conversion

### Full Changelog
https://github.com/vicentereig/dspy.rb/compare/v0.6.1...v0.6.2

## v0.6.1: v0.6.1: Bug Fixes

**Published**: 2025-07-06

## What's Changed

### Bug Fixes
- Fix Gemfile.lock dependencies

This is a patch release that fixes dependency resolution issues in the Gemfile.lock.

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.6.0...v0.6.1

## v0.6.0: v0.6.0: CodeAct Framework Release

**Published**: 2025-07-05

# 🚀 DSPy.rb v0.6.0 - CodeAct Framework Release

## Major Features

### 🤖 CodeAct Framework
- **Dynamic Ruby Code Execution**: New `DSPy::CodeAct` agent that can write and execute Ruby code to solve tasks
- **Think-Code-Observe Pattern**: Advanced reasoning loop with code generation, execution, and result observation
- **Safe Execution Environment**: Built-in error handling and stdout capture for code execution
- **Complete Integration**: Full observability, instrumentation, and logging support

### 🧠 Memory Toolsets  
- **Persistent Memory Management**: Store and retrieve information across agent sessions
- **Embedding-based Search**: Semantic search using local embedding models
- **Memory Compaction**: Automatic cleanup and optimization of stored memories
- **Metadata Tracking**: Rich context and tagging system for memories

### 🛠️ Text Processing Toolsets
- **Advanced Text Manipulation**: grep, ripgrep, line extraction, and text statistics
- **Log Analysis**: Specialized tools for log filtering, sorting, and error analysis
- **Pattern Matching**: Powerful regex and context-aware search capabilities

## 🔧 Technical Improvements

### Enhanced Observability
- **CodeAct Events**: Complete instrumentation for code execution agents
- **Smart Event Consolidation**: Intelligent event filtering for nested contexts  
- **Multi-Platform Logging**: OpenTelemetry, New Relic, and Langfuse integration

### Type Safety & Reliability
- **Improved Nil Handling**: Better type coercion for optional values
- **Reduced Method Complexity**: Refactored iteration logic for improved testability
- **Enhanced Error Handling**: Graceful failure management across all components

### Code Quality
- **Method Extraction**: Separated concerns for better maintainability
- **Unit Test Coverage**: Comprehensive testing of complex private methods
- **Sorbet Integration**: Full type annotations throughout the codebase

## 📚 Documentation Updates

- **CodeAct Usage Guide**: Complete examples and patterns for code execution agents
- **Memory Management**: Detailed guides for memory toolsets and compaction strategies  
- **Toolset Implementation**: Examples and best practices for custom toolsets
- **Updated Quick Start**: Enhanced getting started guide with new capabilities

## 🧪 Testing & Quality

- **1054 Tests Passing**: Full test coverage with no regressions
- **VCR Integration**: All LLM interactions properly recorded for consistent testing
- **Private Method Testing**: Unit tests for extracted methods and complex logic
- **Integration Testing**: End-to-end testing for all new frameworks

## 🔄 Migration Guide

This release is **fully backward compatible**. No breaking changes.

### New Usage Examples

```ruby
# CodeAct Agent for Programming Tasks
class ProgrammingAssistant < DSPy::Module
  def initialize
    super
    @codeact = DSPy::CodeAct.new(ProgrammingSignature, max_iterations: 10)
  end

  def forward(task:)
    @codeact.call(task: task)
  end
end

# Memory-Enhanced Agent
class MemoryAgent < DSPy::Module  
  def initialize
    super
    @memory = DSPy::Tools::MemoryToolset.new
    @predictor = DSPy::Predict.new(MySignature)
  end

  def forward(query:)
    memories = @memory.search_memories(query: query, limit: 5)
    context = memories.map(&:content).join("\n")
    
    result = @predictor.call(query: query, context: context)
    
    # Store result for future use
    @memory.store_memory(content: result.answer, metadata: { query: query })
    
    result
  end
end
```

## 🙏 Contributors

Thank you to everyone who contributed to this release through testing, feedback, and code contributions\!

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.5.1...v0.6.0

## v0.5.1: v0.5.1: Simplified Smart Consolidation

**Published**: 2025-07-04

# 🧹 DSPy.rb v0.5.1 - Simplified Smart Consolidation

This release simplifies the instrumentation system by removing configuration complexity while maintaining the same noise reduction benefits.

## 🔧 **Simplification**

- **Removed trace levels** - no more configuration decisions to make
- **Smart consolidation only** - automatically detects nested vs direct calls
- **Same noise reduction** - still cuts redundant events for ChainOfThought/ReAct calls
- **Cleaner codebase** - 151 lines of code removed

## 📝 **Documentation Updates**

- **Real trace examples** from actual test runs instead of theoretical ones
- **Grounded examples** using actual field names and values
- **Accurate timestamp formats** with real output samples
- **No overpromising** - factual descriptions of current behavior

## 🧪 **Testing Improvements**

- **Fixed 3 failing instrumentation tests** (now all pass)
- **Improved overall pass rate** from 98.8% to 99.1%
- **Robust timestamp testing** using regex patterns (no timecop needed)

## 📊 **Real Examples**

**Direct Predict call** (detailed events):
```
event=lm_request timestamp=2025-07-04T13:46:24+02:00 provider=openai model=gpt-4o-mini status=success duration_ms=3.82
event=lm_tokens timestamp=2025-07-04T13:46:24+02:00 provider=openai model=gpt-4o-mini input_tokens=290 output_tokens=23 total_tokens=313
event=prediction timestamp=2025-07-04T13:46:24+02:00 signature=TestEventConsolidation status=success duration_ms=5.13
```

**ChainOfThought call** (consolidated):
```
event=chain_of_thought timestamp=2025-07-04T13:46:24+02:00 signature=TestQuestionAnswering status=success duration_ms=2.44
```

## 🎯 **No Breaking Changes**

- All existing instrumentation continues to work
- Same token standardization (`input_tokens`, `output_tokens`, `total_tokens`)
- Same timestamp format configuration
- No configuration changes required

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.5.0...v0.5.1

## v0.5.0: v0.5.0: Instrumentation Noise Reduction

**Published**: 2025-07-04

# 🎯 DSPy.rb v0.5.0 - Instrumentation Noise Reduction

This release significantly improves the observability system by reducing instrumentation noise while maintaining comprehensive monitoring capabilities.

## ✨ New Features

### 🔇 **Event Consolidation System**
- **Three trace levels** for different environments:
  - `:minimal` - Only top-level events (production-ready)
  - `:standard` - Consolidated events with smart nesting detection (default)
  - `:detailed` - Full event emission for debugging
- **80% noise reduction**: A single ChainOfThought operation now emits 1 event instead of 5
- **Intelligent nesting detection** prevents redundant nested events

### 📊 **Standardized Token Reporting**
- Unified token field names across all LLM providers
- Consistent schema: `input_tokens`, `output_tokens`, `total_tokens`
- Works seamlessly with OpenAI and Anthropic APIs

### ⏰ **OpenTelemetry-Compliant Timestamps**
- **Three timestamp formats** using type-safe T::Enum:
  - `ISO8601` - Standard format (default)
  - `RFC3339_NANO` - Nanosecond precision
  - `UNIX_NANO` - Unix nanoseconds for high-precision monitoring
- Full OpenTelemetry compliance for production monitoring

### 🔍 **Enhanced Logger Subscriber**
- Separate `dspy.lm.tokens` events for detailed token tracking
- Configurable timestamp formats in all log events
- Backward-compatible with existing logging setups

## 🧪 Testing & Quality

- **44 passing tests** ensure no breaking changes
- New comprehensive test suite for event consolidation
- All instrumentation scenarios covered

## 📚 Documentation

- Updated observability guide with new features
- Configuration examples for all trace levels
- Production deployment patterns

## ⚠️ Known Issues

- **Autonomous task planning specs are currently failing** - investigation in progress
- Does not affect core DSPy functionality or new instrumentation features

## 🔧 Configuration Example

```ruby
DSPy.configure do |config|
  config.instrumentation.enabled = true
  config.instrumentation.trace_level = :standard  # New default
  config.instrumentation.timestamp_format = DSPy::TimestampFormat::UNIX_NANO
end
```

## 🎉 Impact

- **Reduced noise**: 80% fewer events in production
- **Better observability**: Cleaner, more actionable monitoring data
- **OpenTelemetry ready**: Full compliance for enterprise monitoring
- **Backward compatible**: No breaking changes to existing setups

Closes #16

---

**Full Changelog**: https://github.com/vicentereig/dspy.rb/compare/v0.4.0...v0.5.0

## v0.4.0: v0.4.0: Production-grade MIPROv2 Optimization

**Published**: 2025-07-01

## v0.4.0 - Production-grade MIPROv2 Optimization

**🚀 Major Release: Production-grade MIPROv2 Optimization**

This is a significant release introducing production-grade optimization capabilities, comprehensive evaluation frameworks, and enterprise-level documentation.

### ✨ Major New Features
- **MIPROv2 Optimization Algorithm**: Complete implementation with comprehensive test suite for production-grade model optimization
- **Evaluation Framework**: Full evaluation system for model optimization with metrics, validation, and reporting
- **Storage & Persistence**: Comprehensive storage and persistence system (Iteration 5) for program and data management
- **Prompt Objects**: New prompt object foundation for enhanced MIPROv2 support and better abstraction
- **Example System**: DSPy::Example PORO with Signature validation for robust data handling
- **Teleprompter Base**: Complete teleprompter infrastructure for optimization workflows
- **Registry System**: Signature registry and registry manager for better organization and discovery
- **Grounded Proposer**: Advanced proposal system for sophisticated agentic workflows

### 📚 Documentation Overhaul
- **Complete Documentation Restructure**: Migrated to Bridgetown with modular, maintainable structure
- **Production Observability Guide**: Comprehensive observability documentation for enterprise deployments
- **Structured Getting Started**: Professional installation and quick-start guides
- **Evaluation Documentation**: Complete evaluation framework documentation with examples
- **Optimization Guides**: Detailed MIPROv2 optimization tutorials and best practices

### 🔧 Infrastructure & Testing Excellence
- **Enhanced Test Suite**: Major test infrastructure improvements with VCR cassettes for reliable testing
- **Test Isolation**: Completely resolved test isolation issues for better stability and reliability
- **Comprehensive Coverage**: Added extensive test coverage for all new features and edge cases

### 📊 Production Observability
- **Enterprise Observability Stack**: Complete observability implementation for production environments
- **Multiple Subscriber Support**: Langfuse, NewRelic, and OpenTelemetry subscribers for comprehensive monitoring
- **Enhanced Instrumentation**: Improved logging, monitoring, and debugging capabilities

### 🐛 Critical Bug Fixes
- Fixed missing `infer_signature_class` method in Teleprompter base class
- Resolved major test failures and improved overall test stability
- Enhanced logger configuration and instrumentation reliability

### Statistics
- **115 files changed** with **24,518 insertions** and **1,359 deletions**
- **28 commits** since v0.3.0
- **Comprehensive test coverage** with extensive VCR cassette integration

## v0.3.1: v0.3.1: Documentation and Stability Improvements

**Published**: 2025-07-01

## v0.3.1 - Documentation and Stability Improvements

**📖 Enhanced Documentation and System Stability**

This maintenance release focuses on improving documentation and system stability with enhanced logging and configuration.

### 🔧 Improvements
- **Enhanced Logger Configuration**: Improved logger setup with key-value format for better structured logging
- **Configuration Fixes**: Fixed logger config entrypoint issues for more reliable initialization
- **Documentation Updates**: Updated instrumentation documentation with clearer examples and usage patterns
- **MIPROv2 Foundation**: Added MIPROv2 supporting references and preparation documentation

### 🐛 Bug Fixes
- Resolved logger configuration initialization problems
- Fixed config entrypoint reliability issues
- Improved error handling in logging subsystem

### 📚 Documentation
- **Instrumentation Guide**: Enhanced instrumentation documentation with practical examples
- **Configuration Reference**: Improved configuration documentation and troubleshooting guides
- **MIPROv2 Preparation**: Added foundational documentation for upcoming MIPROv2 features

This release ensures better stability and provides clearer documentation to help developers integrate and use the framework effectively.

## v0.3.0: v0.3.0: Instrumentation and Agentic Capabilities

**Published**: 2025-07-01

## v0.3.0 - Instrumentation and Agentic Capabilities

**🎯 Advanced Instrumentation and Agentic Framework**

This release introduces comprehensive instrumentation and agentic capabilities, along with migration to official LM provider clients.

### ✨ New Features
- **Instrumentation Base**: Added comprehensive instrumentation for Predict, ChainOfThought, and ReAct modules
- **Agentic Capabilities**: Complete agentic framework implementation with advanced reasoning
- **Official Client Migration**: Migrated from ruby_llm to official LM provider clients (OpenAI, Anthropic)
- **Sorbet Signatures**: Released comprehensive Sorbet type signatures for better IDE support
- **Per-Module LM Override**: Ability to override language models per module for fine-grained control

### 🔧 Infrastructure Improvements
- **Enhanced ReAct**: Improved ReAct tool schema serialization and reasoning capabilities
- **Prediction Enhancement**: Updated predictions to include input fields for better traceability
- **Documentation Updates**: Comprehensive README and documentation improvements
- **API Documentation**: Sorbet-based API documentation generation

### 🐛 Bug Fixes
- Fixed redundant extend issues in module architecture
- Corrected ReAct tool schema serialization problems
- Fixed Sorbet ReAct reasoning completion flows
- Resolved various instrumentation edge cases

### 📊 Observability
- **Event System**: Comprehensive event instrumentation for all core operations
- **Monitoring Integration**: Built-in support for monitoring and observability
- **Debug Capabilities**: Enhanced debugging and tracing functionality

This release significantly enhances the framework's enterprise readiness with comprehensive instrumentation and agentic capabilities.

## v0.2.0: v0.2.0: Schema Evolution and Type Safety

**Published**: 2025-07-01

## v0.2.0 - Schema Evolution and Type Safety

**🏗️ Enhanced Type Safety and Schema Management**

This release focuses on improving type safety and schema management through Sorbet integration.

### ✨ New Features
- **Sorbet Integration**: Complete migration to Sorbet for enhanced type safety
- **JSON Schema Migration**: Migrated from Sorbet to JSON schema for better flexibility
- **Enhanced Tooling**: Improved development tools and specifications

### 🔧 Infrastructure
- **Comprehensive Spec Support**: Added spec support tools for better testing
- **Enhanced Testing Infrastructure**: Improved testing framework and utilities
- **Development Experience**: Better tooling and cleaner development processes

### 🐛 Improvements
- Enhanced clean-up processes and code organization
- Better specification handling and validation
- Improved development workflow and tooling

This release significantly improves the developer experience and code quality through better type safety and tooling.

## v0.1.0: v0.1.0: Initial Release

**Published**: 2025-07-01

## v0.1.0 - Initial Release

**🎉 First Release: Ruby DSPy Framework**

This is the initial release of DSPy.rb, a Ruby port of the DSPy framework for programming with large language models.

### ✨ Features
- **Core DSPy Framework**: Basic implementation of DSPy patterns in Ruby
- **Language Model Integration**: Initial LM provider support
- **Foundation Classes**: Basic Predict and signature functionality
- **Ruby Ecosystem Integration**: Native Ruby patterns and conventions

### 🏗️ Infrastructure
- **Gem Structure**: Complete Ruby gem setup with proper versioning
- **Testing Framework**: Initial test suite and infrastructure
- **Documentation**: Basic README and getting started guide

This release establishes the foundation for the DSPy.rb ecosystem.

