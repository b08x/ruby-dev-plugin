# Dspy-Ruby_Docs - Production

**Pages:** 8

---

## Events | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/events/

**Contents:**
- Event System
- Two Subscription Patterns
  - Pattern 1: Module-Scoped Subscriptions
  - Pattern 2: Global Subscriptions (For Observability/Integrations)
- Emitting Events
- Global Listeners
- Module-Scoped Subscribers
- Module Stack Metadata
- Choose Listener Ownership and Teardown

DSPy.rb provides a structured event bus for module instrumentation and integrations. Emit events, subscribe globally or by module scope, and unsubscribe when the listener’s lifetime ends.

Choose a subscription scope by listener lifetime:

Use the subscribe DSL inside your modules. Subscriptions automatically scope to the module instance and its descendants:

When to use: Modules with internal state or any listener whose lifetime should match a module instance.

Use DSPy.events.subscribe directly for cross-cutting concerns:

When to use: Observability exporters (Langfuse, Datadog), centralized logging, metrics collection, or any cross-cutting concern that spans multiple modules.

Call DSPy.event for application events that subscribers should receive:

Event naming, attributes, and types:

To receive every event, subscribe directly to the registry:

Wildcard and teardown rules:

For custom tracking, create a class that manages subscriptions:

Call tracker.unsubscribe when you are done.

Every DSPy::Module can declare listeners scoped to its instance and, by default, descendants invoked inside it:

Because the subscribe call does not specify a scope, it listens to events emitted by the ResearchReport module and both nested Predict instances. Use scope: DSPy::Module::SubcriptionScope::SelfOnly to ignore descendants, for example when logging only the parent module’s own search.result events.

Scope and metadata rules:

The context layer tracks a stack of modules whenever DSPy::Module#forward runs. Each entry contains:

Use this metadata to power Langfuse filters, scoped metrics, or custom routing.

The event bus separates module behavior from token accounting, tracing exports, and custom domain instrumentation.

**Examples:**

Example 1 (julia):
```julia
class MyAgent < DSPy::Module
  subscribe 'lm.tokens', :track_tokens, scope: :descendants

  def track_tokens(_event, attrs)
    @total_tokens += attrs.fetch(:total_tokens, 0)
  end
end
```

Example 2 (julia):
```julia
class MyAgent < DSPy::Module
  subscribe 'lm.tokens', :track_tokens, scope: :descendants

  def track_tokens(_event, attrs)
    @total_tokens += attrs.fetch(:total_tokens, 0)
  end
end
```

Example 3 (unknown):
```unknown
DSPy.events.subscribe
```

Example 4 (julia):
```julia
subscription_id = DSPy.events.subscribe('score.create') do |event, attrs|
  Langfuse.export_score(attrs)
end
```

---

## Production Guide | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/

**Contents:**
- Production Guide
- Choose an Operational Concern
  - Events
  - Module Runtime Context
  - Module Lifecycle Callbacks
  - Concurrent Predictions
  - Interception and Monkey-Patching
  - Rails
  - Storage
  - Registry

Production applications need explicit ownership of artifacts, telemetry, failures, secrets, and provider budgets. DSPy.rb supplies storage, registry, and observability components; the application still owns deployment policy and recovery.

Subscribe to typed runtime events for application integrations.

Scope language-model selection and propagation across module calls.

Add ordered before, around, and after behavior to a module call.

Join independent predictor calls under an explicit failure policy and measured limit.

Prefer supported event interception and identify the narrow cases where a monkey patch remains necessary.

Place DSPy.rb configuration and calls within Rails services, jobs, caching, and instrumentation.

Persist optimized programs and their metadata with the storage API.

Register and promote versioned program artifacts across environments.

Export module, LM, tool, and optimizer telemetry through OpenTelemetry.

Create typed evaluation scores and bound asynchronous Langfuse delivery.

Diagnose configuration, provider, parsing, dependency, and test failures.

---

## Observability Interception | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/observability-interception/

**Contents:**
- Event System vs Monkey-Patching
- Identify the Patch Boundary
  - Replace a Logger Backend
- Subscribe Through the Event API
  - Token Cost Tracking
  - Rate Limiting
  - Audit Logging
- Compare the Supported Boundaries
  - Event API properties
  - Monkey-patch liabilities

Subscribe to DSPy.rb events when you need custom metrics or logs. The public event API avoids replacing logger internals or patching module methods.

Replacing logger backends reaches into internals that the public event API already exposes:

The event system exposes subscriptions without replacing logger or module internals:

See working implementations:

**Examples:**

Example 1 (python):
```python
class EventInterceptorBackend < Dry::Logger::Backends::Stream
  def call(entry)
    if handler = @event_handlers[entry[:event]]
      handler.call(entry)
    end
    super
  end
end

DSPy.configure do |config|
  config.logger = Dry.Logger(:dspy) do |logger|
    logger.add_backend(EventInterceptorBackend.new(stream: "log/production.log"))
  end
end
```

Example 2 (python):
```python
class EventInterceptorBackend < Dry::Logger::Backends::Stream
  def call(entry)
    if handler = @event_handlers[entry[:event]]
      handler.call(entry)
    end
    super
  end
end

DSPy.configure do |config|
  config.logger = Dry.Logger(:dspy) do |logger|
    logger.add_backend(EventInterceptorBackend.new(stream: "log/production.log"))
  end
end
```

Example 3 (elixir):
```elixir
class TokenCostTracker
  def initialize
    @costs = Hash.new(0.0)
    @subscriptions = []
    @subscriptions << DSPy.events.subscribe('llm.*') do |event_name, attributes|
      model = attributes['gen_ai.request.model']
      input_tokens = attributes['gen_ai.usage.prompt_tokens'] || 0
      output_tokens = attributes['gen_ai.usage.completion_tokens'] || 0

      cost = calculate_cost(model, input_tokens, output_tokens)
      @costs[model] += cost

      puts "#{model}: $#{cost.round(4)} (total: $#{@costs[model].round(2)})"
    end
  end

  def unsubscribe
    @subscriptions.each { |id| DSPy.events.unsubscribe(id) }
    @subscriptions.clear
  end
end

tracker = TokenCostTracker.new
# Tracks subscribed llm.* events until tracker.unsubscribe is called.
```

Example 4 (elixir):
```elixir
class TokenCostTracker
  def initialize
    @costs = Hash.new(0.0)
    @subscriptions = []
    @subscriptions << DSPy.events.subscribe('llm.*') do |event_name, attributes|
      model = attributes['gen_ai.request.model']
      input_tokens = attributes['gen_ai.usage.prompt_tokens'] || 0
      output_tokens = attributes['gen_ai.usage.completion_tokens'] || 0

      cost = calculate_cost(model, input_tokens, output_tokens)
      @costs[model] += cost

      puts "#{model}: $#{cost.round(4)} (total: $#{@costs[model].round(2)})"
    end
  end

  def unsubscribe
    @subscriptions.each { |id| DSPy.events.unsubscribe(id) }
    @subscriptions.clear
  end
end

tracker = TokenCostTracker.new
# Tracks subscribed llm.* events until tracker.unsubscribe is called.
```

---

## Rails Integration Guide | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/rails-integration/

**Contents:**
- Rails Integration Guide
- Enum Handling
  - Recognize the enum mismatch
  - Compare the declared enum
  - Working with ActiveRecord Enums
  - Debugging Enum Values
- Service Object Pattern
- ActiveJob Integration
- Rails Cache Integration
- Configuration in Rails

Place enum coercion, provider calls, caching, callbacks, and instrumentation behind explicit Rails service and job boundaries.

DSPy.rb coerces returned enum strings into the T::Enum declared by the signature.

You might see code like this in Rails applications:

When a signature declares a T::Enum, prediction coercion converts a compatible returned string to that enum:

When integrating with ActiveRecord enums, you can map between DSPy enums and Rails enums:

If you’re unsure about the enum value, use these debugging techniques:

Use a Rails service object to keep the provider call, returned value, and application mapping together:

Process AI tasks asynchronously:

Cache AI responses to reduce API calls:

Set up DSPy in an initializer:

Add validations for enum fields:

Create form helpers for enum fields:

Test your DSPy integrations:

DSPy modules support before, after, and around lifecycle callbacks. For callback order and failure behavior, see Module Lifecycle Callbacks.

Use callbacks to add instrumentation, logging, or state management to service objects:

Use callbacks to load and save state through the ActiveRecord boundary around each module call:

Extract reusable callback behavior into Rails concerns:

Use callbacks to manage job state and error tracking:

Integrate with Rails’ ActiveSupport::Notifications:

For enum fields, compare the returned value with enum constants and call .serialize before storing it in a string column. Keep provider calls in service objects or jobs where timeout, retry, and telemetry policy are explicit.

**Examples:**

Example 1 (sass):
```sass
# Workaround code (NOT NEEDED)
result = OpenStruct.new(
  sub_queries: raw_result.sub_queries,
  search_strategy: raw_result.search_strategy,  # Manual enum handling
  discovered_topics: raw_result.discovered_topics,
  reasoning: raw_result.reasoning
)
```

Example 2 (sass):
```sass
# Workaround code (NOT NEEDED)
result = OpenStruct.new(
  sub_queries: raw_result.sub_queries,
  search_strategy: raw_result.search_strategy,  # Manual enum handling
  discovered_topics: raw_result.discovered_topics,
  reasoning: raw_result.reasoning
)
```

Example 3 (json):
```json
class SearchStrategy < DSPy::Signature
  class Strategy < T::Enum
    enums do
      Parallel = new('parallel')
      Sequential = new('sequential')
      Hybrid = new('hybrid')
    end
  end
  
  output do
    const :strategy, Strategy
  end
end

# When LLM returns: { "strategy": "parallel" }
# DSPy automatically converts to: Strategy::Parallel
result = predictor.call(query: "search term")
puts result.strategy.class  # => SearchStrategy::Strategy::Parallel
```

Example 4 (json):
```json
class SearchStrategy < DSPy::Signature
  class Strategy < T::Enum
    enums do
      Parallel = new('parallel')
      Sequential = new('sequential')
      Hybrid = new('hybrid')
    end
  end
  
  output do
    const :strategy, Strategy
  end
end

# When LLM returns: { "strategy": "parallel" }
# DSPy automatically converts to: Strategy::Parallel
result = predictor.call(query: "search term")
puts result.strategy.class  # => SearchStrategy::Strategy::Parallel
```

---

## Storage | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/storage/

**Contents:**
- Storage System
- Define What Storage Persists
- Save and Load a Program
  - Storing Optimization Results
  - Save Through StorageManager
  - Loading Programs
- Storage Organization
- Finding Programs
  - Search by Criteria
  - Get Best Program

The storage API persists optimization results and serialized program state. Use it to reload an optimized program and retain the metadata needed to identify the run that produced it.

The storage system provides:

The storage system uses a file-based approach with JSON serialization:

Create and restore checkpoints during long-running optimizations:

Share programs between environments or backup your optimizations:

Track optimization trends and performance over time:

Compare two saved programs:

Manage storage space by removing old programs:

The storage system emits structured log events for monitoring:

Always include descriptive metadata for easier program discovery:

Tags help organize and find programs:

Schedule periodic cleanup to manage storage:

For optimizations that take hours or days:

**Examples:**

Example 1 (elixir):
```elixir
program = DSPy::Predict.new(ClassifyText)
metric = proc { |example, prediction| prediction.sentiment == example.expected_sentiment }
optimizer = DSPy::Teleprompt::MIPROv2.new(metric: metric)
result = optimizer.compile(program, trainset: examples)

storage = DSPy::Storage::ProgramStorage.new(storage_path: "./dspy_storage")
saved_program = storage.save_program(
  result.optimized_program,
  result,
  metadata: {
    signature_class: 'ClassifyText',
    optimizer: 'MIPROv2',
    examples_count: examples.size
  }
)

puts "Stored program with ID: #{saved_program.program_id}"
```

Example 2 (elixir):
```elixir
program = DSPy::Predict.new(ClassifyText)
metric = proc { |example, prediction| prediction.sentiment == example.expected_sentiment }
optimizer = DSPy::Teleprompt::MIPROv2.new(metric: metric)
result = optimizer.compile(program, trainset: examples)

storage = DSPy::Storage::ProgramStorage.new(storage_path: "./dspy_storage")
saved_program = storage.save_program(
  result.optimized_program,
  result,
  metadata: {
    signature_class: 'ClassifyText',
    optimizer: 'MIPROv2',
    examples_count: examples.size
  }
)

puts "Stored program with ID: #{saved_program.program_id}"
```

Example 3 (yaml):
```yaml
storage_manager = DSPy::Storage::StorageManager.new

# Save optimization result automatically
saved_program = storage_manager.save_optimization_result(
  result,
  tags: ['production', 'sentiment-analysis'],
  description: 'Optimized sentiment classifier v2'
)

# Or use the global instance
DSPy::Storage::StorageManager.save(result, metadata: { version: '2.0' })
```

Example 4 (yaml):
```yaml
storage_manager = DSPy::Storage::StorageManager.new

# Save optimization result automatically
saved_program = storage_manager.save_optimization_result(
  result,
  tags: ['production', 'sentiment-analysis'],
  description: 'Optimized sentiment classifier v2'
)

# Or use the global instance
DSPy::Storage::StorageManager.save(result, metadata: { version: '2.0' })
```

---

## Registry | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/registry/

**Contents:**
- Registry & Versions
- Define What the Registry Records
- Register a Version
  - Create the Registry
  - Registering Versions
  - Registering an Optimization Result with RegistryManager
- Version Management
  - Listing Versions
  - Updating Performance Scores
  - Comparing Versions

The registry records versioned signature configurations and which version an environment has deployed. It can register optimization results, compare recorded scores, promote a version, and roll back the deployment pointer.

The registry records:

This example calls the manager explicitly. For optimizer-triggered registration, configure DSPy::Registry::RegistryManager.instance and set the optimizer’s save_intermediate_results option. Optimizers use that singleton after a compile; a separately constructed manager does not receive those calls.

The registry uses file-based storage with YAML files:

The registry emits structured log events for monitoring:

By default, the registry uses timestamp-based versions:

You can also provide custom version names:

Record enough metadata to reproduce the selection decision:

Always update performance scores after evaluation:

Set a measured promotion threshold and keep rollback policy in the application deployment process:

**Examples:**

Example 1 (unknown):
```unknown
RegistryManager
```

Example 2 (julia):
```julia
registry = DSPy::Registry::SignatureRegistry.new

config = DSPy::Registry::SignatureRegistry::RegistryConfig.new
config.registry_path = "./my_dspy_registry"
config.auto_version = true
config.max_versions_per_signature = 10

registry = DSPy::Registry::SignatureRegistry.new(config: config)
```

Example 3 (julia):
```julia
registry = DSPy::Registry::SignatureRegistry.new

config = DSPy::Registry::SignatureRegistry::RegistryConfig.new
config.registry_path = "./my_dspy_registry"
config.auto_version = true
config.max_versions_per_signature = 10

registry = DSPy::Registry::SignatureRegistry.new(config: config)
```

Example 4 (elixir):
```elixir
program = DSPy::Predict.new(ClassifyText)
metric = proc { |example, prediction| prediction.sentiment == example.expected_sentiment }
optimizer = DSPy::Teleprompt::MIPROv2.new(metric: metric)
result = optimizer.compile(program, trainset: training_examples)

configuration = {
  instruction: result.optimized_program.prompt.instruction,
  few_shot_examples_count: result.optimized_program.few_shot_examples.size
}

version = registry.register_version(
  'text_classifier',
  configuration,
  metadata: {
    optimizer: 'MIPROv2',
    training_examples: training_examples.size,
    accuracy: result.best_score_value
  },
  program_id: 'abc123'  # From storage system if saved
)

puts "Registered version: #{version.version}"
```

---

## Observability | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/observability/

**Contents:**
- Observability
- Choose an Observability Boundary
- Installation
- Architecture
  - Dedicated Export Worker
- Quick Start
  - Basic Event Emission
  - Event Listeners
  - Custom Subscribers
- Observation Types

DSPy.rb emits structured events and OpenTelemetry spans for modules, LM calls, tools, evaluation, and optimization. Subscribe to events for application metrics; install the optional Langfuse integration when you need span export there.

The observability system offers:

Add the observability gems alongside dspy:

Check the package and capability matrix for current overlap, loading, and support-status details before selecting observability gems.

When hacking inside this monorepo, run DSPY_WITH_O11Y=1 DSPY_WITH_O11Y_LANGFUSE=1 bundle install to pull in the sibling gems.

The event system is built around three core components:

Routine telemetry export runs on a Concurrent::SingleThreadExecutor instead of the thread that finishes the span. A bounded queue buffers completed spans, and the dedicated worker:

The worker still consumes process resources. A full queue drops its oldest span, exporter failures can exhaust their retries, and shutdown can time out before every span is sent. The asynchronous boundary removes routine OTLP export from the request thread; it does not guarantee delivery or make LLM calls non-blocking.

DSPy.rb maps instrumented operations to Langfuse observation types so consumers can distinguish generations, agents, tools, chains, retrievers, and embeddings:

Generation (generation):

Retriever (retriever):

DSPy.rb does not provide a document store. The wrapper instruments the retrieval client your application already owns.

Embedding (embedding):

The same pattern works with any embedding client. Keep provider credentials and vector persistence in application code.

For custom modules, specify observation types manually:

Instrumented DSPy module calls emit events with OpenTelemetry semantic attributes:

Create structured events with validation:

DSPy.log() writes to the configured logger. It does not notify event subscribers or create telemetry spans. Use DSPy.event() when listeners or an OpenTelemetry exporter must receive the operation:

Existing DSPy.log() call sites continue to log without change. Moving a call site to DSPy.event() is an application decision because subscribers may add processing and side effects. Span export also requires the observability packages and exporter configuration.

Create and retain each custom subscriber explicitly, then unsubscribe it during shutdown. Langfuse export requires the packages, credentials, network access, and exporter lifecycle described below.

Use Semantic Names: Follow dot notation (llm.generate, module.forward)

Check subscription patterns:

Always unsubscribe when done:

Event system is thread-safe by design:

With dspy-o11y, dspy-o11y-langfuse, the OpenTelemetry dependencies, and network access installed, setting the required Langfuse environment variables configures OTLP span export alongside logging.

The integration requires opentelemetry-sdk, opentelemetry-exporter-otlp, valid Langfuse credentials, and network connectivity to the configured instance.

Since v0.25.0, spans capture inputs, outputs, nesting, timing, token usage, and Langfuse observation types (generation, chain, and span).

You can disable or tune async telemetry behavior with environment variables:

When the required Langfuse environment variables are present, initialization:

Environment-driven configuration runs only when the required gems and variables are present. Verify received spans and shutdown behavior in a non-production environment before depending on the exporter.

With Langfuse configured, your DSPy applications will send traces like this:

In your logs (as usual):

In Langfuse (when export is configured):

Trace Examples by Observation Type

Based on actual DSPy.rb implementation, here’s what traces look like for different observation types:

Generation Type (Direct LLM calls):

Chain Type (ChainOfThought reasoning):

Agent Type (ReAct multi-step reasoning):

Instrumented LM operations include OpenTelemetry GenAI semantic attributes:

For custom OpenTelemetry setups, you can disable auto-configuration and set up manually:

dspy-o11y-langfuse declares these export dependencies:

Without these gems, Langfuse span export is unavailable; DSPy logging remains separate.

Missing Langfuse spans:

OpenTelemetry errors:

Authentication issues:

Traces show what executed; they do not establish correctness. See Score Reporting for the canonical DSPy::Scores types, evaluators, evaluation export, and bounded Langfuse exporter lifecycle.

See examples/event_system_demo.rb for event subscriptions and emitted attributes. Keep sensitive input and output data out of exported spans unless your retention and access policy permits it.

**Examples:**

Example 1 (unknown):
```unknown
DSPy.event()
```

Example 2 (unknown):
```unknown
dspy-o11y-langfuse
```

Example 3 (unknown):
```unknown
gem 'dspy'
gem 'dspy-o11y'           # core spans + helpers
gem 'dspy-o11y-langfuse'  # Langfuse/OpenTelemetry adapter (optional)
```

Example 4 (unknown):
```unknown
gem 'dspy'
gem 'dspy-o11y'           # core spans + helpers
gem 'dspy-o11y-langfuse'  # Langfuse/OpenTelemetry adapter (optional)
```

---

## Troubleshooting | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/production/troubleshooting/

**Contents:**
- Troubleshooting
- Language Model Configuration
  - Error: DSPy::ConfigurationError
- Gem Conflicts
  - Warning: ruby-openai gem detected
  - Namespace Conflicts
  - Error: temperature is deprecated for this model (Anthropic)
  - Error: DSPy::LM::ConfigurationError for DSPy::Reasoning
- API Key Issues
  - Error: DSPyLMMissingAPIKeyError

Cause: The module cannot resolve a configured language model.

Correction: Configure an LM globally or on the module instance as shown in the error. Prefer current model identifiers from the provider documentation.

Cause: DSPy uses the official OpenAI SDK. The community ruby-openai gem defines the same OpenAI namespace.

Correction: Remove ruby-openai from the process that loads DSPy:

If the application needs both SDKs, isolate them in separate processes. Bundler groups help only when the conflicting gems are not loaded together.

Problem: Both gems use the OpenAI namespace, causing method conflicts and unexpected behavior.

Problem: Newer Claude models (Sonnet 5, Opus 4.7/4.8, Fable 5, Mythos 5, and others) reject a non-default temperature:

Solution: Upgrade to a version of dspy-anthropic that includes the #256 fix. The adapter now automatically omits temperature for affected models, even if you never pass it yourself. If you’re still on an older version, or you want to be explicit, pass temperature: nil:

See Reasoning Effort & Temperature for the full temperature:/max_tokens:/reasoning: configuration surface.

Problem: You passed a DSPy::Reasoning mode (e.g. .xhigh, .budget(n)) that the target Anthropic model doesn’t support:

Solution: This is a deliberate, eager validation — it’s cheaper to fail at DSPy::LM.new construction time than after a request round-trip. Check Reasoning Effort & Temperature for which effort tiers and thinking modes each model family supports, and adjust your DSPy::Reasoning call or target model accordingly.

Cause: The adapter cannot find an API key in its argument or provider environment variable.

Solution: Set the API key via environment variable or parameter:

Cause: The provider returned content that the configured JSON strategy could not parse or validate.

Correction: Use provider-native structured output when the selected model supports it. Otherwise inspect the raw response and simplify the signature or field descriptions.

Provider capabilities vary by model and SDK version. A provider prefix alone does not establish native schema support. For Anthropic, structured_outputs: true (default) uses native output_config.format; requires anthropic gem >= 1.28.0.

DSPy.rb does not provide a memory store. Keep conversation history, user preferences, and checkpoints in application-owned storage, then pass the relevant state into a signature as typed input.

If retained state grows without bound, inspect the application’s database, cache, or session store. Define retention and compaction rules there rather than relying on an in-process DSPy object.

Verification: Inspect provider latency and DSPy spans before changing execution strategy.

Cause: The recorded request no longer matches the adapter’s current request shape.

Solution: Re-record cassettes when API changes:

In development, DSPy.rb writes logs to log/development.log under the default configuration. Tail that file:

To enable debug level logging with output to stdout:

Or redirect logs to stdout using the environment variable:

If you encounter issues not covered here:

**Examples:**

Example 1 (julia):
```julia
DSPy::ConfigurationError: No language model configured for MyModule module.

To fix this, configure a language model either globally:

  DSPy.configure do |config|
    config.lm = DSPy::LM.new("openai/gpt-4", api_key: ENV["OPENAI_API_KEY"])
  end

Or on the module instance:

  module_instance.configure do |config|
    config.lm = DSPy::LM.new("anthropic/claude-3", api_key: ENV["ANTHROPIC_API_KEY"])
  end
```

Example 2 (julia):
```julia
DSPy::ConfigurationError: No language model configured for MyModule module.

To fix this, configure a language model either globally:

  DSPy.configure do |config|
    config.lm = DSPy::LM.new("openai/gpt-4", api_key: ENV["OPENAI_API_KEY"])
  end

Or on the module instance:

  module_instance.configure do |config|
    config.lm = DSPy::LM.new("anthropic/claude-3", api_key: ENV["ANTHROPIC_API_KEY"])
  end
```

Example 3 (unknown):
```unknown
ruby-openai
```

Example 4 (csharp):
```csharp
WARNING: ruby-openai gem detected. This may cause conflicts with DSPy's OpenAI integration.

DSPy uses the official 'openai' gem. The community 'ruby-openai' gem uses the same
OpenAI namespace and will cause conflicts.
```

---
