# API Reference: telemetry.rb

**Language**: Ruby

**Source**: `lib/gepa/telemetry.rb`

---

## Functions

### with_span(operation, metadata = {}, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| operation | None | - | - |
| metadata | None | {} | - |
| &block | None | - | - |

**Returns**: (none)



### emit(event_name, metadata = {})

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| event_name | None | - | - |
| metadata | None | {} | - |

**Returns**: (none)



### base_attributes()

**Returns**: (none)



### build_context(additional_attributes = {})

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| additional_attributes | None | {} | - |

**Returns**: (none)



### with_span(operation, attributes = {}, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| operation | None | - | - |
| attributes | None | {} | - |
| &block | None | - | - |

**Returns**: (none)



### emit(event_name, attributes = {})

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| event_name | None | - | - |
| attributes | None | {} | - |

**Returns**: (none)



### normalize_operation(operation)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| operation | None | - | - |

**Returns**: (none)



### symbolize(attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |

**Returns**: (none)


