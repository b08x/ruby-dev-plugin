# Dspy-Ruby_Docs - Modules

**Pages:** 3

---

## DSPy Modules: Composable LLM Components in Ruby | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/core-concepts/modules/

**Contents:**
- Modules
- Choose a Module Boundary
- Subclass DSPy::Module
  - Define forward
  - Inject Module Configuration
- Override the Language Model at Runtime
- Manual Module Composition
  - Sequential Processing
  - Conditional Processing
- Compose Predictor Types

DSPy::Module is the reusable execution boundary in DSPy.rb. Predict, ChainOfThought, and ReAct are modules; applications can subclass DSPy::Module to compose them with Ruby.

See Module Runtime Context for fiber-local language model overrides and lifecycle callbacks.

This ReAct module exposes only the portable count and line-range operations. It caps application input and bounds model-directed steps:

These examples deliberately exclude text_grep, text_rg, and text_filter_lines: those helpers accept command or regular-expression patterns and do not provide process deadlines or input/output caps. Tool arguments remain untrusted even when the module input was validated, so use an application-owned wrapper when provider output limits do not satisfy the same byte budget. max_iterations limits agent steps; it does not cancel a running tool.

The core feature is DSPy::Tools::GitHubCLIToolset, loaded with require "dspy/tools/github_cli_toolset". Do not pass its entire authenticated proxy set to a triage agent: that would expose broader repository and arbitrary GET API access than issue listing requires. Wrap only the required read operation with an application-owned repository allowlist, credential scope, command timeout, output cap, and failure redaction before giving it to ReAct.

See Toolsets to define and export tools.

CodeAct is available via the dspy-code_act gem. The complete Think-Code-Observe module example now lives in lib/dspy/code_act/README.md, alongside guidance on safety, observability, and advanced usage.

Subclass DSPy::Module when the built-in modules do not define the required execution pattern, as DSPy::ReAct (core) and DSPy::CodeAct (optional gem) do. A custom module can compose predictors, agents, application services, and Ruby control flow behind one typed call boundary.

Optimizers such as GEPA and MIPROv2 expect predictors to expose immutable update hooks so they can safely swap instructions and few-shot examples. When you build a custom module that participates in optimization:

You can include DSPy::Mixins::InstructionUpdatable to signal this capability and surface helpful default errors during development:

If a module omits these hooks, optimizers raise DSPy::InstructionUpdateError instead of mutating instance variables directly.

Modules can work with the optimization framework through their underlying predictors:

**Examples:**

Example 1 (yaml):
```yaml
DSPy::Module
```

Example 2 (unknown):
```unknown
ChainOfThought
```

Example 3 (yaml):
```yaml
DSPy::Module
```

Example 4 (julia):
```julia
class SentimentSignature < DSPy::Signature
  description "Analyze sentiment of text"
  
  input do
    const :text, String
  end
  
  output do
    const :sentiment, String
    const :confidence, Float
  end
end

class SentimentAnalyzer < DSPy::Module
  def initialize
    super
    
    # Create the predictor
    @predictor = DSPy::Predict.new(SentimentSignature)
  end

  def forward(text:)
    @predictor.call(text: text)
  end
end

# Usage
analyzer = SentimentAnalyzer.new
result = analyzer.call(text: "I love this product!")

puts result.sentiment    # => "positive"
puts result.confidence   # => 0.9
```

---

## Module Runtime Context | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/module-runtime-context/

**Contents:**
- Module Runtime Context
- Fiber-Local LM Context
  - Basic Usage
  - LM Resolution Hierarchy
  - Using with Different Model Types
- Configuring Agent LMs
  - Basic Configuration
  - Fine-Grained Control
  - Available Predictors by Agent Type
  - Propagation Behavior

Module runtime context controls language-model resolution and propagation for a module call.

DSPy.with_lm temporarily overrides the language model in fiber-local storage. Use it in optimization, model comparisons, or a Ruby program whose modules require different models.

DSPy resolves language models in this order:

Complex agents such as ReAct and CodeAct contain internal predictors. Calling configure(lm:) on the parent propagates that LM to child predictors that do not already have an explicit LM.

Use configure_predictor to assign different LMs to specific internal predictors:

Both methods support chaining:

Callbacks are a separate module-authoring task. See Module Lifecycle Callbacks for the canonical before, around, and after definitions, order, inheritance, and failure boundary.

**Examples:**

Example 1 (unknown):
```unknown
DSPy.with_lm
```

Example 2 (julia):
```julia
DSPy.configure do |config|
  config.lm = DSPy::LM.new("openai/gpt-4o", api_key: ENV['OPENAI_API_KEY'])
end

class Classifier < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(ClassificationSignature)
  end

  def forward(text:)
    @predictor.call(text: text)
  end
end

classifier = Classifier.new

result1 = classifier.call(text: "This is great!")

fast_model = DSPy::LM.new("openai/gpt-4o-mini", api_key: ENV['OPENAI_API_KEY'])

DSPy.with_lm(fast_model) do
  # Inside this block, all modules use the fast model
  result2 = classifier.call(text: "This is great!")
end

# Back to using the global LM (gpt-4o)
result3 = classifier.call(text: "This is great!")
```

Example 3 (julia):
```julia
DSPy.configure do |config|
  config.lm = DSPy::LM.new("openai/gpt-4o", api_key: ENV['OPENAI_API_KEY'])
end

class Classifier < DSPy::Module
  def initialize
    super
    @predictor = DSPy::Predict.new(ClassificationSignature)
  end

  def forward(text:)
    @predictor.call(text: text)
  end
end

classifier = Classifier.new

result1 = classifier.call(text: "This is great!")

fast_model = DSPy::LM.new("openai/gpt-4o-mini", api_key: ENV['OPENAI_API_KEY'])

DSPy.with_lm(fast_model) do
  # Inside this block, all modules use the fast model
  result2 = classifier.call(text: "This is great!")
end

# Back to using the global LM (gpt-4o)
result3 = classifier.call(text: "This is great!")
```

Example 4 (unknown):
```unknown
DSPy.with_lm
```

---

## Module Lifecycle Callbacks | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/advanced/module-lifecycle-callbacks/

**Contents:**
- Module Lifecycle Callbacks
- Prerequisites
- Define the Callback Lifecycle
- Wrap a Module Call
- Choose the Supported Integration
- Continue by task

Add one cross-cutting lifecycle around a module’s forward call without changing the task signature.

Implement a module with forward as shown in Modules. Runtime model selection belongs to Module Runtime Context, not to callbacks.

Callbacks of the same type run in registration order. Inherited parent callbacks precede child callbacks. A combined call runs before, the pre-yield half of around, forward, the post-yield half of around, then after.

This example is complete and network-free: callbacks wrap a deterministic forward method, making their order and failure behavior directly observable.

A successful call prints the normalized question and before -> around_before -> forward -> around_after -> after. A blank question records around_error, re-raises ArgumentError, and does not run after. An around callback that omits yield prevents forward from running. Keep mutable callback state per call when a module instance may be shared concurrently.

**Examples:**

Example 1 (perl):
```perl
require 'dspy'

class NormalizedQuestion < DSPy::Module
  attr_reader :events

  before :record_start
  around :record_call
  after :record_finish

  def initialize
    super
    @events = []
  end

  def forward(question:)
    @events << :forward
    raise ArgumentError, "question cannot be blank" if question.strip.empty?

    question.strip
  end

  private

  def record_start
    @events << :before
  end

  def record_call
    @events << :around_before
    result = yield
    @events << :around_after
    result
  rescue StandardError
    @events << :around_error
    raise
  end

  def record_finish
    @events << :after
  end
end

normalizer = NormalizedQuestion.new
result = normalizer.call(question: "  What is a typed module?  ")
puts result
puts normalizer.events.join(" -> ")
```

Example 2 (perl):
```perl
require 'dspy'

class NormalizedQuestion < DSPy::Module
  attr_reader :events

  before :record_start
  around :record_call
  after :record_finish

  def initialize
    super
    @events = []
  end

  def forward(question:)
    @events << :forward
    raise ArgumentError, "question cannot be blank" if question.strip.empty?

    question.strip
  end

  private

  def record_start
    @events << :before
  end

  def record_call
    @events << :around_before
    result = yield
    @events << :around_after
    result
  rescue StandardError
    @events << :around_error
    raise
  end

  def record_finish
    @events << :after
  end
end

normalizer = NormalizedQuestion.new
result = normalizer.call(question: "  What is a typed module?  ")
puts result
puts normalizer.events.join(" -> ")
```

Example 3 (perl):
```perl
before -> around_before -> forward -> around_after -> after
```

Example 4 (unknown):
```unknown
around_error
```

---
