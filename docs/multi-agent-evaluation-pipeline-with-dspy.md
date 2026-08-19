# Building a Multi-Agent Evaluation Pipeline with DSPy

## Architecture Overview

The `rubyist` gateway agent orchestrates this. The pipeline follows a **design → build → evaluate → optimize** flow with clear agent boundaries:

```
cognitive-architect (plan)
    ↓
multi-db + ruby-nlp (parallel: store + text processing)
    ↓
ruby-llm (client integration)
    ↓
dspy-ruby (typed programs + evals + optimization)
    ↓
technical-writer → auditor
```

## Agent Dispatch Summary

| Stage | Agent | Input | Output |
|---|---|---|---|
| Architecture | `cognitive-architect` | User requirements | Component plan |
| Store layer | `multi-db` | Component plan | pgvector/Sequel models |
| Text processing | `ruby-nlp` | Component plan | Chunking, BM25, tokenization |
| LLM client | `ruby-llm` | Component plan | `ruby_llm` integration |
| Typed programs | `dspy-ruby` | Retrieved context | Signatures, modules, evals |
| Documentation | `technical-writer` | All code | YARD docs |
| Audit | `auditor` | All code | SIFT report |

## Step 1: Design (cognitive-architect)

The architect produces a **component plan** — no code:

```
ARCHITECTURE: <how pipeline composes and why>
COMPONENTS:
  - layer: store | text | client | typed-program | glue
    owner: multi-db | ruby-nlp | ruby-llm | dspy-ruby
    builds: <what this layer provides>
    interface: <what it accepts and returns>
DECISIONS: <choices made, alternatives rejected>
RISKS: <integration risks>
```

Layer ownership:

- **store** (`multi-db`) — pgvector tables, Ohm/Sequel models, payload separation, scalar filters
- **text** (`ruby-nlp`) — chunking, tokenization, segmentation, POS/dependency parsing, WordNet, TF-IDF/BM25, topic modeling
- **client** (`ruby-llm`) — `ruby_llm` chat, tool calling, streaming, embedding generation, structured output, MCP client
- **typed-program** (`dspy-ruby`) — Sorbet signatures, Predict/ChainOfThought/ReAct, Toolsets, evals, MIPROv2/GEPA. Runs *after* retrieval, taking context as a typed input field.

## Step 2: Build Signatures & Modules (dspy-ruby)

### Signatures

A signature is the typed task boundary. Sorbet types drive schema generation *and* runtime coercion of the response:

```ruby
class ClassifyTicket < DSPy::Signature
  description "Classify support ticket priority"

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

Supported types: `String`, `Integer`, `Float`, `T::Boolean`, `Date`, `DateTime`, `Time`, `T::Array[X]`, `T::Hash[K,V]`, `T::Enum`, `T::Struct`, and `T.any(...)` unions.

Two type rules that bite people:

- **`T.nilable(X)` is not "optional."** It permits a `nil` *value*; the key stays in the schema's `required` list. Add `default:` when omission is legitimate.
- **Provider adapters can tighten the schema.** OpenAI strict structured outputs mark every property required, defaults included.

### Predictors

| Predictor | Shape | Use when |
|---|---|---|
| `DSPy::Predict` | One request, response coerced to declared types | The task is one typed transformation |
| `DSPy::ChainOfThought` | Adds a `:reasoning` output field | You want the rationale |
| `DSPy::ReAct` | Bounded loop; model picks a typed tool or submits a final answer | The model has a genuine choice among reviewed tools |
| `DSPy::CodeAct` | Think-Code-Observe; synthesizes and runs Ruby | The task needs computation the tools don't cover |

Reach for `Predict` first. Escalate to `ChainOfThought` or `ReAct` only when an evaluation shows the simpler shape failing.

### Modules

Subclass `DSPy::Module` when Ruby should own sequencing and branching, and the model should own only the judgment:

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

### Toolsets and ReAct

A `Toolset` groups related operations and exports selected methods as individually-named tools:

```ruby
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

Security boundary: a tool declaration is an interface, not permission. Export the minimum reviewed proxies, and treat every argument the model produces as untrusted.

## Step 3: Define Metrics (before optimization)

Build and inspect the metric *first*. Optimizers search for whatever the metric rewards.

```ruby
# Boolean metric: counts passes
exact = ->(example, prediction) do
  prediction.priority == example.expected_values[:priority]
end

# Hash metric: records the decision AND its components
graded = ->(example, prediction) do
  correct = prediction.priority == example.expected_values[:priority]
  calibrated = (prediction.confidence - (correct ? 1.0 : 0.0)).abs < 0.3
  { passed: correct, score: correct ? 1.0 : 0.0, calibration_ok: calibrated }
end
```

Do not combine unrelated concerns into one number without recording the components. A single score can hide a regression in the behavior that matters most.

### Custom Metrics

```ruby
# Weighted accuracy — considers example difficulty
weighted_accuracy = ->(example, prediction) do
  correct = prediction.answer.downcase.strip == example.expected_answer.downcase.strip
  return false unless correct

  weight = example.metadata[:difficulty] || 1.0
  weight
end
```

### Score Reporting

Attach typed metric results to executions and export to Langfuse:

```ruby
require "dspy"
require "dspy/o11y/langfuse"

exporter = DSPy::Observability::Adapters::Langfuse::ScoresExporter.configure(
  secret_key: ENV.fetch("LANGFUSE_SECRET_KEY"),
  public_key: ENV.fetch("LANGFUSE_PUBLIC_KEY"),
  host: ENV.fetch("LANGFUSE_HOST", "https://cloud.langfuse.com")
)

score = DSPy.score("accuracy", 0.95, comment: "held-out evaluation")
```

## Step 4: Evaluate Baseline

```ruby
examples = [
  DSPy::Example.new(
    signature_class: ClassifyTicket,
    input: { ticket_body: "Checkout returns 500 for all EU customers" },
    expected: { priority: ClassifyTicket::Priority::Critical },
    id: "eu-checkout-outage"
  )
]

evaluator = DSPy::Evals.new(program, metric: graded, num_threads: 4)
result = evaluator.evaluate(examples)

result.pass_rate  # 0–1 scale
result.score      # 0–100 scale — different scale, same run
```

**Key rules:**

- `BatchEvaluationResult#score` is 0–100 while `#pass_rate` is 0–1. Mixing them silently is an easy way to report a 95% pass rate as a 0.95 score.
- Hold back a **test set** separate from the optimizer's validation set.
- Exceptions become failed results rather than crashing the run.
- `num_threads` raises concurrent provider calls — watch rate limits.

### Benchmarking Raw Prompts

Use `raw_chat` to establish a baseline before replacing with a typed module:

```ruby
lm = DSPy::LM.new("openai/gpt-4o-mini", api_key: ENV["OPENAI_API_KEY"])

result = lm.raw_chat do |m|
  m.system "You are a changelog generator."
  m.user "Generate a changelog for: feat: Add user auth, fix: Memory leak"
end
```

Both `raw_chat` and DSPy modules emit `lm.tokens` events — compare under one measurement harness.

## Step 5: Optimize

### MIPROv2 (Bayesian search)

Works with plain pass/fail metrics. Searches over instructions and few-shot demonstrations:

```ruby
require "dspy/miprov2"

optimizer = DSPy::Teleprompt::MIPROv2.new(metric: graded)
result = optimizer.compile(program, trainset: train, valset: validation)

optimized = result.optimized_program  # deploy this, not the optimizer
```

Presets follow the paper's guidance on trials, instruction candidates, and bootstrap batches.

### GEPA (Reflective evolution)

Needs metrics that explain *why* something failed, not merely that it did. The reflection model receives textual feedback and proposes instruction rewrites:

```ruby
require "dspy/gepa"

optimizer = DSPy::Teleprompt::GEPA.new(metric: graded)
result = optimizer.compile(program, trainset: train, valset: validation)
```

GEPA runs in iterative loops:

1. Run module on a small batch
2. Collect scores and short text notes about what happened
3. Reflection model rewrites the instruction
4. If rewrite helps on validation without regressing, keep as Pareto candidate

### Choosing Between Them

| Metric shape | Use |
|---|---|
| Bare boolean (pass/fail) | MIPROv2 |
| Hash with named components | Either |
| Hash with textual feedback explaining failures | GEPA |

## Step 6: Persist & Verify

```ruby
DSPy::Storage::ProgramStorage.save(
  optimized,
  metadata: {
    dataset_version: "v2",
    metric_version: "v1",
    model: "openai/gpt-4o-mini",
    optimizer: "miprov2",
    validation_score: result.score
  }
)
```

**Critical:** Re-evaluate loaded programs before promoting — persistence ≠ compatibility. Reloading reconstructs the class named in the artifact, so that class and its signature must already be loaded.

## Package Map

| Gem | Purpose | Required when |
|---|---|---|
| `dspy` | Core: signatures, modules, Predict/ChainOfThought/ReAct, Toolsets, `DSPy::Evals` | Always |
| `dspy-openai` | Adapter for `openai/*`, `openrouter/*`, `ollama/*` | Using OpenAI/OpenRouter/Ollama |
| `dspy-anthropic` | Adapter for `anthropic/*`; only adapter supporting `DSPy::Reasoning` | Using Claude |
| `dspy-gemini` | Adapter for `gemini/*` | Using Gemini |
| `dspy-ruby_llm` | Adapter routing through a configured `RubyLLM` client | Already on `ruby_llm` |
| `dspy-miprov2` | MIPROv2 optimizer | Optimizing with MIPROv2 |
| `dspy-gepa` | GEPA optimizer | Optimizing with GEPA |
| `dspy-code_act` | `DSPy::CodeAct` Think-Code-Observe agent | Agent needs computation |
| `dspy-evals` / `dspy-datasets` | Extended evaluation harness | Beyond core `DSPy::Evals` |
| `dspy-o11y` / `dspy-o11y-langfuse` | OpenTelemetry spans; Langfuse export | Traces must leave the process |

```ruby
# Gemfile
gem "dspy"
gem "dspy-openai"        # or dspy-anthropic / dspy-gemini / dspy-ruby_llm
gem "dspy-miprov2"       # only when optimizing with MIPROv2
gem "dspy-gepa"          # only when optimizing with GEPA
gem "dspy-code_act"      # only for Think-Code-Observe agents
```

## Configuration

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

Resolution order: LM passed to predictor → fiber-local `DSPy.with_lm` block → global `DSPy.configure` LM.

## Common Pitfalls

1. **Type validation ≠ correctness** — a well-typed wrong answer is still wrong. Shape is `Signature`'s job; correctness is `Evals`'.
2. **`score` (0–100) vs `pass_rate` (0–1)** — same result object, different scales.
3. **Optimizing before measuring** — no baseline = no evidence about improvement.
4. **Reusing validation set for final comparison** — candidate selection already fit that data.
5. **Reaching for ReAct when Predict would do** — agency is a cost, not a feature.
6. **Declaring `:reasoning` in a ChainOfThought signature** — the predictor injects that field itself; collision is undefined behavior.
7. **Installing only `dspy`** — no adapter means `MissingAdapterError` at the first model.
8. **Deploying the optimizer instead of `result.optimized_program`** — and without provenance metadata.
9. **Confusing `score` with `pass_rate`** — easy silent misreporting.
10. **Collapsing several concerns into one metric number** — return a hash with named components.

## Verification Checklist

- [ ] Core API shapes verified via Context7 (`/vicentereig/dspy.rb`) before relying on examples
- [ ] Gemfile carries `dspy` plus the adapter matching every model prefix in use
- [ ] API keys loaded via `ENV.fetch` inside `DSPy.configure`
- [ ] Every output field that may be omitted has a `default:`, not just `T.nilable`
- [ ] No signature used with `ChainOfThought` declares its own `:reasoning` field
- [ ] `DSPy::Evals` baseline recorded before any optimization run
- [ ] Train / validation / test sets are distinct
- [ ] Metric returns named components, not a single opaque number
- [ ] Optimized program persisted with dataset, metric, model, and optimizer provenance
- [ ] Event subscriptions unsubscribed in long-lived processes

## References

- [DSPy.rb Documentation](https://oss.vicente.services/dspy.rb)
- [DSPy.rb GitHub](https://github.com/vicentereig/dspy.rb)
- [MIPROv2 Paper](https://arxiv.org/abs/2406.11695v2) (Opsahl-Ong et al., 2024)
- [GEPA Paper](https://arxiv.org/abs/2507.19457) (Agrawal et al., 2025)
