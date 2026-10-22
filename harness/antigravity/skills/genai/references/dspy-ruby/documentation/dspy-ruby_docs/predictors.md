# Dspy-Ruby_Docs - Predictors

**Pages:** 5

---

## DSPy.rb Core Concepts: Signatures, Modules, and Predictors | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/

**Contents:**
- Core Concepts
- The Programming Model
  - Signatures
  - Predictors
  - Modules
  - Application State
- Learn the Concepts in Prerequisite Order
- Continue by task

Start with a signature, choose a predictor, then wrap calls in a module when the program needs reusable Ruby composition. Use ReAct later, when the model should choose among typed tools.

A signature declares typed inputs, outputs, and task instructions.

Execute a signature with Predict, ChainOfThought, or a bounded ReAct tool loop.

Encapsulate predictor calls and compose them with ordinary Ruby control flow.

Keep conversation history, user preferences, checkpoints, and other durable state in application-owned storage. Pass the state a module needs through typed inputs.

After these three abstractions, use the Build selector for examples, pipelines, retrieval, multimodal inputs, Toolsets, and stateful agents. Runtime context, events, interception, Rails, storage, observability, and troubleshooting live under Operate.

Read these concepts in order:

Evaluation defines acceptable behavior. Optimizers use examples, metrics, and feedback to search supported program parameters.

**Examples:**

Example 1 (unknown):
```unknown
ChainOfThought
```

---

## DSPy Predictors: Predict, ChainOfThought, and ReAct | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/predictors/

**Contents:**
- Predictors
- DSPy::Predict
  - Call Predict
  - Use the Configured Language Model
- DSPy::ChainOfThought
  - When to Use ChainOfThought
  - Call ChainOfThought
  - Read the Added Reasoning Field
- DSPy::ReAct
  - Define a Typed Tool

Predictors are modules that execute signatures. DSPy.rb provides Predict for one typed call, ChainOfThought for a typed call with an added reasoning field, and ReAct for a bounded tool-selection loop.

Executes a signature with one language-model request and converts the response to the declared output type.

Adds a reasoning field to the signature output. Whether that improves task quality is an evaluation question, not a property of the module.

Runs a bounded loop in which the model chooses a typed tool call or submits the final result.

CodeAct now ships separately as the dspy-code_act gem. Install it alongside dspy to access Think-Code-Observe agents that synthesize and execute Ruby code.

The predictor comparison still applies to CodeAct’s execution strategy; its package-specific API evolves independently from the core gem.

Concurrency is application-owned rather than a predictor type. See Concurrent Predictions for the runnable Async::Barrier pattern, failure policy, and measurement boundaries.

The core event subscription is in-process and reports usage only when the provider returns it. Trace export requires the optional observability packages, exporter configuration, credentials, and network access described in Observability. Predictors validate declared result types; evaluate task correctness separately with examples and a metric.

**Examples:**

Example 1 (unknown):
```unknown
ChainOfThought
```

Example 2 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify text sentiment and extract key topics"
  
  class Sentiment < T::Enum
    enums do
      Positive = new('positive')
      Negative = new('negative')
      Neutral = new('neutral')
    end
  end
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :topics, T::Array[String]
    const :confidence, Float
  end
end

# Create and use the predictor
classifier = DSPy::Predict.new(ClassifyText)
result = classifier.call(text: "I absolutely love the new features in this app!")

puts result.sentiment    # => #<Sentiment::Positive>
puts result.topics       # => ["app", "features"]
puts result.confidence   # => 0.92
```

Example 3 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify text sentiment and extract key topics"
  
  class Sentiment < T::Enum
    enums do
      Positive = new('positive')
      Negative = new('negative')
      Neutral = new('neutral')
    end
  end
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, Sentiment
    const :topics, T::Array[String]
    const :confidence, Float
  end
end

# Create and use the predictor
classifier = DSPy::Predict.new(ClassifyText)
result = classifier.call(text: "I absolutely love the new features in this app!")

puts result.sentiment    # => #<Sentiment::Positive>
puts result.topics       # => ["app", "features"]
puts result.confidence   # => 0.92
```

Example 4 (markdown):
```markdown
# Basic usage - uses global language model
predictor = DSPy::Predict.new(ClassifyText)
```

---

## Build DSPy.rb Programs and Agents | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/build/

**Contents:**
- Build with DSPy.rb
- Compose a Program
- Build an Agent
- Continue by task

Choose the smallest execution shape that owns the task. Use Ruby for known sequencing and branches; use a bounded agent when the model has a useful choice among reviewed tools.

Before choosing an execution shape, learn signatures, predictors, and modules. After the program works, evaluate its behavior.

---

## Concurrent Predictions | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/concurrent-predictions/

**Contents:**
- Concurrent Predictions
- Prerequisites
- Run, Join, and Preserve Failures
- Measure and Bound Concurrency
- Inspect Concurrency in Production
- Continue by task

Schedule a bounded set of independent predictor calls and collect every result. This is application-owned Ruby control flow; DSPy.rb does not create concurrent child tasks for a batch.

Define and call one predictor first in Predictors. Add gem 'async', '~> 2.29' to the application, then require async and async/barrier.

The complete program below uses the same OpenAI setup as Quick Start. Save it as concurrent_predictions.rb and run it with bundle exec ruby concurrent_predictions.rb.

The barrier joins every child task, and tasks.map(&:wait) preserves input order. Each child converts its own exception into a result, so one provider failure does not erase successful siblings. The batch rejects more than three inputs before creating tasks; use a worker pool or semaphore when the input source itself is unbounded. Timeouts, retries, idempotency, and cancellation remain application and provider concerns.

Concurrency overlaps waits only when the provider SDK and transport cooperate with Ruby’s scheduler. Measure sequential and concurrent runs against the adapter, model, rate limit, and payload shape you deploy. Record wall-clock latency, successful throughput, provider throttles, timeouts, and partial failures.

The example’s measured limit is MAX_BATCH_SIZE. Increase it only while throughput improves without unacceptable throttling, queue growth, or error rate; Async::Barrier joins tasks but does not rate-limit them.

**Examples:**

Example 1 (unknown):
```unknown
gem 'async', '~> 2.29'
```

Example 2 (unknown):
```unknown
async/barrier
```

Example 3 (unknown):
```unknown
concurrent_predictions.rb
```

Example 4 (unknown):
```unknown
bundle exec ruby concurrent_predictions.rb
```

---

## Reasoning | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/reasoning/

**Contents:**
- Reasoning Effort & Temperature
- The problem this solves
- DSPy::Reasoning
  - Effort tiers vs. extended thinking
  - Model support varies by family
- temperature
- max_tokens
- Structured outputs compose with reasoning
- Continue by task

Anthropic’s newer Claude models (Sonnet 5, Opus 4.7/4.8, Fable 5, Mythos 5, and others) changed how sampling and “thinking” work: some reject a custom temperature outright, some default extended thinking to on, and all of them expose a documented effort tier independent of thinking. DSPy::Reasoning and the temperature:/max_tokens: constructor options give you a typed way to control this per DSPy::LM instance.

Provider support: this is currently implemented for the Anthropic adapter only (dspy-anthropic). Passing reasoning: to an OpenAI, Gemini, or Ollama-backed DSPy::LM is not supported yet — see DSPy::LM Migration for the tracking issue on other providers.

Some Claude models reject a non-default temperature:

Before this feature, dspy-anthropic unconditionally sent temperature: 0.0 and max_tokens: 4096 on every request, with no way to override either. DSPy::LM.new(..., temperature: nil) would even raise ArgumentError: unknown keyword: :temperature.

As of this release, the Anthropic adapter:

DSPy::Reasoning is a typed, provider-agnostic value object. Exactly one mode is set per instance:

Pass it to DSPy::LM.new:

.max is not part of Anthropic’s originally-sketched effort tiers in the tracking issue; it’s included because Anthropic documents it as a real output_config.effort value.

Effort (.low/.medium/.high/.xhigh/.max) and extended thinking (.budget/.adaptive/.disabled) are independent Anthropic features. DSPy::Reasoning only lets you set one or the other per value — you can’t construct a single DSPy::Reasoning that means “effort: high AND a manual thinking budget.” If you need both, that’s a real limitation of the current API; please open an issue if it blocks you.

That said, on opt-in-adaptive model families (Opus 4.7/4.8, Opus/Sonnet 4.6), the adapter automatically adds thinking: { type: "adaptive" } whenever you pass an effort tier. Anthropic’s docs are explicit that these models run without thinking unless that flag is set, independent of output_config.effort — so without this, DSPy::Reasoning.high on Opus 4.8 would silently change token spend without engaging the model’s actual reasoning. On models where thinking is already on by default (Sonnet 5) or always on (Fable 5, Mythos 5), or where adaptive thinking isn’t available at all (Opus 4.5), effort tiers are sent as-is with no implicit thinking param.

Not every Claude model supports every DSPy::Reasoning mode. The adapter validates your choice against the model at DSPy::LM.new construction time and raises DSPy::LM::ConfigurationError immediately if it’s unsupported — you don’t have to wait for a request to fail:

DSPy::Reasoning.budget(n) also validates 1024 <= n < max_tokens, matching Anthropic’s documented minimum and the API’s own budget_tokens < max_tokens requirement.

temperature: now has three distinct states:

If you never pass temperature: or reasoning: at all, existing code keeps working exactly as before on models that don’t have this restriction (temperature: 0.0 is still sent). The fix is entirely about not sending an incompatible default — it does not change behavior for classic models.

max_tokens: is a regular constructor option, defaulting to 4096:

Increase it when using DSPy::Reasoning.budget(n) with a large token budget, since Anthropic requires budget_tokens < max_tokens. Note that .budget(n) requires a model where manual thinking budgets are still supported (e.g. Opus/Sonnet 4.6); newer models like Opus 4.7/4.8 or Sonnet 5 are adaptive-only and reject manual budgets — use DSPy::Reasoning.adaptive or an effort tier on those instead.

Effort and structured-output schemas share a single output_config request parameter under the hood — reasoning: works alongside structured_outputs: true (the default) without any extra configuration:

**Examples:**

Example 1 (unknown):
```unknown
temperature
```

Example 2 (yaml):
```yaml
DSPy::Reasoning
```

Example 3 (yaml):
```yaml
temperature:
```

Example 4 (yaml):
```yaml
max_tokens:
```

---
