# API Reference: structured_outputs_prompt.rb

**Language**: Ruby

**Source**: `lib/dspy/structured_outputs_prompt.rb`

---

## Classes

### StructuredOutputsPrompt

**Inherits from**: Prompt



## Functions

### initialize(instruction:, input_schema:, output_schema:, few_shot_examples: [], signature_class_name: nil, schema_format: nil, signature_class: nil, data_format: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| instruction: | None | - | - |
| input_schema: | None | - | - |
| output_schema: | None | - | - |
| few_shot_examples: [] | None | - | - |
| signature_class_name: nil | None | - | - |
| schema_format: nil | None | - | - |
| signature_class: nil | None | - | - |
| data_format: nil | None | - | - |

**Returns**: (none)



### render_system_prompt()

**Returns**: (none)



### render_user_prompt(input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |

**Returns**: (none)



### symbolize_keys(hash)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |

**Returns**: (none)


