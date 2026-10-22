# ruby-dev — Mistral Vibe harness port

This directory is a complete, self-contained port of the ruby-dev-plugin to
**Mistral Vibe** (native Agent Plugins 1.0 format). Upstream files outside
`harness/mistral-vibe/` stay byte-identical to the Claude Code version; this
directory holds the harness-specific deltas plus verbatim copies of the shared
Markdown (skills, references, tasks), so the two formats can diverge without
merge conflicts.

## Layout

```
harness/mistral-vibe/
  plugin.json                 # native Agent Plugins 1.0 manifest + ai.mistral.vibe extension
  skills/                     # 13 domain skills (verbatim) + 5 role skills (paths rebound)
                              #   + ruby-development / ruby-gate command-skills (ported from commands/)
  references/                 # shared conventions (verbatim copies)
  tasks/                      # workflow step files (paths rebound)
  ai.mistral.vibe/
    agents/                   # 5 phase subagent TOML profiles: specifier, implementer,
                              #   cleaner, hardener, verifier (ported from agents/*.md)
  agents/rubyist.toml         # main-thread orchestrator agent profile (vibe --agent rubyist)
  prompts/rubyist.md          # its system prompt (system_prompt_id = "rubyist")
```

## Install

User-global (recommended — available in every project):

```bash
rsync -a --delete harness/mistral-vibe/ ~/.vibe/plugins/ruby-dev/
```

Project-scope instead (only active inside a trusted project), from the project root:

```bash
mkdir -p .vibe/plugins && rsync -a --delete harness/mistral-vibe/ .vibe/plugins/ruby-dev/
```

Install the main-thread orchestrator agent profile as well (a plugin can only ship
subagents, so rubyist lives as a user agent profile):

```bash
cp harness/mistral-vibe/agents/rubyist.toml ~/.vibe/agents/rubyist.toml
cp harness/mistral-vibe/prompts/rubyist.md ~/.vibe/prompts/rubyist.md
```

Then run `/reload-plugins` (or `/reload`) in the Vibe session and confirm with
`/plugins` that `ruby-dev` shows up with skills and agents components; start the
orchestrator with `vibe --agent rubyist`.

After pulling upstream changes, re-run the same rsync command to refresh the
installed copy, then diff the copies under `skills/`, `references/`, and `tasks/`
against upstream (`../..` from here) and re-apply the harness rebindings listed
below if the changed files contained them.

## Harness translation map

| Claude Code mechanism | Mistral Vibe mechanism |
|---|---|
| `.claude-plugin/plugin.json` | `plugin.json` (native format takes precedence in Vibe) |
| `agents/*.md` (frontmatter agents) | 5 phase agents → `ai.mistral.vibe/agents/*.toml` subagents; rubyist → `~/.vibe/agents/rubyist.toml` main-thread agent |
| `Agent(ruby-dev:X)` dispatch | `agents.spawn` tool with `config_name` `rubyDev:X` |
| `rubyist` as main-thread agent (`claude --agent`) | `rubyist` is a user agent profile in `~/.vibe/agents/` (`vibe --agent rubyist`); the five phases remain plugin subagents |
| `/ruby-development`, `/ruby-gate` commands | user-invocable skills `rubyDev:ruby-development`, `rubyDev:ruby-gate` |
| `${CLAUDE_PLUGIN_ROOT}/...` paths | `<plugin-root>/...` with a locate-the-root note, or relative paths (`../../references/...`, `../<skill>/SKILL.md`) |
| `${CLAUDE_PLUGIN_ROOT}/skills/X/SKILL.md` loads | the `skill` tool with name `rubyDev:X` |
| `tools:` frontmatter gating | `disabled_tools` + `[tools.*] permission = "never"` (rubyist and verifier cannot edit files) |
| `$ARGUMENTS` in commands | the text the user typed after the `/rubyDev:<skill-name>` invocation |

Namespace: the manifest sets `toolNamespace = "rubyDev"`, so every component is
namespaced at runtime: skills `rubyDev:scaffold`, `rubyDev:role-implementer`,
`rubyDev:ruby-development`, `rubyDev:ruby-gate`; agents `rubyDev:specifier`,, `rubyDev:implementer`, `rubyDev:cleaner`,
`rubyDev:hardener`, `rubyDev:verifier`.

## Invariants preserved from upstream

- The orchestrator (`rubyist`, the main-thread agent) never writes Ruby: its write tools are
  disabled and set to `permission = "never"`.
- Each phase subagent loads its own role skill first
  (`rubyDev:role-<name>`), which carries the task-to-skill table; the
  orchestrator never loads role or domain skills (its `skill` tool is disabled).
- Fixed phase order specifier → implementer → cleaner → hardener → verifier,
  skipping stages that do not apply.
- Verify-don't-relay: gates and `VERIFY` run in the orchestrating context.
- The verifier runs in a fresh subagent, never inline.

> **Gem-API lookups:** some verbatim-copied skill bodies mention "Context7 MCP or
> DeepWiki" for verifying non-stdlib gem APIs. Those tools are not Vibe
> built-ins; use whatever lookup surface the session has (web search, configured
> MCP servers) instead. The rule itself is unchanged: verify non-stdlib gem APIs
> at point of use, never assume them from memory.

> **Agent TOML schema note (verified against the runtime):** the loader
> (`vibe/core/plugins/_native.py::_PluginAgentDocument`) requires **snake_case**
> keys — `schema_version`, `agent_type`, `display_name`, `enabled_tools`,
> `disabled_tools`, `instructions` — with `extra = "forbid"` (any unknown key
> rejects the whole file) and `description` capped at 300 characters.
> The shipped `vibe:create-plugin` skill documents camelCase examples
> (`schemaVersion`, `agentType`, …), which the runtime rejects; a rejected
> agent file is dropped silently (`plugin.agent.invalid` is non-fatal), so
> validate against this note, not the skill doc.
