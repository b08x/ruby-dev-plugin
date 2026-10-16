# API Reference: callbacks.rb

**Language**: Ruby

**Source**: `lib/dspy/callbacks.rb`

---

## Functions

### setup_context()

**Returns**: (none)



### log_metrics()

**Returns**: (none)



### manage_memory()

**Returns**: (none)



### included(base)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| base | None | - | - |

**Returns**: (none)



### create_before_callback(method_name, wrap: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |
| wrap: true | None | - | - |

**Returns**: (none)



### create_after_callback(method_name, wrap: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |
| wrap: true | None | - | - |

**Returns**: (none)



### create_around_callback(method_name, wrap: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |
| wrap: true | None | - | - |

**Returns**: (none)



### ensure_callback_method_defined(type, target_method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |
| target_method_name | None | - | - |

**Returns**: (none)



### register_callback(type, method_name, callback)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |
| method_name | None | - | - |
| callback | None | - | - |

**Returns**: (none)



### own_callbacks_for(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### mark_method_has_callbacks(method_name, wrap: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |
| wrap: true | None | - | - |

**Returns**: (none)



### callbacks_for(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### wrap_method_with_callbacks(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### has_around_callbacks?(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### method_added(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### method_has_callback_support?(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### mark_method_wrapped(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### method_wrapped?(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### manual_callback_targets()

**Returns**: (none)



### callback_defaults()

**Returns**: (none)



### set_default_callback_target(type, method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |
| method_name | None | - | - |

**Returns**: (none)



### default_callback_target(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### run_callbacks(type, method_name, payload = nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |
| method_name | None | - | - |
| payload | None | nil | - |

**Returns**: (none)



### execute_with_around_callbacks(method_name, original_method, *args, **kwargs, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |
| original_method | None | - | - |
| *args | None | - | - |
| **kwargs | None | - | - |
| &block | None | - | - |

**Returns**: (none)


