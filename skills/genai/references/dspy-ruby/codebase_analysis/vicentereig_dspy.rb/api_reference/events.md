# API Reference: events.rb

**Language**: Ruby

**Source**: `lib/dspy/events.rb`

---

## Classes

### EventRegistry

**Inherits from**: (none)



## Functions

### initialize()

**Returns**: (none)



### subscribe(pattern, &block)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| pattern | None | - | - |
| &block | None | - | - |

**Returns**: (none)



### unsubscribe(subscription_id)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| subscription_id | None | - | - |

**Returns**: (none)



### clear_listeners()

**Returns**: (none)



### notify(event_name, attributes)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| event_name | None | - | - |
| attributes | None | - | - |

**Returns**: (none)



### pattern_matches?(pattern, event_name)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| pattern | None | - | - |
| event_name | None | - | - |

**Returns**: (none)


