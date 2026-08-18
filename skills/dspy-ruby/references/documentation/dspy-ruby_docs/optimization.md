# Dspy-Ruby_Docs - Optimization

**Pages:** 4

---

## Optimization | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/

**Contents:**
- Optimization
- Choose an Evaluation or Optimization Task
  - Evaluation
  - Score Reporting
  - Benchmarking Raw Prompts
  - Choose an Optimizer
  - GEPA
  - MIPROv2
- Establish Evidence Before Optimizing
- Continue by task

Optimizers search over supported program parameters, including instructions and few-shot examples. You supply examples, a metric, and a budget; the optimizer returns the best candidate it found.

Optimization does not define quality for you. Build and inspect the metric first, preserve a held-out test set, and record the model and dataset used for each run.

Build metrics and evaluation frameworks to measure and improve your modules systematically.

Attach typed metric results to executions and, when configured, export them to Langfuse.

Compare an existing prompt with a DSPy module under the same models, examples, and measurements.

Revise instructions and examples immutably, measure a baseline, and choose an optimizer from the measured failure and feedback shape.

Use reflective feedback to evolve supported program parameters after establishing an evaluation baseline.

Use Bayesian search to select instructions and demonstrations for single- or multi-predictor programs.

---

## Program Optimization in Ruby MIPROv2 & GEPA | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/prompt-optimization/

**Contents:**
- Program Optimization
- Inspect a Program
- Revise Instructions and Examples
- Measure a Baseline
- Compile with MIPROv2
- Compile with GEPA
- Store the Result
- Operational Limits
- Continue by task

DSPy.rb applications define tasks with signatures and execute them with modules. Instructions and few-shot examples remain part of the program, but you do not need to maintain provider-specific prompt templates. Adapters render the signature, examples, and output constraints for each provider.

Optimization starts with a dataset and a metric. The optimizer proposes program variants, evaluates them, and returns the best candidate it found within the configured budget. A higher validation score is evidence about that dataset and metric, not a general guarantee.

DSPy::Predict exposes its immutable DSPy::Prompt:

The prompt stores the instruction and examples. The signature remains the source of the input and output contract.

Use module methods to create a revised program. The original remains unchanged.

with_instruction and with_examples return new module instances. There is no prompt= writer on DSPy::Predict.

Evaluate the same examples and metric before and after a change:

Keep a separate test set for the final comparison. Reusing the validation set for the final claim rewards candidates that happened to fit that set.

MIPROv2 lives in the optional dspy-miprov2 gem:

Compile the program against training and validation examples:

MIPROv2 searches over instructions and demonstrations. Its API returns an OptimizationResult; deploy or serialize result.optimized_program, not the optimizer itself.

See MIPROv2 for budgets, presets, and multi-predictor programs.

GEPA uses scalar scores and textual feedback to propose instruction changes. It lives in the optional dspy-gepa gem.

Use GEPA when your metric can explain a failure, not merely mark it wrong. The reflection model receives that feedback and uses it to propose the next candidate.

See GEPA for its metric contract, reflection model, and evaluation budget.

ProgramStorage saves the optimized program together with the optimization result and metadata:

Record the dataset version, metric version, model, optimizer configuration, and validation score beside the artifact. Those details explain what the optimized program was selected to do.

Reloading reconstructs the program class named in the artifact. That class and its signature class must already be loaded, and the program class must implement .from_h. Evaluate loaded_program before promotion; persistence does not establish compatibility with a changed model, dependency, or application.

**Examples:**

Example 1 (yaml):
```yaml
DSPy::Predict
```

Example 2 (yaml):
```yaml
DSPy::Prompt
```

Example 3 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify the sentiment of the given text"

  input do
    const :text, String
  end

  output do
    const :sentiment, String
    const :confidence, Float
  end
end

predictor = DSPy::Predict.new(ClassifyText)
prompt = predictor.prompt

puts prompt.instruction
puts prompt.few_shot_examples.size
```

Example 4 (php):
```php
class ClassifyText < DSPy::Signature
  description "Classify the sentiment of the given text"

  input do
    const :text, String
  end

  output do
    const :sentiment, String
    const :confidence, Float
  end
end

predictor = DSPy::Predict.new(ClassifyText)
prompt = predictor.prompt

puts prompt.instruction
puts prompt.few_shot_examples.size
```

---

## GEPA Optimizer for Ruby — Reflective Prompt Evolution | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/gepa/

**Contents:**
- GEPA Optimizer
- Installation
- Understand the GEPA Loop
- Quickstart (ADE demo)
- Step-by-step Integration
  - 1. Define the signature and baseline program
  - 2. Build datasets and evaluation helpers
  - 3. Design a metric that returns DSPy::Prediction
  - 4. (Optional) Add predictor-level feedback hooks
  - 5. Configure the Optimizer

See the package and capability matrix for the distinction between the public dspy-gepa integration and its lower-level gepa dependency.

GEPA stands for Genetic-Pareto Reflective Prompt Evolution. In practice, it is a feedback loop: run your DSPy module on a small batch, collect both scores and short text notes about what happened, and let a reflection model rewrite the instruction. If the rewrite helps on the validation set without regressing elsewhere, GEPA keeps it as a new candidate on the Pareto frontier.

The walkthrough uses examples/ade_optimizer_gepa/ as a concrete implementation. Replace its signature, dataset, and metric while retaining the budget and held-out evaluation structure.

Add the optional gem so Bundler pulls in the DSPy.rb optimizer integration and its GEPA core dependency:

If you’re working inside the DSPy.rb monorepo, set DSPY_WITH_GEPA=1 bundle install so the local gemspecs are included. The dspy-gepa gem depends on the gepa core optimizer gem automatically.

GEPA runs in iterative loops:

DSPy.rb’s GEPA implementation includes telemetry, merge proposers, and experiment tracking. Supply a DSPy module and a metric that returns DSPy::Prediction; add a feedback_map when individual predictors need separate feedback.

The ADE demo optimizes a clinical text classifier with GEPA. Run it end-to-end:

Reuse this dataset, metric, budget, and held-out-test structure with the application task.

Start from a vanilla DSPy::Predict so you have an instruction to evolve and a prompt container for few-shot examples.

The demo converts ADE rows into strongly typed DSPy::Example instances and provides an evaluate helper:

Any GEPA run should keep a held-out test set so you can confirm improvements outside the optimization loop.

GEPA expects richer feedback than a plain boolean. Borrow the ADE pattern:

The helper ADEExampleGEPA.snippet trims long sentences so the feedback stays readable. Keep the score in [0, 1] and always return a short message that explains what happened—GEPA saves both fields and hands the text to the reflection model so it understands the failure.

feedback_map lets you target individual predictors inside a composite module. The ADE demo runs GEPA over a simple predictor, so the map keys just use 'self':

Leave feedback_map empty if your metric already covers the basics. For multi-predictor chains, add entries per component so the reflection LM sees localized context at each step.

The returned result exposes:

The ADE example writes two artifacts to examples/ade_optimizer_gepa/results/:

You can adopt the same pattern or plug GEPA::Logging::ExperimentTracker into your own persistence layer:

Add the tracker to DSPy::Teleprompt::GEPA.new via experiment_tracker: tracker.

The GEPA paper by Agrawal et al. (2025)1 highlights patterns that make reflective prompt evolution efficient:

The ADE demo script already follows most of these recommendations. To extend it:

The JSONL log contains every Pareto update and merge decision, so you can inspect candidate evolution with tools like jq or rg.

Use the ADE workflow as a template:

Promote result.optimized_program only after evaluating it on data GEPA did not use for candidate selection.

Lakshya A. Agrawal et al., “GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning,” arXiv:2507.19457 (2025). ↩

**Examples:**

Example 1 (unknown):
```unknown
examples/ade_optimizer_gepa/
```

Example 2 (unknown):
```unknown
gem 'dspy'
gem 'dspy-gepa'
```

Example 3 (unknown):
```unknown
gem 'dspy'
gem 'dspy-gepa'
```

Example 4 (sass):
```sass
DSPY_WITH_GEPA=1 bundle install
```

---

## MIPROv2 Program Optimization in Ruby | DSPy.rb

**URL:** https://oss.vicente.services/dspy.rb/optimization/miprov2/

**Contents:**
- MIPROv2 Optimizer
- Decide Whether MIPROv2 Fits
- Quickstart (ADE demo)
- Integration walkthrough
  - 1. Describe the task with a signature
  - 2. Build examples and measure a baseline
  - 3. Define a developer-friendly metric
  - 4. Pick the right preset (or customize)
  - 5. Compile and inspect the optimized program
- Reading the outputs

See the package and capability matrix for the dspy-miprov2 install, require, dependency, and support boundary.

MIPROv2 searches over instructions and few-shot demonstrations for one or more predictors. You provide a typed program, examples, a metric, and a budget. It evaluates candidates on minibatches and returns the best program it found for the validation data.1

ℹ️ Packaging note — MIPROv2 ships as the dspy-miprov2 gem. Add it alongside dspy in your Gemfile:

Bundler will require dspy/miprov2 automatically. The separate gem keeps the Gaussian Process dependency tree out of apps that do not need advanced optimization.

Run the repository’s ADE demo to inspect one bounded MIPROv2 workflow:

What you get out of a single command:

Treat the demo as a recipe. Replace the dataset builder and metric with your own code, keep the rest.

Follow the structure from examples/ade_optimizer_miprov2/main.rb when bringing MIPROv2 into your project.

Typed signatures give MIPROv2 the schema it needs for generating examples, validating LM outputs, and rendering prompts.

Hold back a test set from the optimization loop. MIPROv2 selects candidates on train and validation data; compare the selected program on held-out or production data before making a generalization claim.

Metrics can be as simple as a boolean. The ADE demo shows the minimal viable option:

Return true when the prediction meets your acceptance criteria. For richer feedback (e.g., correctness + penalty scores), return a numeric score or DSPy::Prediction.

Presets follow the paper’s guidance on how many trials, instruction candidates, and bootstrap batches you need:

Switch to manual configuration when you already know the budget you can afford.

The result object exposes:

MIPROv2 writes two main artifacts under examples/ade_optimizer_miprov2/results/:

Inside the console you’ll also see the best instruction found during the run. To persist the complete optimized program, store it with the optimization result:

The program and signature classes must be loaded when you restore the artifact, and the program class must implement .from_h. Evaluate loaded_program against the held-out set before promoting it.

The ADE demo has one predictor. For a multi-predictor example, see spec/integration/dspy/mipro_v2_re_act_integration_spec.rb, where the optimizer:

If your pipeline mixes tools and plain LLM calls, the metric sees only the final output—the optimizer handles credit assignment internally.

The Stanford team behind MIPROv2 observed three practices that translate well to Ruby apps1:

The paper reports improvements on its evaluated tasks. Measure the Ruby program on a held-out set before promoting an optimized artifact.

Opsahl-Ong, Krista, et al. Optimizing Instructions and Demonstrations for Multi-Stage Language Model Programs. arXiv:2406.11695v2, 2024. ↩ ↩2

**Examples:**

Example 1 (unknown):
```unknown
dspy-miprov2
```

Example 2 (unknown):
```unknown
dspy-miprov2
```

Example 3 (unknown):
```unknown
gem "dspy"
gem "dspy-miprov2"
```

Example 4 (unknown):
```unknown
gem "dspy"
gem "dspy-miprov2"
```

---
