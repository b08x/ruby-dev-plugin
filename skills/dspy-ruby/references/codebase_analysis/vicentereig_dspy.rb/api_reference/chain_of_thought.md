# API Reference: chain_of_thought.rb

**Language**: Ruby

**Source**: `lib/dspy/chain_of_thought.rb`

---

## Classes

### ChainOfThought

**Inherits from**: Predict



## Functions

### initialize(signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |

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



### forward_untyped(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### build_enhanced_signature(signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |

**Returns**: (none)



### create_signature_class(signature_class, enhanced_output_struct)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| enhanced_output_struct | None | - | - |

**Returns**: (none)



### name()

**Returns**: (none)



### create_enhanced_output_struct(signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |

**Returns**: (none)



### ensure_chain_of_thought_instruction(instruction)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| instruction | None | - | - |

**Returns**: (none)



### analyze_reasoning(prediction_result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| prediction_result | None | - | - |

**Returns**: (none)



### emit_reasoning_analysis(reasoning_content)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| reasoning_content | None | - | - |

**Returns**: (none)



### count_reasoning_steps(reasoning_text)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| reasoning_text | None | - | - |

**Returns**: (none)


