# API Reference: context.rb

**Language**: Ruby

**Source**: `lib/dspy/context.rb`

---

## Classes

### Context

**Inherits from**: (none)



## Functions

### current()

**Returns**: (none)



### with_request(request_id, start_time)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| request_id | None | - | - |
| start_time | None | - | - |

**Returns**: (none)



### fork_context(parent_context)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| parent_context | None | - | - |

**Returns**: (none)



### with_span(operation:, **attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| operation: | None | - | - |
| **attributes | None | - | - |

**Returns**: (none)



### with_module(module_instance, label: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| module_instance | None | - | - |
| label: nil | None | - | - |

**Returns**: (none)



### module_stack()

**Returns**: (none)



### module_context_attributes()

**Returns**: (none)



### clear!()

**Returns**: (none)



### in_async_context?()

**Returns**: (none)



### build_context()

**Returns**: (none)



### clone_context(context)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| context | None | - | - |

**Returns**: (none)



### sanitize_span_attributes(attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |

**Returns**: (none)



### sanitize_attribute_value(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)



### build_module_entry(module_instance, explicit_label)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| module_instance | None | - | - |
| explicit_label | None | - | - |

**Returns**: (none)



### set_span_timing_attributes(span, otel_start_time)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| span | None | - | - |
| otel_start_time | None | - | - |

**Returns**: (none)



### set_span_error_attributes(span, error)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| span | None | - | - |
| error | None | - | - |

**Returns**: (none)



### set_span_status_attribute(span, succeeded)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| span | None | - | - |
| succeeded | None | - | - |

**Returns**: (none)


