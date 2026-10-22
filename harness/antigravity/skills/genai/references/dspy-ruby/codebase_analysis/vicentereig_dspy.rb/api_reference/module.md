# API Reference: module.rb

**Language**: Ruby

**Source**: `lib/dspy/module.rb`

---

## Classes

### Module

**Inherits from**: (none)



## Functions

### method_added(method_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method_name | None | - | - |

**Returns**: (none)



### inherited(subclass)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| subclass | None | - | - |

**Returns**: (none)



### subscribe(pattern, handler = nil, scope: DEFAULT_MODULE_SUBSCRIPTION_SCOPE, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| pattern | None | - | - |
| handler | None | nil | - |
| scope: DEFAULT_MODULE_SUBSCRIPTION_SCOPE | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### module_subscription_specs()

**Returns**: (none)



### build_subscription_callback(weakref, subscription_id_ref, spec)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| weakref | None | - | - |
| subscription_id_ref | None | - | - |
| spec | None | - | - |

**Returns**: (none)



### validate_subscription_scope!(scope)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| scope | None | - | - |

**Returns**: (none)



### normalize_scope(scope)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| scope | None | - | - |

**Returns**: (none)



### forward(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### forward_untyped(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### call(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### call_untyped(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### lm()

**Returns**: (none)



### save(path)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| path | None | - | - |

**Returns**: (none)



### to_h()

**Returns**: (none)



### named_predictors()

**Returns**: (none)



### predictors()

**Returns**: (none)



### configure(&block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| &block | None | - | - |

**Returns**: (none)



### configure_predictor(predictor_name, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| predictor_name | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### instrument_forward_call(call_args, call_kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| call_args | None | - | - |
| call_kwargs | None | - | - |

**Returns**: (none)



### serialize_module_input(call_args, call_kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| call_args | None | - | - |
| call_kwargs | None | - | - |

**Returns**: (none)



### serialize_module_output(result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| result | None | - | - |

**Returns**: (none)



### serialize_module_error_output(error)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| error | None | - | - |

**Returns**: (none)



### root_trace_attributes(call_args, call_kwargs, input_json)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| call_args | None | - | - |
| call_kwargs | None | - | - |
| input_json | None | - | - |

**Returns**: (none)



### resolve_conversation_id(call_args, call_kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| call_args | None | - | - |
| call_kwargs | None | - | - |

**Returns**: (none)



### fetch_hash_value(hash, key)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |
| key | None | - | - |

**Returns**: (none)



### present_value?(value)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |

**Returns**: (none)



### infer_signature_kind(signature_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| signature_name | None | - | - |

**Returns**: (none)



### module_scope_id()

**Returns**: (none)



### module_scope_label()

**Returns**: (none)



### module_scope_label()

**Returns**: (none)



### registered_module_subscriptions()

**Returns**: (none)



### unsubscribe_module_events()

**Returns**: (none)



### dup_for_thread()

**Returns**: (none)



### reset_thread_state()

**Returns**: (none)



### propagate_lm_to_children(lm)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| lm | None | - | - |

**Returns**: (none)



### ensure_module_subscriptions!()

**Returns**: (none)



### module_event_within_scope?(attributes, scope)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |
| scope | None | - | - |

**Returns**: (none)



### extract_module_metadata(attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |

**Returns**: (none)


