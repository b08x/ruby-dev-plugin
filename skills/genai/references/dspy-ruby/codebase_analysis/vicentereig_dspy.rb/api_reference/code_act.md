# API Reference: code_act.rb

**Language**: Ruby

**Source**: `lib/dspy/code_act.rb`

---

## Classes

### CodeAct

**Inherits from**: Predict



### CodeAct

**Inherits from**: (none)



## Functions

### to_h()

**Returns**: (none)



### initialize(signature_class, max_iterations: 10)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| max_iterations: 10 | None | - | - |

**Returns**: (none)



### name()

**Returns**: (none)



### named_predictors()

**Returns**: (none)



### predictors()

**Returns**: (none)



### forward(**kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **kwargs | None | - | - |

**Returns**: (none)



### execute_codeact_reasoning_loop(task)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| task | None | - | - |

**Returns**: (none)



### execute_single_iteration(task, history, context, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| task | None | - | - |
| history | None | - | - |
| context | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### execute_think_code_step(task, context, history, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| task | None | - | - |
| context | None | - | - |
| history | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### finalize_iteration(execution_state, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| execution_state | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### create_enhanced_output_struct(signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |

**Returns**: (none)



### create_enhanced_result(input_kwargs, reasoning_result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_kwargs | None | - | - |
| reasoning_result | None | - | - |

**Returns**: (none)



### should_continue_iteration?(iterations_count, final_answer)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iterations_count | None | - | - |
| final_answer | None | - | - |

**Returns**: (none)



### execute_ruby_code_with_instrumentation(ruby_code, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| ruby_code | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### create_history_entry(step, thought, ruby_code, execution_result, error_message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| step | None | - | - |
| thought | None | - | - |
| ruby_code | None | - | - |
| execution_result | None | - | - |
| error_message | None | - | - |

**Returns**: (none)



### process_observation_and_decide_next_step(task, history, execution_result, error_message, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| task | None | - | - |
| history | None | - | - |
| execution_result | None | - | - |
| error_message | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### build_context_from_history(history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| history | None | - | - |

**Returns**: (none)



### emit_iteration_complete_event(iteration, thought, ruby_code, execution_result, error_message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iteration | None | - | - |
| thought | None | - | - |
| ruby_code | None | - | - |
| execution_result | None | - | - |
| error_message | None | - | - |

**Returns**: (none)



### handle_max_iterations_if_needed(iterations_count, final_answer, history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iterations_count | None | - | - |
| final_answer | None | - | - |
| history | None | - | - |

**Returns**: (none)



### default_no_answer_message()

**Returns**: (none)



### execute_ruby_code_safely(ruby_code)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| ruby_code | None | - | - |

**Returns**: (none)



### generate_example_output()

**Returns**: (none)


