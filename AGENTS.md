# ruby-dev-plugin

Claude plugin providing 13 specialist skills + agents for Ruby development workflows. Pure Markdown — no executable code, no build step.

## Project Structure

```
.claude-plugin/plugin.json   — Plugin metadata (name, version, keywords)
agents/                       — 13 role-specific agent prompts (.md files)
skills/                       — 14 skill directories (SKILL.md + references/)
```

## Conventions

### File Format

- **Skills**: `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) + `references/` subdirectory
- **Agents**: `agents/<name>.md` with YAML frontmatter (`name`, `description`) + pointer to their skill via `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md`
- Agent files are thin wrappers; real logic lives in the skill's SKILL.md

### Ruby Code Standards (when generating code)

- `# frozen_string_literal: true` on line 1 of every `.rb` file
- Zeitwerk-compliant directory/file naming
- dry-rb ecosystem for type safety: `dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`
- Default new methods to `private`; promote to `public` only for stable interfaces
- Forward undeclared params with `...` (`def foo(...) = bar(...)`)
- Verify non-stdlib gem APIs via Context7 MCP or DeepWiki at point of use — never assume from memory

### Orchestrator Pattern

`ruby-dev/SKILL.md` is the entry point. It dispatches to 13 specialist skills based on task type. When a task spans multiple concerns, start with the orchestrator rather than a single specialist.

### Skill Reference Loading

Skills reference shared patterns from `skills/ruby-dev/references/`:
- `dry-rb-patterns.md` — Type safety & validation
- `ood-principles.md` — Object-oriented design
- `logging-patterns.md` — Structured logging
- `environment-variables.md` — Env var conventions
- `pry-console.md` — Debugging with Pry
- `rubysmith-scaffolding.md` — Project scaffolding flags

### Gem Ecosystem Coverage

Key gems this plugin covers deeply: `tty` (TUI), `dry-rb`, `glimmer-dsl-libui` (GUI), `ruby-llm`, `ohm`, `sequel`, `pgvector`, `rubocop`, `yard`.

## Gotchas

- No tests or CI — this is a prompt-only plugin. Validate changes by reading the Markdown for coherence.
- Agent files use `${CLAUDE_PLUGIN_ROOT}` as the path variable, not relative paths.
- The `tui/` skill has 21 reference files for `tty-*` gems — the largest skill by reference count.
- Skills cross-reference each other via relative Markdown links (e.g., `../refactor/SKILL.md`).
