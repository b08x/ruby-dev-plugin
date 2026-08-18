# ruby-dev-plugin

Claude plugin providing 13 specialist skills + agents for Ruby development workflows. Pure Markdown — no executable code, no build step.

## Project Structure

```
.claude-plugin/plugin.json   — Plugin metadata (name, version, keywords)
agents/                       — 15 agent prompts: the `rubyist` gateway + 14 specialists
skills/                       — 14 specialist skill directories (SKILL.md + references/)
references/                   — shared conventions loaded by skills and agents alike
```

## Conventions

### File Format

- **Skills**: `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) + `references/` subdirectory
- **Agents**: `agents/<name>.md` with YAML frontmatter (`name`, `description`) + pointer to their skill via `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md`
- Agent files are thin wrappers; real logic lives in the skill's SKILL.md. The exception is `agents/rubyist.md`, the gateway: it has no skill, routes rather than implements, and must never load a specialist SKILL.md into its own context.

### Ruby Code Standards (when generating code)

- `# frozen_string_literal: true` on line 1 of every `.rb` file
- Zeitwerk-compliant directory/file naming
- dry-rb ecosystem for type safety: `dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`
- Default new methods to `private`; promote to `public` only for stable interfaces
- Forward undeclared params with `...` (`def foo(...) = bar(...)`)
- Verify non-stdlib gem APIs via Context7 MCP or DeepWiki at point of use — never assume from memory

### Gateway Pattern

`agents/rubyist.md` is the entry point. It is a gateway agent, not a skill: it runs in its own context, plans a dispatch route, and delegates every stage to one of the 14 specialist subagents in `agents/`. When a task spans multiple concerns, or it is unclear which specialist applies, start at `rubyist`. A single-concern task may go straight to its specialist skill.

### Skill Reference Loading

Skills and agents reference shared patterns from `references/` at the plugin root:
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
