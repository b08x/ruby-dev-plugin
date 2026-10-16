# API Reference: prompt.rb

**Language**: Ruby

**Source**: `lib/dspy/prompt.rb`

---

## Classes

### Prompt

**Inherits from**: (none)



### begin

**Inherits from**: (none)



### name

**Inherits from**: (none)



### name

**Inherits from**: (none)



### end

**Inherits from**: (none)



## Functions

### schema_format()

**Returns**: (none)



### data_format()

**Returns**: (none)



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



### with_instruction(new_instruction)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_instruction | None | - | - |

**Returns**: (none)



### with_examples(new_examples)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_examples | None | - | - |

**Returns**: (none)



### add_examples(new_examples)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_examples | None | - | - |

**Returns**: (none)



### with_schema_format(new_schema_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_schema_format | None | - | - |

**Returns**: (none)



### with_data_format(new_data_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| new_data_format | None | - | - |

**Returns**: (none)



### render_system_prompt()

**Returns**: (none)



### render_user_prompt(input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |

**Returns**: (none)



### to_h()

**Returns**: (none)



### from_h(hash)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |

**Returns**: (none)



### from_signature(signature_class, schema_format: nil, data_format: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| schema_format: nil | None | - | - |
| data_format: nil | None | - | - |

**Returns**: (none)



### diff(other)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| other | None | - | - |

**Returns**: (none)



### stats()

**Returns**: (none)



### render_baml_schema(schema, type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| schema | None | - | - |
| type | None | - | - |

**Returns**: (none)



### toon_data_format_enabled?()

**Returns**: (none)



### example_toon_payload(role)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| role | None | - | - |

**Returns**: (none)



### sample_struct_values(struct_class, depth = 0)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| struct_class | None | - | - |
| depth | None | 0 | - |

**Returns**: (none)



### sample_value_for_type(prop_type, field_name, depth)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| prop_type | None | - | - |
| field_name | None | - | - |
| depth | None | - | - |

**Returns**: (none)



### sample_for_class_type(prop_type, field_name, depth)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| prop_type | None | - | - |
| field_name | None | - | - |
| depth | None | - | - |

**Returns**: (none)



### nil_type?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### sample_string(field_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| field_name | None | - | - |

**Returns**: (none)



### resolve_schema_format(schema_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| schema_format | None | - | - |

**Returns**: (none)



### resolve_data_format(data_format)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| data_format | None | - | - |

**Returns**: (none)


