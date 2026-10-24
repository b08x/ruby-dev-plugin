# API Reference: error_formatter.rb

**Language**: Ruby

**Source**: `lib/dspy/error_formatter.rb`

---

## Classes

### ErrorFormatter

**Inherits from**: (none)



## Functions

### format_error(error_message, context = nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| error_message | None | - | - |
| context | None | nil | - |

**Returns**: (none)



### sorbet_type_error?(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)



### argument_error?(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)



### format_sorbet_type_error(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)



### format_argument_error(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)



### format_missing_fields_error(fields)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| fields | None | - | - |

**Returns**: (none)



### format_unknown_fields_error(fields)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| fields | None | - | - |

**Returns**: (none)



### generate_type_specific_explanation(actual_type, expected_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| actual_type | None | - | - |
| expected_type | None | - | - |

**Returns**: (none)



### generate_suggestions(field_name, actual_type, expected_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| field_name | None | - | - |
| actual_type | None | - | - |
| expected_type | None | - | - |

**Returns**: (none)



### clean_error_message(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)


