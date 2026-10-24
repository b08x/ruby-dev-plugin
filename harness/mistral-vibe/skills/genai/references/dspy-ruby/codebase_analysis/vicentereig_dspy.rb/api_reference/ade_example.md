# API Reference: ade_example.rb

**Language**: Ruby

**Source**: `examples/ade_optimizer_miprov2/ade_example.rb`

---

## Functions

### build_examples(rows)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| rows | None | - | - |

**Returns**: (none)



### split_examples(examples, train_ratio:, val_ratio:, seed: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| examples | None | - | - |
| train_ratio: | None | - | - |
| val_ratio: | None | - | - |
| seed: nil | None | - | - |

**Returns**: (none)



### default_split(examples, train_ratio, val_ratio)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| examples | None | - | - |
| train_ratio | None | - | - |
| val_ratio | None | - | - |

**Returns**: (none)



### ensure_label_presence!(splits, label)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| splits | None | - | - |
| label | None | - | - |

**Returns**: (none)



### label_from_prediction(prediction)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| prediction | None | - | - |

**Returns**: (none)



### evaluate(program, examples)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| program | None | - | - |
| examples | None | - | - |

**Returns**: (none)



### safe_divide(numerator, denominator)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| numerator | None | - | - |
| denominator | None | - | - |

**Returns**: (none)


