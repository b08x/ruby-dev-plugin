# API Reference: evals.rb

**Language**: Ruby

**Source**: `lib/dspy/evals.rb`

---

## Classes

### Evals

**Inherits from**: (none)



### EvaluationResult

**Inherits from**: (none)



### BatchEvaluationResult

**Inherits from**: (none)



## Functions

### initialize(example:, prediction:, trace:, metrics:, passed:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example: | None | - | - |
| prediction: | None | - | - |
| trace: | None | - | - |
| metrics: | None | - | - |
| passed: | None | - | - |

**Returns**: (none)



### to_h()

**Returns**: (none)



### initialize(results:, aggregated_metrics:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| results: | None | - | - |
| aggregated_metrics: | None | - | - |

**Returns**: (none)



### to_h()

**Returns**: (none)



### to_polars()

**Returns**: (none)



### ensure_polars!()

**Returns**: (none)



### serialize_for_polars(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)



### before_example(callback = nil, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| callback | None | nil | - |
| &block | None | - | - |

**Returns**: (none)



### after_example(callback = nil, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| callback | None | nil | - |
| &block | None | - | - |

**Returns**: (none)



### before_batch(callback = nil, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| callback | None | nil | - |
| &block | None | - | - |

**Returns**: (none)



### after_batch(callback = nil, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| callback | None | nil | - |
| &block | None | - | - |

**Returns**: (none)



### reset_callbacks!()

**Returns**: (none)



### initialize(program, metric: nil, num_threads: 1, max_errors: 5, failure_score: 0.0, provide_traceback: true, export_scores: false, score_name: 'evaluation')

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| program | None | - | - |
| metric: nil | None | - | - |
| num_threads: 1 | None | - | - |
| max_errors: 5 | None | - | - |
| failure_score: 0.0 | None | - | - |
| provide_traceback: true | None | - | - |
| export_scores: false | None | - | - |
| score_name: 'evaluation' | None | - | - |

**Returns**: (none)



### call(example, trace: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| trace: nil | None | - | - |

**Returns**: (none)



### evaluate(devset, display_progress: true, display_table: false, return_outputs: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| devset | None | - | - |
| display_progress: true | None | - | - |
| display_table: false | None | - | - |
| return_outputs: true | None | - | - |

**Returns**: (none)



### parallel_execution?(@num_threads || 1)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| @num_threads || 1 | None | - | - |

**Returns**: (none)



### evaluate_sequential(devset, display_progress:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| devset | None | - | - |
| display_progress: | None | - | - |

**Returns**: (none)



### evaluate_in_parallel(devset, display_progress:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| devset | None | - | - |
| display_progress: | None | - | - |

**Returns**: (none)



### safe_call(example, program: @program, track_state: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| program: @program | None | - | - |
| track_state: true | None | - | - |

**Returns**: (none)



### perform_call(example, trace:, program:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| trace: | None | - | - |
| program: | None | - | - |

**Returns**: (none)



### call_with_program(program, example, trace: nil, track_state: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| program | None | - | - |
| example | None | - | - |
| trace: nil | None | - | - |
| track_state: true | None | - | - |

**Returns**: (none)



### fork_program_for_thread()

**Returns**: (none)



### build_error_result(example, error, trace: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| error | None | - | - |
| trace: nil | None | - | - |

**Returns**: (none)



### log_progress(processed, total, passed_count)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| processed | None | - | - |
| total | None | - | - |
| passed_count | None | - | - |

**Returns**: (none)



### extract_input_values(example)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |

**Returns**: (none)



### extract_expected_values(example)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |

**Returns**: (none)



### aggregate_metrics(results)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| results | None | - | - |

**Returns**: (none)



### display_results_table(batch_result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| batch_result | None | - | - |

**Returns**: (none)



### emit_example_observation(example, result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| result | None | - | - |

**Returns**: (none)



### emit_batch_observation(devset, batch_result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| devset | None | - | - |
| batch_result | None | - | - |

**Returns**: (none)



### export_example_score(example, result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |
| result | None | - | - |

**Returns**: (none)



### export_batch_score(batch_result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| batch_result | None | - | - |

**Returns**: (none)



### extract_example_id(example)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| example | None | - | - |

**Returns**: (none)



### symbolize_keys(hash)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |

**Returns**: (none)



### normalize_score(value, passed)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| passed | None | - | - |

**Returns**: (none)



### exact_match(field: :answer, case_sensitive: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| field: :answer | None | - | - |
| case_sensitive: true | None | - | - |

**Returns**: (none)



### contains(field: :answer, case_sensitive: false)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| field: :answer | None | - | - |
| case_sensitive: false | None | - | - |

**Returns**: (none)



### numeric_difference(field: :answer, tolerance: 0.01)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| field: :answer | None | - | - |
| tolerance: 0.01 | None | - | - |

**Returns**: (none)



### composite_and(*metrics)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| *metrics | None | - | - |

**Returns**: (none)



### extract_field(obj, field)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| obj | None | - | - |
| field | None | - | - |

**Returns**: (none)


