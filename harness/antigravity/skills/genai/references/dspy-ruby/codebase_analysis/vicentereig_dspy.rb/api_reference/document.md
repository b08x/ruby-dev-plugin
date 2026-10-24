# API Reference: document.rb

**Language**: Ruby

**Source**: `lib/dspy/document.rb`

---

## Classes

### Document

**Inherits from**: (none)



### RubyLLMInlineAttachment

**Inherits from**: StringIO



## Functions

### initialize(content, path:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| content | None | - | - |
| path: | None | - | - |

**Returns**: (none)



### initialize(url: nil, base64: nil, data: nil, content_type: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| url: nil | None | - | - |
| base64: nil | None | - | - |
| data: nil | None | - | - |
| content_type: nil | None | - | - |

**Returns**: (none)



### to_openai_format()

**Returns**: (none)



### to_anthropic_format()

**Returns**: (none)



### to_gemini_format()

**Returns**: (none)



### to_ruby_llm_attachment()

**Returns**: (none)



### to_base64()

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



### to_binary()

**Returns**: (none)


