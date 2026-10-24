# Dspy-Ruby_Docs - Getting Started

**Pages:** 4

---

## DSPy.rb Tutorial: Getting Started | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/getting-started/

**Contents:**
- Getting Started with DSPy.rb
- Run Your First Program
- Choose a Provider or Package
- Continue After the Quick Start

DSPy.rb lets Ruby applications declare typed inputs and outputs for language-model calls. Choose one route based on what you need now.

Follow the Quick Start to install the gems, configure OpenAI, save the example, and run it.

Use Installation to select and configure a provider adapter. Use the package and capability matrix when you need exact package status, require behavior, or capability boundaries.

Read Core Concepts to choose signatures, predictors, modules, examples, and tools. Move to evaluation, optimization, and production guides when your application reaches those tasks.

---

## Installation | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/getting-started/installation/

**Contents:**
- Installation & Provider Setup
- Requirements
- Install Core and an Adapter
- Choose a Provider Adapter
- Configure Credentials
- Configure a Provider
  - OpenAI
  - Anthropic
  - Gemini
  - OpenRouter

Choose and configure a provider here. To build and run a first program with OpenAI, follow the Quick Start.

DSPy.rb requires Ruby 3.3 or newer and Bundler.

Every application needs the core gem plus a provider adapter. For OpenAI, OpenRouter, or Ollama:

Installing only dspy does not install an OpenAI SDK or adapter. If code configures an openai/*, openrouter/*, or ollama/* model without dspy-openai, DSPy::LM raises DSPy::LM::MissingAdapterError.

The package and capability matrix lists every package’s status, exact require path, dependencies, and limitations. Provider and model capabilities still vary after a package is installed.

DSPy::LM auto-requires the installed adapter from the model prefix. The prefix selects an adapter; it does not prove that a particular model supports schemas, tools, media, documents, or streaming. Check the package matrix and provider documentation for the selected model and SDK version.

Set provider credentials in the process environment, for example:

DSPy.rb reads only the value your application passes to api_key:. It does not load .env files. Load a .env file explicitly with an application dependency such as dotenv, or export variables in the shell or deployment environment.

Prefer ENV.fetch when a key is required:

With this form, a missing variable raises Ruby’s KeyError before LM initialization. If an application passes nil, an empty string, or whitespace with ENV['OPENAI_API_KEY'], the OpenAI adapter raises DSPy::LM::MissingAPIKeyError.

Use an openai/* model identifier and pass OPENAI_API_KEY. Native structured-output support depends on the selected model; enable it only when the model and SDK support it:

OpenRouter capabilities vary by the routed model. Optional http_referrer: and x_title: values add attribution headers; they do not change model support.

Install Ollama, pull a model, and use the OpenAI-compatible adapter:

The default local endpoint does not need an API key. A remote or protected endpoint may require base_url: and api_key:. Model support for JSON schemas, media, and tools varies.

When RubyLLM is already configured and DSPy receives no api_key, base_url, timeout, or max_retries override, the adapter reuses the global RubyLLM configuration:

Passing one of those values creates or uses adapter-scoped configuration instead. Registry data, provider overrides, authentication, and features vary by provider, model, RubyLLM version, and provider SDK.

See Troubleshooting for runtime failures after setup.

**Examples:**

Example 1 (markdown):
```markdown
# Gemfile
gem 'dspy'
gem 'dspy-openai'
```

Example 2 (markdown):
```markdown
# Gemfile
gem 'dspy'
gem 'dspy-openai'
```

Example 3 (unknown):
```unknown
bundle install
```

Example 4 (unknown):
```unknown
bundle install
```

---

## Quick Start | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/getting-started/quick-start/

**Contents:**
- Quick Start
- Your First DSPy Program
  - 1. Create the Gemfile
  - 2. Set the API key
  - 3. Save the program
  - 4. Run it
- What the Boundary Guarantees
- Failure and Testing Boundaries
- Key Concepts
  - Modules and Agents

This path uses OpenAI for one small sentiment classifier; model output can vary.

Create a directory for the program and save this as Gemfile:

dspy provides signatures and modules. dspy-openai provides the adapter used by the openai/* model identifier below. The package and capability matrix lists other packages and their boundaries.

Export an OpenAI API key in the same shell:

DSPy.rb does not load .env files. If your application uses one, load it with your own environment library before reading the key.

Save this exact program as classify.rb:

The program prints a sentiment value followed by a confidence value. Do not depend on a particular label, confidence, or wording: those depend on the model and request. When prediction succeeds, result.sentiment is a Classify::Sentiment and result.confidence is a Float.

The signature supplies the task description plus the input and output schemas. DSPy::Predict builds the provider request, converts the response to the declared Ruby types, and rejects incompatible output.

Typed output validation constrains the result shape; it does not prove that the answer is correct. Use named examples and a metric to gather evidence about model behavior; see Examples and Datasets and Evaluation.

Because the program uses ENV.fetch('OPENAI_API_KEY'), running it without that variable raises Ruby’s KeyError before DSPy::LM is created. An installed core gem without dspy-openai instead raises DSPy::LM::MissingAdapterError when an openai/* model is configured. Provider authentication, transport, rate-limit, and response-validation failures remain separate application errors; Troubleshooting lists their owning layers.

Represent expected domain uncertainty in the signature, for example with an enum value such as Unknown. Handle configuration and provider failures around the call rather than turning them into a model-generated result.

For deterministic tests, assert the signature schema, result classes, enum membership, and failure boundaries. Record provider calls with VCR or evaluate behavior against examples and a named metric. Avoid tests that require one exact label, confidence, or explanation from a live model.

DSPy::Predict performs one typed prediction. DSPy::ChainOfThought adds a reasoning field, while DSPy::ReAct runs a bounded loop in which the model can select tools. Keep known sequencing and branches in Ruby; use an agent only when a bounded model choice is useful.

Tools expose Ruby methods through Sorbet signatures:

The application owns the tool implementation, side effects, permissions, error handling, and iteration limits. ReAct only owns the bounded loop in which the model selects a tool or returns a result.

**Examples:**

Example 1 (unknown):
```unknown
source 'https://rubygems.org'

gem 'dspy'
gem 'dspy-openai'
```

Example 2 (unknown):
```unknown
source 'https://rubygems.org'

gem 'dspy'
gem 'dspy-openai'
```

Example 3 (unknown):
```unknown
dspy-openai
```

Example 4 (unknown):
```unknown
bundle install
```

---

## Packages and capabilities | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/getting-started/packages/

**Contents:**
- Packages and capabilities
- Status labels
- Package matrix
  - dspy
  - dspy-openai
  - dspy-anthropic
  - dspy-gemini
  - dspy-ruby_llm
  - dspy-code_act
  - dspy-datasets

Start with dspy, then add the package that owns the provider or optional feature you use. A gem’s presence means its Ruby entry point is available. It does not mean every model or provider endpoint implements every capability.

The matrix is generated from package_capabilities.yml, the canonical package inventory.

supported — A public entry point with a current gemspec, repository tests, and a maintained guide or canonical package entry.

preview — A public pre-1.0 entry point covered by repository tests; its API may change before 1.0.

supporting — A maintained package installed mainly as a dependency of another public DSPy.rb package.

These labels describe this repository’s documentation and test posture. They do not extend the compatibility promises made by provider APIs or third-party SDKs.

Monorepo development only: DSPY_WITH_OPENAI=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_ANTHROPIC=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_GEMINI=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_RUBY_LLM=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_CODE_ACT=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_DATASETS=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_EVALS=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_MIPROV2=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_GEPA=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_GEPA=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_O11Y=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_O11Y_LANGFUSE=1 selects this repository’s local gemspec. Application users install the gem instead.

Monorepo development only: DSPY_WITH_SCHEMA=1 selects this repository’s local gemspec. Application users install the gem instead.

These are packaging facts, not separate implementations. The validator compares every tracked gemspec pair and fails if this list drifts.

dspy + dspy-evals: The core gem currently ships the evaluation runtime files also packaged by dspy-evals; installing dspy-evals does not isolate a different implementation. Overlapping files: lib/dspy/evals.rb, lib/dspy/evals/version.rb.

dspy + dspy-ruby_llm: The core gem currently contains RubyLLM adapter files, while dspy-ruby_llm supplies the required RubyLLM dependency and the same entry point. Overlapping files: lib/dspy/ruby_llm.rb, lib/dspy/ruby_llm/lm/adapters/ruby_llm_adapter.rb, lib/dspy/ruby_llm/version.rb.

dspy + dspy-schema: The core gem currently ships the schema files also packaged by dspy-schema; direct dspy-schema installation avoids the rest of core, but adding it beside dspy does not create a separate implementation. Overlapping files: lib/dspy/schema.rb, lib/dspy/schema/sorbet_json_schema.rb, lib/dspy/schema/sorbet_toon_adapter.rb, lib/dspy/schema/version.rb.

dspy-deep_research + dspy-deep_search: dspy-deep_research currently packages DeepSearch implementation files and also depends on the exactly matched dspy-deep_search gem. Overlapping files: lib/dspy/deep_search/clients/exa_client.rb, lib/dspy/deep_search/gap_queue.rb, lib/dspy/deep_search/module.rb, lib/dspy/deep_search/signatures.rb, lib/dspy/deep_search/token_budget.rb, lib/dspy/deep_search/version.rb.

dspy-o11y + dspy-o11y-langfuse: dspy-o11y currently packages the Langfuse files also shipped by dspy-o11y-langfuse; the latter declares exporter dependencies and is the direct Langfuse installation entry. Overlapping files: lib/dspy/o11y/langfuse.rb, lib/dspy/o11y/langfuse/scores_exporter.rb, lib/dspy/o11y/langfuse/version.rb.

RubyLLM is deliberately one row, not a promise that all of its underlying providers behave alike. Its registry and SDK determine model discovery; DSPy.rb still applies narrower boundaries where the adapter has them. For example, document inputs through RubyLLM currently require an Anthropic model.

Do not install dspy-deepsearch. Use dspy-deep_search.

Do not install dspy-deepresearch. Use dspy-deep_research.

dspy-code_act executes model-generated Ruby with the process’s authority. Installing it does not add a sandbox, resource isolation, a permission system, or safe handling for untrusted input. Put execution behind an isolation boundary appropriate to the data and side effects involved; the application owns that boundary.

DSPY_WITH_* flags only select local gemspecs while developing or testing this monorepo. Application users install the named gems in their Gemfile and do not set these flags. Packages without a flag are not selected by a DSPY_WITH_* switch.

**Examples:**

Example 1 (unknown):
```unknown
package_capabilities.yml
```

Example 2 (unknown):
```unknown
dspy-openai
```

Example 3 (unknown):
```unknown
dspy/openai
```

Example 4 (unknown):
```unknown
dspy-anthropic
```

---
