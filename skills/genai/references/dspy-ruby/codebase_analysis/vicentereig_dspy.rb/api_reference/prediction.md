# API Reference: prediction.rb

**Language**: Ruby

**Source**: `lib/dspy/prediction.rb`

---

## Classes

### Prediction

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



### end

**Inherits from**: (none)



## Functions

### initialize(schema = nil, **attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| schema | None | nil | - |
| **attributes | None | - | - |

**Returns**: (none)



### method_missing(method, *args, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method | None | - | - |
| *args | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### respond_to_missing?(method, include_all = false)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| method | None | - | - |
| include_all | None | false | - |

**Returns**: (none)



### to_h()

**Returns**: (none)



### to_json(*args)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| *args | None | - | - |

**Returns**: (none)



### extract_struct_class(schema)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| schema | None | - | - |

**Returns**: (none)



### convert_attributes_with_schema(attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |

**Returns**: (none)



### detect_discriminator_fields(schema)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| schema | None | - | - |

**Returns**: (none)



### is_union_type?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### is_nilable_type?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### is_string_type?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### is_enum_type?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### extract_enum_class(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### build_type_mapping_from_union(union_type, discriminator_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| union_type | None | - | - |
| discriminator_type | None | - | - |

**Returns**: (none)



### convert_union_type(value, discriminator_value, type_mapping, union_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| discriminator_value | None | - | - |
| type_mapping | None | - | - |
| union_type | None | - | - |

**Returns**: (none)



### needs_struct_conversion?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### convert_to_struct(value, type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| value | None | - | - |
| type | None | - | - |

**Returns**: (none)



### needs_array_conversion?(type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| type | None | - | - |

**Returns**: (none)



### convert_array_elements(array, type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| array | None | - | - |
| type | None | - | - |

**Returns**: (none)



### convert_hash_to_union_struct(hash, union_type)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |
| union_type | None | - | - |

**Returns**: (none)



### create_dynamic_struct(attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attributes | None | - | - |

**Returns**: (none)


