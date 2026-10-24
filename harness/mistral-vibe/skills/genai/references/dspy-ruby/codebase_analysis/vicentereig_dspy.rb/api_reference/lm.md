# API Reference: lm.rb

**Language**: Ruby

**Source**: `lib/dspy/lm.rb`

---

## Classes

### LM

**Inherits from**: (none)



## Functions

### initialize(model_id, api_key: nil, schema_format: :json, data_format: :json, **options)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| model_id | None | - | - |
| api_key: nil | None | - | - |
| schema_format: :json | None | - | - |
| data_format: :json | None | - | - |
| **options | None | - | - |

**Returns**: (none)



### chat(inference_module, input_values, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| inference_module | None | - | - |
| input_values | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### raw_chat(messages = nil, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | nil | - |
| &block | None | - | - |

**Returns**: (none)



### chat_with_strategy(messages, signature_class, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |
| signature_class | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### execute_chat_with_strategy(messages, signature_class, strategy, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |
| signature_class | None | - | - |
| strategy | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### parse_model_id(model_id)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| model_id | None | - | - |

**Returns**: (none)



### build_messages(inference_module, input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| inference_module | None | - | - |
| input_values | None | - | - |

**Returns**: (none)



### extract_document_inputs(input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |

**Returns**: (none)



### nested_document_input?(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)



### validate_document_predict_support!(input_values, document_inputs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| input_values | None | - | - |
| document_inputs | None | - | - |

**Returns**: (none)



### will_use_structured_outputs?(signature_class, data_format: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_class | None | - | - |
| data_format: nil | None | - | - |

**Returns**: (none)



### parse_response(response, input_values, signature_class)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| response | None | - | - |
| input_values | None | - | - |
| signature_class | None | - | - |

**Returns**: (none)



### normalize_output_payload(payload)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| payload | None | - | - |

**Returns**: (none)



### instrument_lm_request(messages, signature_class_name, &execution_block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |
| signature_class_name | None | - | - |
| &execution_block | None | - | - |

**Returns**: (none)



### emit_token_usage(response, signature_class_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| response | None | - | - |
| signature_class_name | None | - | - |

**Returns**: (none)



### extract_token_usage(response)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| response | None | - | - |

**Returns**: (none)



### execute_raw_chat(messages, &streaming_block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |
| &streaming_block | None | - | - |

**Returns**: (none)



### normalize_messages(messages)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |

**Returns**: (none)



### messages_to_hash_array(messages)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| messages | None | - | - |

**Returns**: (none)


