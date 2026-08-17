# API Reference: re_act.rb

**Language**: Ruby

**Source**: `lib/dspy/re_act.rb`

---

## Classes

### ReAct

**Inherits from**: Predict



### MaxIterationsError

**Inherits from**: StandardError



### end

**Inherits from**: (none)



## Functions

### to_h()

**Returns**: (none)



### initialize(message = "Agent reached maximum iterations without producing a final answer", iterations: nil, max_iterations: nil, tools_used: [], history: [], last_observation: nil, partial_final_answer: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | "Agent reached maximum iterations without producing a final answer" | - |
| iterations: nil | None | - | - |
| max_iterations: nil | None | - | - |
| tools_used: [] | None | - | - |
| history: [] | None | - | - |
| last_observation: nil | None | - | - |
| partial_final_answer: nil | None | - | - |

**Returns**: (none)



### initialize(signature_class, tools: [], max_iterations: 5)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| tools: [] | None | - | - |
| max_iterations: 5 | None | - | - |

**Returns**: (none)



### name()

**Returns**: (none)



### named_predictors()

**Returns**: (none)



### predictors()

**Returns**: (none)



### prompt()

**Returns**: (none)



### with_instruction(instruction)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| instruction | None | - | - |

**Returns**: (none)



### with_examples(examples)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| examples | None | - | - |

**Returns**: (none)



### forward(**kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **kwargs | None | - | - |

**Returns**: (none)



### loop_description(signature_class, loop_instruction)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| loop_instruction | None | - | - |

**Returns**: (none)



### serialize_for_llm(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)



### serialize_history_for_llm(history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| history | None | - | - |

**Returns**: (none)



### format_input_context(input_struct)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_struct | None | - | - |

**Returns**: (none)



### format_history(history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| history | None | - | - |

**Returns**: (none)



### format_observation(observation)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| observation | None | - | - |

**Returns**: (none)



### toon_data_format?()

**Returns**: (none)



### create_action_enum_class()

**Returns**: (none)



### create_thought_signature(signature_class, data_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| data_format | None | - | - |

**Returns**: (none)



### create_observation_signature(signature_class, data_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| data_format | None | - | - |

**Returns**: (none)



### execute_react_reasoning_loop(input_struct)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_struct | None | - | - |

**Returns**: (none)



### execute_single_iteration(input_struct, history, available_tools_desc, iteration, tools_used, last_observation)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_struct | None | - | - |
| history | None | - | - |
| available_tools_desc | None | - | - |
| iteration | None | - | - |
| tools_used | None | - | - |
| last_observation | None | - | - |

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



### find_last_tool_observation(history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| history | None | - | - |

**Returns**: (none)



### build_max_iterations_error(iterations:, tools_used:, history:, partial_final_answer: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iterations: | None | - | - |
| tools_used: | None | - | - |
| history: | None | - | - |
| partial_final_answer: nil | None | - | - |

**Returns**: (none)



### deserialize_final_answer(final_answer, output_field_type, history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| final_answer | None | - | - |
| output_field_type | None | - | - |
| history | None | - | - |

**Returns**: (none)



### deserialize_scalar(final_answer, output_field_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| final_answer | None | - | - |
| output_field_type | None | - | - |

**Returns**: (none)



### deserialize_structured(final_answer, output_field_type, history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| final_answer | None | - | - |
| output_field_type | None | - | - |
| history | None | - | - |

**Returns**: (none)



### convert_to_expected_type(value, type_object)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| type_object | None | - | - |

**Returns**: (none)



### type_matches?(value, type_object)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| type_object | None | - | - |

**Returns**: (none)



### should_continue_iteration?(iterations_count, final_answer)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iterations_count | None | - | - |
| final_answer | None | - | - |

**Returns**: (none)



### finish_action?(action)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| action | None | - | - |

**Returns**: (none)



### valid_tool?(action)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| action | None | - | - |

**Returns**: (none)



### execute_tool_with_instrumentation(action, tool_input, iteration)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| action | None | - | - |
| tool_input | None | - | - |
| iteration | None | - | - |

**Returns**: (none)



### serialize_tool_payload(payload)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| payload | None | - | - |

**Returns**: (none)



### create_history_entry(step, thought, action, tool_input, observation)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| step | None | - | - |
| thought | None | - | - |
| action | None | - | - |
| tool_input | None | - | - |
| observation | None | - | - |

**Returns**: (none)



### process_observation_and_decide_next_step(input_struct, history, observation, available_tools_desc, iteration, tools_used)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_struct | None | - | - |
| history | None | - | - |
| observation | None | - | - |
| available_tools_desc | None | - | - |
| iteration | None | - | - |
| tools_used | None | - | - |

**Returns**: (none)



### generate_forced_final_answer(input_struct, history, available_tools_desc, observation_result, iteration, tools_used)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_struct | None | - | - |
| history | None | - | - |
| available_tools_desc | None | - | - |
| observation_result | None | - | - |
| iteration | None | - | - |
| tools_used | None | - | - |

**Returns**: (none)



### emit_iteration_complete_event(iteration, thought, action, tool_input, observation, tools_used)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iteration | None | - | - |
| thought | None | - | - |
| action | None | - | - |
| tool_input | None | - | - |
| observation | None | - | - |
| tools_used | None | - | - |

**Returns**: (none)



### handle_max_iterations_if_needed(iterations_count, final_answer, tools_used, history)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| iterations_count | None | - | - |
| final_answer | None | - | - |
| tools_used | None | - | - |
| history | None | - | - |

**Returns**: (none)



### execute_action(action, tool_input)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| action | None | - | - |
| tool_input | None | - | - |

**Returns**: (none)



### generate_example_output()

**Returns**: (none)



### handle_finish_action(final_answer_value, last_observation, step, thought, action, history, output_field_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| final_answer_value | None | - | - |
| last_observation | None | - | - |
| step | None | - | - |
| thought | None | - | - |
| action | None | - | - |
| history | None | - | - |
| output_field_type | None | - | - |

**Returns**: (none)



### expected_output_field_type()

**Returns**: (none)



### coerce_candidate_for_output(value, output_field_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| output_field_type | None | - | - |

**Returns**: (none)



### parse_json_string(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)


