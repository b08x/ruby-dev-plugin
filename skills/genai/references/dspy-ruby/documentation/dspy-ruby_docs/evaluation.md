# Dspy-Ruby_Docs - Evaluation

**Pages:** 4

---

## Evaluation | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/evaluation/

**Contents:**
- Evaluation Framework
- Define Examples
- Define a Metric
- Run an Evaluation
- Result Objects
- Inspect Failures
- Use Numeric Scores
- Run in Parallel
- Callbacks and Events
- Evaluate an Optimized Program

The package and capability matrix records how the dspy-evals and dspy-datasets packages relate to the evaluation runtime shipped by core.

DSPy::Evals runs a program against DSPy::Example objects and applies a metric to each prediction. Evaluation measures the behavior named by that metric; typed output validation alone does not establish correctness.

Examples use the same signature as the program:

Construction validates the input and expected output against the signature. Use example.input_values and example.expected_values inside metrics and debugging code.

A metric receives an example and the program’s prediction:

Boolean metrics count passing examples. To report a numeric score, return a hash with :passed and :score. Keep numeric ranges and thresholds explicit so readers can interpret the result.

Pass the program and metric to DSPy::Evals, then evaluate the dataset:

BatchEvaluationResult#score is expressed on a 0-100 scale. pass_rate is expressed on a 0-1 scale.

evaluate also accepts display_progress:, display_table:, and return_outputs:. The current implementation always returns a BatchEvaluationResult; return_outputs: remains available for API compatibility.

BatchEvaluationResult exposes:

The evaluator also keeps last_example_result and last_batch_result for inspection after a run.

Each EvaluationResult contains the example, prediction, trace, metric values, and pass status:

Provider, program, and metric exceptions become failed results. Their metrics include :error, :passed, and :score. With provide_traceback: true, the evaluator also stores the first ten backtrace entries in metrics[:traceback]. The trace reader contains only a trace explicitly passed to Evals#call; use application traces and logs for provider or module execution details.

A metric hash can record a threshold decision, an aggregate score, and named component metrics:

Do not combine unrelated concerns into one number without recording the components. A single score can hide a regression in the behavior that matters most.

The batch result reports label_match_avg, label_match_min, and label_match_max under aggregated_metrics.

Set num_threads on the evaluator when calls are independent:

Parallel evaluation increases concurrent provider calls. Keep provider rate limits and the cost of the full dataset in view.

max_errors stops scheduling new examples after the configured number of failed results. failure_score supplies the score for exceptions, and provide_traceback controls backtrace capture:

With parallel evaluation, the evaluator finishes the current group of submitted examples before checking the limit again.

Subclasses can observe individual examples and complete batches:

Available class callbacks are before_example, after_example, before_batch, and after_batch. DSPy.rb also emits evals.example.complete and evals.batch.complete events.

Set export_scores: true to send per-example and batch scores through DSPy.score; score_name: changes the exported score name. Export requires the corresponding scores and observability integration to be configured.

Use the same held-out examples and metric for the baseline and optimized program:

Do not use the optimizer’s validation set for this final comparison. Candidate selection has already adapted to that data.

**Examples:**

Example 1 (unknown):
```unknown
dspy-datasets
```

Example 2 (yaml):
```yaml
DSPy::Evals
```

Example 3 (yaml):
```yaml
DSPy::Example
```

Example 4 (php):
```php
class Sentiment < DSPy::Signature
  input do
    const :text, String
  end

  output do
    const :label, String
  end
end

examples = [
  DSPy::Example.new(
    signature_class: Sentiment,
    input: { text: "The release fixed my issue." },
    expected: { label: "positive" },
    id: "positive-1"
  ),
  DSPy::Example.new(
    signature_class: Sentiment,
    input: { text: "The request timed out." },
    expected: { label: "negative" },
    id: "negative-1"
  )
]
```

---

## Benchmarking Raw Prompts | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/benchmarking-raw-prompts/

**Contents:**
- Benchmarking Raw Prompts
- Establish a Comparable Baseline
- Using raw_chat
  - Array Format
  - DSL Format
- Capturing Observability Data
- Run a Changelog Benchmark
- Compare Multiple Providers
- Capture Both Paths in Observability
- Benchmarking Schema Formats

Use raw_chat to establish a baseline for an existing provider prompt before replacing it with a typed module. Compare both implementations with the same model, inputs, metric, and telemetry.

The raw_chat method supports two formats: array format and DSL format.

Both raw_chat and DSPy modules emit lm.tokens events. Subscribe around one call so each measurement owns its event buffer and elapsed time:

The following example compares a monolithic changelog generator with a modular DSPy implementation:

Compare performance across different LLM providers:

raw_chat emits DSPy log events and spans; configure the selected observability integration to capture both paths:

DSPy.rb supports JSON Schema and BAML schema rendering. Measure both formats on your actual signature; the difference depends on schema shape and provider formatting.

Do not infer output quality from schema length. Compare validation failures and task metrics beside token counts.

See Schema Formats for detailed comparison.

Keep the baseline when the module does not improve the metric or operational boundary that motivated the migration. A typed interface is useful, but it does not make a weaker result acceptable.

**Examples:**

Example 1 (scala):
```scala
lm = DSPy::LM.new('openai/gpt-4o-mini', api_key: ENV['OPENAI_API_KEY'])

result = lm.raw_chat([
  { role: 'system', content: 'You are a helpful assistant.' },
  { role: 'user', content: 'What is the capital of France?' }
])

puts result # => "The capital of France is Paris."
```

Example 2 (scala):
```scala
lm = DSPy::LM.new('openai/gpt-4o-mini', api_key: ENV['OPENAI_API_KEY'])

result = lm.raw_chat([
  { role: 'system', content: 'You are a helpful assistant.' },
  { role: 'user', content: 'What is the capital of France?' }
])

puts result # => "The capital of France is Paris."
```

Example 3 (lua):
```lua
result = lm.raw_chat do |m|
  m.system "You are a changelog generator. Format output as markdown."
  m.user "Generate a changelog for: feat: Add user auth, fix: Memory leak"
end

puts result # => "# Changelog\n\n## Features\n- Add user authentication..."
```

Example 4 (lua):
```lua
result = lm.raw_chat do |m|
  m.system "You are a changelog generator. Format output as markdown."
  m.user "Generate a changelog for: feat: Add user auth, fix: Memory leak"
end

puts result # => "# Changelog\n\n## Features\n- Add user authentication..."
```

---

## Custom Metrics | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/custom-metrics/

**Contents:**
- Custom Metrics
- Choose a Metric Shape
- Built-in Score Evaluators
- Implement Scalar Metrics
  - Return a Boolean Score
  - Weighted Accuracy Metric
  - Confidence-Aware Metric
- Domain-Specific Metrics
  - Customer Service Quality Metric
  - Medical Information Accuracy Metric

A metric turns an example and a prediction into the score an evaluator or optimizer should use. Keep the metric close to the behavior you can inspect: exact fields, bounded numeric scores, or explicit feedback.

Custom metrics in DSPy.rb:

Before creating a custom metric, check the exact-match, containment, regex, length, similarity, and JSON-validity evaluators in Score Reporting. That guide owns their arguments, ScoreEvent result, exporter configuration, and delivery boundaries. Continue here when the application outcome needs domain-specific logic.

**Examples:**

Example 1 (elixir):
```elixir
# Define a custom accuracy metric
accuracy_metric = ->(example, prediction) do
  return false unless prediction && prediction.respond_to?(:answer)
  prediction.answer.downcase.strip == example.expected_answer.downcase.strip
end

# Use with evaluator
program = DSPy::Predict.new(YourSignature)
evaluator = DSPy::Evals.new(program, metric: accuracy_metric)

result = evaluator.evaluate(test_examples)

puts "Custom accuracy: #{(result.pass_rate * 100).round(1)}%"
```

Example 2 (elixir):
```elixir
# Define a custom accuracy metric
accuracy_metric = ->(example, prediction) do
  return false unless prediction && prediction.respond_to?(:answer)
  prediction.answer.downcase.strip == example.expected_answer.downcase.strip
end

# Use with evaluator
program = DSPy::Predict.new(YourSignature)
evaluator = DSPy::Evals.new(program, metric: accuracy_metric)

result = evaluator.evaluate(test_examples)

puts "Custom accuracy: #{(result.pass_rate * 100).round(1)}%"
```

Example 3 (julia):
```julia
# Metric that considers example difficulty/importance
weighted_accuracy = ->(example, prediction) do
  return false unless prediction && prediction.respond_to?(:answer)
  
  # Base correctness
  correct = prediction.answer.downcase.strip == example.expected_answer.downcase.strip
  return false unless correct
  
  # Apply weight based on example metadata
  weight = example.metadata[:difficulty] || 1.0
  
  # Return weighted score (true/false gets converted to 1.0/0.0)
  weight
end

# Use in evaluation
program = DSPy::Predict.new(YourSignature)
evaluator = DSPy::Evals.new(program, metric: weighted_accuracy)
```

Example 4 (julia):
```julia
# Metric that considers example difficulty/importance
weighted_accuracy = ->(example, prediction) do
  return false unless prediction && prediction.respond_to?(:answer)
  
  # Base correctness
  correct = prediction.answer.downcase.strip == example.expected_answer.downcase.strip
  return false unless correct
  
  # Apply weight based on example metadata
  weight = example.metadata[:difficulty] || 1.0
  
  # Return weighted score (true/false gets converted to 1.0/0.0)
  weight
end

# Use in evaluation
program = DSPy::Predict.new(YourSignature)
evaluator = DSPy::Evals.new(program, metric: weighted_accuracy)
```

---

## Score Reporting | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/score-reporting/

**Contents:**
- Score Reporting
- Prerequisites
- Create and Export a Typed Score
- Use Built-in Evaluators
- Connect Scores to Their Owners
- Continue by task

Attach a named evaluation result to an execution and, optionally, export it to Langfuse. A score reports metric output; it does not make a trace evidence of correctness.

Define the behavior being measured in Evaluation or Custom Metrics. Langfuse is optional; install dspy-o11y and dspy-o11y-langfuse, then follow Observability only when scores must leave the process.

The complete program creates one typed score, observes its score.create event, queues it for Langfuse, and shuts the exporter down. Save it as report_score.rb after installing the prerequisite packages.

DSPy.score returns a DSPy::Scores::ScoreEvent and emits score.create. DataType::Numeric is the default; pass DataType::Boolean for 0 or 1, or DataType::Categorical for labels. Pass trace_id: or observation_id: when explicit correlation is required; otherwise the score uses current trace context when one exists.

The exporter consumes the same event asynchronously. Queueing is not delivery: network errors are retried up to max_retries and then logged. shutdown has a five-second default join timeout and may return without proving delivery or terminating the worker. Decide whether failed telemetry is best-effort or an operational alert.

DSPy::Scores::Evaluators owns exact-match, containment, regex, length, similarity, and JSON-validity scoring. Each evaluator receives complete values and returns a ScoreEvent; for example, exact_match(output: "Hello", expected: "hello", ignore_case: true) returns a numeric score event.

Use Custom Metrics when those predicates do not represent the application outcome. To emit evaluation scores automatically, construct DSPy::Evals with an existing program and metric plus export_scores: true and score_name: "qa_accuracy"; the evaluator emits one score per example and a qa_accuracy_batch score. The default is false.

**Examples:**

Example 1 (unknown):
```unknown
dspy-o11y-langfuse
```

Example 2 (unknown):
```unknown
score.create
```

Example 3 (unknown):
```unknown
report_score.rb
```

Example 4 (julia):
```julia
require 'dspy'
require 'dspy/o11y/langfuse'

exporter = DSPy::Observability::Adapters::Langfuse::ScoresExporter.configure(
  secret_key: ENV.fetch('LANGFUSE_SECRET_KEY'),
  public_key: ENV.fetch('LANGFUSE_PUBLIC_KEY'),
  host: ENV.fetch('LANGFUSE_HOST', 'https://cloud.langfuse.com')
)

observed_scores = []
subscription = DSPy.events.subscribe('score.create') do |_event_name, attributes|
  observed_scores << attributes
end

begin
  score = DSPy.score(
    'accuracy',
    0.95,
    comment: 'held-out evaluation',
    trace_id: 'evaluation-run-42'
  )
ensure
  DSPy.events.unsubscribe(subscription)
  exporter.shutdown
end

puts "#{score.name}=#{score.value} trace=#{score.trace_id}"
puts "events=#{observed_scores.length}"
```

---
