# API Reference: predict.rb

**Language**: Ruby

**Source**: `lib/dspy/predict.rb`

---

## Classes

### PredictionInvalidError

**Inherits from**: StandardError



## Functions

### initialize(errors, context: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| errors | None | - | - |
| context: nil | None | - | - |

**Returns**: (none)



### initialize(signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |

**Returns**: (none)



### from_h(data)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| data | None | - | - |

**Returns**: (none)



### system_signature()

**Returns**: (none)



### user_signature(input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |

**Returns**: (none)



### with_prompt(new_prompt)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_prompt | None | - | - |

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



### add_examples(examples)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| examples | None | - | - |

**Returns**: (none)



### configure(&block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| &block | None | - | - |

**Returns**: (none)



### named_predictors()

**Returns**: (none)



### predictors()

**Returns**: (none)



### forward_untyped(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### reset_thread_state()

**Returns**: (none)



### build_prompt_from_signature()

**Returns**: (none)



### sync_prompt_formats_from_lm(lm_source)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| lm_source | None | - | - |

**Returns**: (none)



### validate_input_struct(input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |

**Returns**: (none)



### process_lm_output(output_attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| output_attributes | None | - | - |

**Returns**: (none)



### create_prediction_result(input_values, output_attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |
| output_attributes | None | - | - |

**Returns**: (none)



### create_combined_struct_class()

**Returns**: (none)



### apply_defaults_to_output(output_attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| output_attributes | None | - | - |

**Returns**: (none)



### preprocess_nilable_attributes(attributes, struct_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |
| struct_class | None | - | - |

**Returns**: (none)


