# API Reference: image.rb

**Language**: Ruby

**Source**: `lib/dspy/image.rb`

---

## Classes

### Image

**Inherits from**: (none)



## Functions

### initialize(url: nil, base64: nil, data: nil, content_type: nil, detail: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| url: nil | None | - | - |
| base64: nil | None | - | - |
| data: nil | None | - | - |
| content_type: nil | None | - | - |
| detail: nil | None | - | - |

**Returns**: (none)



### to_openai_format()

**Returns**: (none)



### to_anthropic_format()

**Returns**: (none)



### to_gemini_format()

**Returns**: (none)



### to_base64()

**Returns**: (none)



### validate!()

**Returns**: (none)



### validate_for_provider!(provider)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| provider | None | - | - |

**Returns**: (none)



### validate_input!(url, base64, data)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| url | None | - | - |
| base64 | None | - | - |
| data | None | - | - |

**Returns**: (none)



### validate_content_type!()

**Returns**: (none)



### validate_size!(size_bytes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| size_bytes | None | - | - |

**Returns**: (none)



### infer_content_type_from_url(url)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| url | None | - | - |

**Returns**: (none)


