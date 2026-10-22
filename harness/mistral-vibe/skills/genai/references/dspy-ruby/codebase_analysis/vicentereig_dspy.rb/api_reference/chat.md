# API Reference: chat.rb

**Language**: Ruby

**Source**: `examples/deep_research_cli/chat.rb`

---

## Classes

### StatusBoard

**Inherits from**: (none)



## Functions

### initialize(updater)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| updater | None | - | - |

**Returns**: (none)



### subscribe()

**Returns**: (none)



### unsubscribe()

**Returns**: (none)



### relevant_module?(attrs)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| attrs | None | - | - |

**Returns**: (none)



### value_for(hash, key)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| hash | None | - | - |
| key | None | - | - |

**Returns**: (none)



### update_status(text)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| text | None | - | - |

**Returns**: (none)



### refresh()

**Returns**: (none)



### label()

**Returns**: (none)



### elapsed_string()

**Returns**: (none)



### mark_completed()

**Returns**: (none)



### mark_error(message)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| message | None | - | - |

**Returns**: (none)



### truncate(text, length = 40)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| text | None | - | - |
| length | None | 40 | - |

**Returns**: (none)



### host_for(url)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| url | None | - | - |

**Returns**: (none)



### formatted_elapsed()

**Returns**: (none)



### initialize()

**Returns**: (none)



### forward_untyped(**input_values)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **input_values | None | - | - |

**Returns**: (none)



### parse_options(argv)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| argv | None | - | - |

**Returns**: (none)



### ensure_configuration!(dry_run:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| dry_run: | None | - | - |

**Returns**: (none)



### configure_lm!()

**Returns**: (none)



### build_agent(dry_run:)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| dry_run: | None | - | - |

**Returns**: (none)



### render_result(result, brief)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| result | None | - | - |
| brief | None | - | - |

**Returns**: (none)



### render_sections(result)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| result | None | - | - |

**Returns**: (none)



### prompt_loop(agent)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| agent | None | - | - |

**Returns**: (none)



### run_research(agent, brief)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| agent | None | - | - |
| brief | None | - | - |

**Returns**: (none)



### truncate_text(text, limit = 80)

**Parameters**:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| text | None | - | - |
| limit | None | 80 | - |

**Returns**: (none)


