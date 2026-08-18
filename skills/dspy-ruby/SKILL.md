---
name: dspy-ruby
description: "Use for the dspy.rb gem ecosystem in Ruby - Sorbet-typed signatures, predictors (Predict, ChainOfThought, ReAct, CodeAct), composable DSPy::Module programs, Toolsets, DSPy::Evals metrics, and prompt optimization with MIPROv2 and GEPA. Trigger on 'dspy', 'dspy.rb', 'DSPy::Signature', 'DSPy::Predict', 'ChainOfThought', 'ReAct agent', 'typed LLM output', 'prompt optimization', 'GEPA', 'MIPROv2', or any request to make an LLM return a validated Ruby type rather than a string. Also use when a Ruby project is hand-rolling prompt templates and JSON parsing that dspy.rb would replace."
---

# RubyDev DSPy-Ruby — Typed LLM Programs with dspy.rb

## Overview

This skill covers **`dspy`** (`vicentereig/dspy.rb`, docs at oss.vicente.services/dspy.rb): the Ruby port of Stanford's DSPy. Its premise is that a prompt is an implementation detail, not an interface. You declare a *signature* — typed inputs, typed outputs, a task description — and a *module* renders the provider-specific prompt, parses the response, and coerces it into declared Sorbet types. Change providers, change schema format, or let an optimizer rewrite the instruction, and the signature stays the same.

**Core Mandate**: Declare the contract, not the prompt. If code is building a prompt string with interpolation and then parsing JSON out of the response, that is a signature waiting to be written.

**What the typed boundary does and does not buy you.** Type coercion proves the response *fit the declared shape*. It does not prove the answer was *right*. Those are separate claims established by separate machinery: signatures for shape, `DSPy::Evals` with examples and a metric for correctness. Conflating them is the single most common failure mode in DSPy.rb code — a program that always returns a valid `Sentiment` enum and is wrong 40% of the time will look healthy right up until someone measures it.

**⚠️ Verification notice**: API shapes below are drawn from the bundled reference docs in `references/`, which snapshot dspy.rb around **v1.0.2**. The gem's package split and optimizer APIs move quickly. Before writing production code, verify the exact API via Context7 MCP (library ID `/vicentereig/dspy.rb`) or against `references/api/merged_api.md`, per this plugin's standing verification mandate.

## When to Use

- Getting a validated Ruby object (enum, `T::Struct`, typed array) out of an LLM instead of a string to parse
- Building a bounded agent that selects among reviewed, typed tools (`DSPy::ReAct`)
- Composing multi-stage LLM programs where Ruby owns the control flow and the model owns the judgment calls
- Measuring whether an LLM program is actually correct (`DSPy::Evals`, examples, metrics)
- Optimizing instructions and few-shot examples against a metric (MIPROv2, GEPA) rather than by hand
- Replacing a hand-rolled prompt template + `JSON.parse` + `rescue` sandwich
- Migrating an existing raw prompt to a typed module while holding the comparison honest (`lm.raw_chat` baseline)

**Don't use for:**

- **Plain chat, streaming, or a one-shot completion with no typed contract** — that's `ruby_llm`; see [ruby-llm/SKILL.md](../ruby-llm/SKILL.md). dspy.rb can sit on top of RubyLLM as an adapter, but if there's no schema to enforce, the DSPy layer is overhead.
- **RAG architecture, chunking strategy, pgvector schema, RRF hybrid retrieval** — see [genai/SKILL.md](../genai/SKILL.md). That skill owns retrieval and storage; dspy.rb is what you call *after* retrieval, with the retrieved context as a typed input field.
- **Building an MCP server** — that's `fast-mcp`, in [genai/SKILL.md](../genai/SKILL.md).
- **Tokenization, POS tagging, lexical resources** — see [ruby-nlp/SKILL.md](../ruby-nlp/SKILL.md).
- **Non-LLM Ruby work** — use the [`rubyist` gateway agent](../../agents/rubyist.md).

## Package Map

dspy.rb is deliberately split: core ships signatures, modules, `Predict`/`ChainOfThought`/`ReAct`, Toolsets, and the evaluation runtime. Everything else — every provider, both optimizers, CodeAct, observability — is a separate gem. Installing only `dspy` and then configuring an `openai/*` model raises `DSPy::LM::MissingAdapterError`, which is the most common first-run failure.

| Gem | Purpose | Required when |
|:----|:--------|:--------------|
| `dspy` | Core: signatures, modules, Predict/ChainOfThought/ReAct, Toolsets, `DSPy::Evals` | Always |
| `dspy-openai` | Adapter for `openai/*`, `openrouter/*`, `ollama/*` model identifiers | Using OpenAI, OpenRouter, or Ollama |
| `dspy-anthropic` | Adapter for `anthropic/*`; also the only adapter supporting `DSPy::Reasoning` | Using Claude models |
| `dspy-gemini` | Adapter for `gemini/*` | Using Gemini |
| `dspy-ruby_llm` | Adapter routing through a configured `RubyLLM` client | Already standardized on `ruby_llm` (see [ruby-llm/SKILL.md](../ruby-llm/SKILL.md)) |
| `dspy-miprov2` | MIPROv2 optimizer — Bayesian search over instructions and demonstrations | Optimizing with MIPROv2 |
| `dspy-gepa` | GEPA optimizer — reflective evolution driven by textual metric feedback | Optimizing with GEPA |
| `dspy-code_act` | `DSPy::CodeAct` Think-Code-Observe agent that synthesizes and executes Ruby | Agent needs computation, not just tool selection |
| `dspy-evals` / `dspy-datasets` | Extended evaluation harness and dataset loaders | Beyond the core `DSPy::Evals` runtime |
| `dspy-o11y` / `dspy-o11y-langfuse` | OpenTelemetry spans; Langfuse OTLP export | Traces or scores must leave the process |
| `dspy-schema` | Standalone `DSPy::TypeSystem::SorbetJsonSchema` for non-DSPy projects | Reusing the Sorbet→JSON Schema converter elsewhere |

**Requirements**: Ruby 3.3+ and Bundler.

```ruby
# Gemfile
gem "dspy"
gem "dspy-openai"        # or dspy-anthropic / dspy-gemini / dspy-ruby_llm
gem "dspy-miprov2"       # only when optimizing with MIPROv2
gem "dspy-gepa"          # only when optimizing with GEPA
gem "dspy-code_act"      # only for Think-Code-Observe agents

group :development, :test do
  gem "dotenv"
end
```

The model-identifier prefix (`openai/`, `anthropic/`, …) selects the adapter and auto-requires it. It does **not** prove the model supports structured outputs, tools, images, or documents — those vary per model and SDK version even after the adapter loads.

## Configuration

dspy.rb reads only the value you pass to `api_key:`. **It does not load `.env` files.** Load them yourself, and prefer `ENV.fetch` so a missing key raises `KeyError` at boot rather than `DSPy::LM::MissingAPIKeyError` on the first request:

```ruby
# frozen_string_literal: true

require "dotenv/load"
require "dspy"

DSPy.configure do |config|
  config.lm = DSPy::LM.new(
    "openai/gpt-4o-mini",
    api_key: ENV.fetch("OPENAI_API_KEY")
  )
end
```

Resolution order is: an LM passed to the predictor → a fiber-local `DSPy.with_lm` block → the global `DSPy.configure` LM. Use `DSPy.with_lm` to run a cheap model for a subtree without rewiring construction:

```ruby
fast = DSPy::LM.new("openai/gpt-4o-mini", api_key: ENV.fetch("OPENAI_API_KEY"))

DSPy.with_lm(fast) do
  classifier.call(text: comment)  # this call only
end
```

## Core API Surface

### Signatures

A signature is the typed task boundary. Sorbet types drive schema generation *and* runtime coercion of the response:

```ruby
class ClassifyTicket < DSPy::Signature
  description "Classify a support ticket's priority and extract the affected systems"

  class Priority < T::Enum
    enums do
      Low      = new("low")
      Medium   = new("medium")
      High     = new("high")
      Critical = new("critical")
    end
  end

  input do
    const :ticket_body, String
    const :customer_tier, String, default: "standard"
  end

  output do
    const :priority, Priority
    const :affected_systems, T::Array[String], default: []
    const :confidence, Float
  end
end
```

Supported: `String`, `Integer`, `Float`, `T::Boolean`, `Date`, `DateTime`, `Time`, `T::Array[X]`, `T::Hash[K,V]`, `T::Enum`, `T::Struct`, and `T.any(...)` unions (DSPy adds a `_type` discriminator to struct variants so the response coerces to the right class).

Two type rules that bite people:

- **`T.nilable(X)` is not "optional."** It permits a `nil` *value*; the key stays in the schema's `required` list. Add `default:` when omission is legitimate. Note that a standalone `T::Struct` behaves differently — Sorbet treats a nilable const as fully optional there — so signature structs and plain structs are not interchangeable on this point.
- **Provider adapters can tighten the schema.** OpenAI strict structured outputs mark every property required, defaults included. Inspect the schema your adapter actually generates rather than assuming base DSPy omission rules survive.

Enum matching from the model is case-insensitive under Enhanced Prompting (`structured_outputs: false`), so `"HIGH"` still coerces. Under `structured_outputs: true` the provider enforces exact values.

Schema formats: JSON Schema (default), BAML (`schema_format: :baml`, Enhanced Prompting only, needs `sorbet-baml`), and TOON (`schema_format: :toon` for the prompt's schema block, `data_format: :toon` for the values themselves). BAML and TOON are shorter than JSON Schema for nested types — but *shorter is not better*. Measure tokens with your model's tokenizer and compare validation failure rates before switching.

Keep nesting to 1–2 levels. Three or more is workable but degrades reliably; five or more should be flattened or split into stages.

### Predictors

| Predictor | Shape | Use when |
|:----------|:------|:---------|
| `DSPy::Predict` | One request, response coerced to declared types | The task is one typed transformation |
| `DSPy::ChainOfThought` | Adds a `:reasoning` output field | You want the rationale — *whether it improves accuracy is an eval question, not a property of the class* |
| `DSPy::ReAct` | Bounded loop; model picks a typed tool or submits a final answer | The model has a genuine choice among reviewed tools |
| `DSPy::CodeAct` (`dspy-code_act`) | Think-Code-Observe; synthesizes and runs Ruby | The task needs computation the tools don't cover |

```ruby
classifier = DSPy::Predict.new(ClassifyTicket)
result = classifier.call(ticket_body: body, customer_tier: "enterprise")

result.priority           # => #<Priority::High>
result.affected_systems   # => ["billing-api"]
```

`ChainOfThought` injects `:reasoning` into the output. **Do not also declare `:reasoning` in the signature** — the collision produces undefined behavior.

Reach for `Predict` first. Escalate to `ChainOfThought` or `ReAct` only when an evaluation shows the simpler shape failing; each step up costs tokens and latency, and "agent" is not a quality tier.

### Modules

Subclass `DSPy::Module` when Ruby should own sequencing and branching, and the model should own only the judgment. `forward` is the method you define; `call` is the method you invoke (it runs the callback lifecycle around `forward`):

```ruby
class TicketTriage < DSPy::Module
  def initialize
    super
    @classify = DSPy::Predict.new(ClassifyTicket)
    @summarize = DSPy::ChainOfThought.new(SummarizeForOncall)
  end

  def forward(ticket_body:)
    classification = @classify.call(ticket_body: ticket_body)

    # Ruby owns this branch — the model was never asked to decide it
    return classification if classification.priority == ClassifyTicket::Priority::Low

    summary = @summarize.call(
      ticket_body: ticket_body,
      priority: classification.priority.serialize
    )
    { classification: classification, oncall_summary: summary.summary }
  end
end
```

Lifecycle callbacks (`before`, `around`, `after`) wrap `forward` for cross-cutting concerns. Order is `before → around(pre) → forward → around(post) → after`; inherited callbacks precede child ones; a raising `forward` runs `around`'s rescue path and **skips `after`**. Keep callback state per-call if the instance may be shared across threads or fibers.

If a custom module should participate in optimization, expose immutable update hooks (include `DSPy::Mixins::InstructionUpdatable`). Optimizers refuse to mutate instance variables directly and raise `DSPy::InstructionUpdateError` instead.

### Toolsets and ReAct

A `Toolset` groups related operations and exports selected methods as individually-named tools. Sorbet signatures generate each tool's JSON Schema:

```ruby
require "dspy/tools/toolset"

class OrderToolset < DSPy::Tools::Toolset
  extend T::Sig

  toolset_name "orders"
  tool :lookup, description: "Fetch an order's status by ID"

  sig { params(order_id: String).returns(T::Hash[String, String]) }
  def lookup(order_id:)
    order = Order.find_by(public_id: order_id)
    return { "error" => "not_found" } unless order

    { "status" => order.status, "placed_at" => order.created_at.iso8601 }
  end
end

agent = DSPy::ReAct.new(
  SupportAgentSignature,
  tools: OrderToolset.to_tools,
  max_iterations: 5
)
```

`to_tools` is a **class** method: it calls `new` with no arguments once and shares that instance across every exported proxy. A toolset destined for `to_tools` needs a zero-argument constructor, and `configured_instance.class.to_tools` will *not* preserve your configured instance. Inject dependencies through class-level configuration or a lazily-memoized reader instead.

The security boundary is the part people skip. A tool declaration is an interface, not permission:

- A schema does not authorize, sandbox, sanitize, rate-limit, or time-bound anything. All of that is deterministic Ruby you write around the operation.
- `max_iterations` bounds *model-directed steps*. It does not cancel a tool call already in flight — a slow query still hangs the request.
- The built-in `TextProcessingToolset`'s `text_grep` and `text_rg` interpolate patterns into shell strings with no timeout or output cap; `text_filter_lines` compiles model-supplied patterns as Ruby regexes. Export the pure-Ruby operations to agents; keep the shell-backed ones for trusted, application-supplied input.
- `GitHubCLIToolset` carries the caller's full `gh` authentication. Wrap the one operation you need behind a repository allowlist rather than handing an agent the whole proxy set.

Export the minimum reviewed proxies, and treat every argument the model produces as untrusted even when the module's own input was validated.

## Evaluation Before Optimization

Optimizers search for whatever the metric rewards. A vague metric produces a program that is confidently wrong in a new way, so build and inspect the metric *first*.

```ruby
examples = [
  DSPy::Example.new(
    signature_class: ClassifyTicket,
    input: { ticket_body: "Checkout returns 500 for all EU customers" },
    expected: { priority: ClassifyTicket::Priority::Critical },
    id: "eu-checkout-outage"
  )
]

# Boolean metric: counts passes.
exact = ->(example, prediction) do
  prediction.priority == example.expected_values[:priority]
end

# Hash metric: records the decision AND its components, so a regression
# in the part that matters is visible instead of averaged away.
graded = ->(example, prediction) do
  correct = prediction.priority == example.expected_values[:priority]
  calibrated = (prediction.confidence - (correct ? 1.0 : 0.0)).abs < 0.3
  { passed: correct, score: correct ? 1.0 : 0.0, calibration_ok: calibrated }
end

evaluator = DSPy::Evals.new(program, metric: graded, num_threads: 4)
result = evaluator.evaluate(examples)

result.pass_rate  # 0–1 scale
result.score      # 0–100 scale — different scale, same run
```

`BatchEvaluationResult#score` is 0–100 while `#pass_rate` is 0–1. Mixing them silently is an easy way to report a 95% pass rate as a 0.95 score or vice versa.

Exceptions become failed results rather than crashing the run; their metrics carry `:error`, `:passed`, and `:score`. `provide_traceback: true` stores the first ten backtrace frames in `metrics[:traceback]`, `failure_score` sets the score for exceptions, and `max_errors` stops scheduling after N failures. `num_threads` raises concurrent provider calls — watch rate limits and the cost of a full dataset pass.

Subclass hooks (`before_example`, `after_example`, `before_batch`, `after_batch`) and the `evals.example.complete` / `evals.batch.complete` events are available for progress reporting.

## Optimization

A program's prompt is immutable and inspectable. `with_instruction` and `with_examples` return *new* modules — there is no `prompt=` writer:

```ruby
predictor = DSPy::Predict.new(ClassifyTicket)
predictor.prompt.instruction
predictor.prompt.few_shot_examples.size

revised = predictor.with_instruction("Classify priority using the SLA matrix.")
```

Measure a baseline, compile, then compare on data the optimizer never saw:

```ruby
require "dspy/miprov2"

optimizer = DSPy::Teleprompt::MIPROv2.new(metric: graded)
result = optimizer.compile(program, trainset: train, valset: validation)

optimized = result.optimized_program   # deploy this, not the optimizer
```

**Choosing between them**: MIPROv2 runs Bayesian search over instructions and demonstrations and works with a plain pass/fail metric. GEPA evolves instructions from *textual feedback*, so it only earns its cost when your metric can explain **why** something failed, not merely that it did. If your metric returns a bare boolean, GEPA has nothing to reflect on — use MIPROv2 or enrich the metric first.

Hold back a test set that is separate from the optimizer's validation set. Candidate selection has already adapted to the validation data; reusing it for the final claim rewards whichever candidate happened to fit it.

Persist with `DSPy::Storage::ProgramStorage`, and record the dataset version, metric version, model, optimizer config, and validation score alongside the artifact — those are what explain what the program was selected to *do*. Reloading reconstructs the class named in the artifact, so that class and its signature must already be loaded and the program class must implement `.from_h`. Re-evaluate a loaded program before promoting it; persistence does not establish compatibility with a changed model or dependency.

## Anthropic Reasoning and Temperature

Newer Claude models changed sampling: some reject a custom temperature outright, some default extended thinking on. `DSPy::Reasoning` is a typed value object with exactly one mode per instance — an effort tier (`.low`/`.medium`/`.high`/`.xhigh`/`.max`) *or* a thinking mode (`.budget(n)`/`.adaptive`/`.disabled`), never both.

```ruby
lm = DSPy::LM.new(
  "anthropic/claude-sonnet-4-5",
  api_key: ENV.fetch("ANTHROPIC_API_KEY"),
  reasoning: DSPy::Reasoning.high,
  max_tokens: 8192
)
```

This is **`dspy-anthropic` only** — passing `reasoning:` to an OpenAI, Gemini, or Ollama-backed LM is not supported. The adapter validates the mode against the model at `DSPy::LM.new` time and raises `DSPy::LM::ConfigurationError` immediately rather than failing on the first request. `.budget(n)` requires `1024 <= n < max_tokens` and a model that still accepts manual budgets; adaptive-only models reject it. `reasoning:` composes with `structured_outputs: true` without extra configuration.

## Observability

The core event system is in-process and reports token usage only when the provider returns it:

```ruby
subscription = DSPy.events.subscribe("lm.tokens") do |_name, attrs|
  StatsD.increment("llm.tokens", attrs["gen_ai.usage.completion_tokens"].to_i)
end

DSPy.events.unsubscribe(subscription)   # long-lived processes leak without this
```

Subscribe through the event API rather than monkey-patching module internals — the events are the supported boundary and survive gem upgrades. Exporting traces off-process needs `dspy-o11y` plus `dspy-o11y-langfuse`, exporter configuration, credentials, and network access; `export_scores: true` on an evaluator routes per-example scores through `DSPy.score` to the same pipeline.

For a migration baseline, `lm.raw_chat` emits the same `lm.tokens` events as a typed module, so the old prompt and the new signature can be compared under one measurement harness.

## Failover

| Dependency | If unavailable | Fallback |
|:-----------|:---------------|:---------|
| Context7 / DeepWiki | Both unreachable | Fall back to `references/api/merged_api.md` in this skill. If that is also missing, annotate every non-core API call `[WARNING: API unverified]` and summarize the unverified surface at the end of the response. |
| `dspy-miprov2` / `dspy-gepa` | Not in Gemfile | Optimize by hand: `with_instruction` / `with_examples` variants scored through `DSPy::Evals` against a held-out set. Slower, but the measurement discipline is the valuable half anyway. |
| `dspy-o11y*` | Not in Gemfile | Subscribe to core `DSPy.events` in-process and emit through the app's existing logger. Cross-process latency must be reconstructed from timestamps. |
| Provider adapter for the target model | Missing (`MissingAdapterError`) | Name the exact gem for the model prefix and stop. Do not silently switch providers — model choice is an evaluation variable, not an implementation detail. |
| `dspy-code_act` | Not in Gemfile | Use `ReAct` with an explicit, reviewed toolset. Do not hand-roll `eval` of model-generated Ruby as a substitute; CodeAct's value is its execution boundary, and reimplementing that badly is worse than not having it. |

## Common Pitfalls

1. **Treating type validation as correctness.** A well-typed wrong answer is still wrong. Shape is `DSPy::Signature`'s job; correctness is `DSPy::Evals`'.
2. **`T.nilable` used to mean "optional."** It permits `nil`; the key stays required. Add `default:` for genuine omission.
3. **Declaring `:reasoning` in a signature used with `ChainOfThought`.** The predictor injects that field itself; the collision is undefined behavior.
4. **Installing only `dspy`.** No adapter means `DSPy::LM::MissingAdapterError` at the first configured model. The prefix picks the adapter, but the gem has to be there.
5. **Expecting `.env` to load itself.** dspy.rb reads only what you pass to `api_key:`. Use `dotenv` plus `ENV.fetch`.
6. **`to_tools` on a configured instance.** It constructs its own zero-arg instance; your configuration is discarded silently.
7. **Trusting `max_iterations` as a timeout.** It bounds model steps, not tool execution. A slow tool hangs regardless.
8. **Exporting shell-backed tools to an agent.** `text_grep`, `text_rg`, and the `gh` toolset take model-supplied arguments straight to a subprocess. Export pure-Ruby operations; wrap the rest.
9. **Optimizing before measuring.** Without a baseline on a held-out set, a higher validation score is evidence about the validation set, nothing more.
10. **Reusing the validation set for the final comparison.** Candidate selection already fit that data. Keep a test set the optimizer never touched.
11. **Confusing `score` (0–100) with `pass_rate` (0–1).** Same result object, different scales.
12. **Collapsing several concerns into one metric number.** Return a hash with named components so a regression in the part that matters stays visible.
13. **Deploying the optimizer instead of `result.optimized_program`.** And persist the dataset/metric/model provenance next to it, or the artifact is uninterpretable in six months.
14. **Passing `reasoning:` to a non-Anthropic LM.** Anthropic adapter only, validated at construction.
15. **Reaching for `ReAct` when `Predict` would do.** Agency is a cost, not a feature. Escalate on evidence.

## Verification Checklist

- [ ] Core API shapes verified via Context7 (`/vicentereig/dspy.rb`) or `references/api/merged_api.md` before relying on this skill's examples
- [ ] Gemfile carries `dspy` **plus** the adapter matching every model prefix in use
- [ ] API keys loaded via `ENV.fetch` inside `DSPy.configure`, with `.env` loaded explicitly
- [ ] Every output field that may legitimately be omitted has a `default:`, not just `T.nilable`
- [ ] Generated schema inspected against the actual adapter, not assumed from base DSPy rules
- [ ] No signature used with `ChainOfThought` declares its own `:reasoning` field
- [ ] Toolsets exported to agents are zero-arg constructible and free of shell interpolation
- [ ] Agent has an explicit `max_iterations`, plus real timeouts and output caps inside each tool
- [ ] `DSPy::Evals` baseline recorded before any optimization run
- [ ] Train / validation / test sets are distinct; the final claim uses the untouched test set
- [ ] Metric returns named components, not a single opaque number
- [ ] Optimized program persisted via `ProgramStorage` with dataset, metric, model, and optimizer provenance
- [ ] Event subscriptions unsubscribed in long-lived processes

## Reference Map

Bundled under `references/`. Grep these rather than reading them whole — several are large.

- **[references/api/merged_api.md](references/api/merged_api.md)** — merged API surface from docs and code analysis, one entry per class/method (~10k lines, no table of contents). Grep it: `grep -A5 'Predict' references/api/merged_api.md`. Entries marked "⚠️ Conflict" exist in the codebase but lack formal documentation.
- **Per-file API docs** — [references/codebase_analysis/vicentereig_dspy.rb/api_reference/](references/codebase_analysis/vicentereig_dspy.rb/api_reference/), one file per source file (`predict.md`, `re_act.md`, `signature.md`, `module.md`, `evals.md`, `lm.md`, `tools.md`, `code_act.md`, `observability.md`, …).
- **Official docs snapshot** — [references/documentation/dspy-ruby_docs/](references/documentation/dspy-ruby_docs/): [signatures](references/documentation/dspy-ruby_docs/signatures.md), [predictors](references/documentation/dspy-ruby_docs/predictors.md), [modules](references/documentation/dspy-ruby_docs/modules.md), [tools](references/documentation/dspy-ruby_docs/tools.md), [building](references/documentation/dspy-ruby_docs/building.md) (pipelines, RAG, multimodal, stateful agents), [evaluation](references/documentation/dspy-ruby_docs/evaluation.md), [optimization](references/documentation/dspy-ruby_docs/optimization.md), [production](references/documentation/dspy-ruby_docs/production.md) (events, Rails, storage, registry, observability, troubleshooting), [getting_started](references/documentation/dspy-ruby_docs/getting_started.md).
- **Repository** — [README](references/github/vicentereig_dspy.rb/README.md), [open issues](references/github/vicentereig_dspy.rb/issues.md), [releases](references/github/vicentereig_dspy.rb/releases.md), [architecture notes](references/codebase_analysis/vicentereig_dspy.rb/ARCHITECTURE.md).
- **[references/conflicts.md](references/conflicts.md)** — automated docs-vs-code diff. Mostly private methods from the repo's own `examples/` scripts; low signal, useful only when hunting for an undocumented internal.

Known issues worth knowing about as of this snapshot: **#251** (`ReAct` types `final_answer` from only the first output field, breaking multi-field signature outputs) and **#247** (no per-LM reasoning-effort control outside the Anthropic adapter). Check [issues.md](references/github/vicentereig_dspy.rb/issues.md) for current state.
