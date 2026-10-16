# API Reference: scores.rb

**Language**: Ruby

**Source**: `lib/dspy/scores.rb`

---

## Functions

### create(name:, value:, data_type: DataType::Numeric, comment: nil, span: nil, trace_id: nil, observation_id: nil, emit: true)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| name: | None | - | - |
| value: | None | - | - |
| data_type: DataType::Numeric | None | - | - |
| comment: nil | None | - | - |
| span: nil | None | - | - |
| trace_id: nil | None | - | - |
| observation_id: nil | None | - | - |
| emit: true | None | - | - |

**Returns**: (none)



### extract_trace_id_from_context()

**Returns**: (none)



### extract_observation_id_from_span(span)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| span | None | - | - |

**Returns**: (none)



### emit_score_event(event)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| event | None | - | - |

**Returns**: (none)



### score(name, value, data_type: Scores::DataType::Numeric, comment: nil, span: nil, trace_id: nil, observation_id: nil)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| name | None | - | - |
| value | None | - | - |
| data_type: Scores::DataType::Numeric | None | - | - |
| comment: nil | None | - | - |
| span: nil | None | - | - |
| trace_id: nil | None | - | - |
| observation_id: nil | None | - | - |

**Returns**: (none)


