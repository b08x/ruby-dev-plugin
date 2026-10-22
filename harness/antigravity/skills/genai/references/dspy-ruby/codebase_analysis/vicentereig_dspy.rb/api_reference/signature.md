# API Reference: signature.rb

**Language**: Ruby

**Source**: `lib/dspy/signature.rb`

---

## Classes

### Signature

**Inherits from**: (none)



### FieldDescriptor

**Inherits from**: (none)



### StructBuilder

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



## Functions

### initialize(type, description = nil, has_default = false, default_value = nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |
| description | None | nil | - |
| has_default | None | false | - |
| default_value | None | nil | - |

**Returns**: (none)



### initialize()

**Returns**: (none)



### const(name, type, **kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| name | None | - | - |
| type | None | - | - |
| **kwargs | None | - | - |

**Returns**: (none)



### build_struct_class()

**Returns**: (none)



### new(*args, **kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| *args | None | - | - |
| **kwargs | None | - | - |

**Returns**: (none)



### constructor_properties(args, kwargs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| args | None | - | - |
| kwargs | None | - | - |

**Returns**: (none)



### validate_required_fields!(properties, descriptors)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| properties | None | - | - |
| descriptors | None | - | - |

**Returns**: (none)



### description(desc = nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| desc | None | nil | - |

**Returns**: (none)



### input(&block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| &block | None | - | - |

**Returns**: (none)



### output(&block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| &block | None | - | - |

**Returns**: (none)



### input_json_schema()

**Returns**: (none)



### input_schema()

**Returns**: (none)



### output_json_schema()

**Returns**: (none)



### output_json_schema_with_defs()

**Returns**: (none)



### output_schema()

**Returns**: (none)


