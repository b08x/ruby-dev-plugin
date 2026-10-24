# ruby-dev-plugin

Claude plugin providing 1 orchestrator agent, 5 phase subagents, and 13 domain skills for Ruby development workflows. Markdown throughout — no build step; the only script in the plugin's machinery is the `rubydex` MCP launcher, `scripts/rubydex-mcp.sh`; the `harness/` ports carry their own shell scripts.

## Project Structure

```
.claude-plugin/                — plugin.json (plugin metadata, rubydex MCP server) + marketplace.json
agents/                        — 6 agent prompts: the `rubyist` orchestrator + specifier, implementer, cleaner, hardener, verifier
skills/                        — 13 domain skill directories + 5 role skills (`role-*`), each SKILL.md; references/ subdirectories in domain skills except data-engineer
references/                    — shared conventions loaded by skills and agents alike
commands/                      — `/ruby-development` and `/ruby-gate` entry points
tasks/                         — workflow step files the commands drive (step-1-survey-plan, step-2-dispatch-reconcile, gate-check, step-3-gate-synthesize, analysis-gems)
scripts/                       — rubydex-mcp.sh, the rubydex MCP server launcher registered in plugin.json
docs/                          — Workflow_matrix.csv, the extracted workflow-matrix source reference
harness/                       — hand-written ports to other harnesses: `antigravity/` and `mistral-vibe/`
goals/                         — working notes from integration/port sessions (not plugin surface)
```

## Conventions

### File Format

- **Skills**: `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) + `references/` subdirectory where present
- **Agents**: `agents/<name>.md` with YAML frontmatter (`name`, `description`) + pointer to their role skill via `${CLAUDE_PLUGIN_ROOT}/skills/role-<name>/SKILL.md`
- **Role skills**: `skills/role-<name>/SKILL.md` — one per phase subagent; each holds a task-to-skill loading table and the deterministic checks that phase owns. Shared mandates live in `references/subagent-mandates.md`.
- Subagent files are thin wrappers; real logic lives in the role skill and the domain skills it loads. The exception is `agents/rubyist.md`, the orchestrator: it has no skill, routes rather than implements, and must never load a role or domain SKILL.md into its own context.

### Ruby Code Standards (when generating code)

- `# frozen_string_literal: true` on line 1 of every `.rb` file
- Zeitwerk-compliant directory/file naming
- dry-rb ecosystem for type safety: `dry-struct`, `dry-types`, `dry-schema`, `dry-validation`, `dry-monads`
- Default new methods to `private`; promote to `public` only for stable interfaces
- Forward undeclared params with `...` (`def foo(...) = bar(...)`)
- Verify non-stdlib gem APIs via Context7 MCP or DeepWiki at point of use — never assume from memory

### Orchestrator Pattern

`agents/rubyist.md` is the entry point. It is an orchestrator agent, not a skill: it runs in its own context, plans a dispatch route, and delegates every stage to one of 5 phase subagents in `agents/`, in the fixed order specifier → implementer → cleaner → hardener → verifier, skipping stages that do not apply. When a task spans multiple concerns, start at `rubyist`. A single-concern task may go straight to its domain skill.

### Skill Reference Loading

Skills and agents reference shared patterns from `references/` at the plugin root:
- `dry-rb-patterns.md` — Type safety & validation
- `ood-principles.md` — Object-oriented design
- `logging-patterns.md` — Structured logging
- `environment-variables.md` — Env var conventions
- `pry-console.md` — Debugging with Pry
- `rubysmith-scaffolding.md` — Project scaffolding flags
- `quality-gates.md` — Per-phase gate thresholds, rollback targets, escalation triggers
- `subagent-mandates.md` — Shared subagent mandates and report format

### Gem Ecosystem Coverage

Key gems this plugin covers deeply: `tty` (TUI), `dry-rb`, `glimmer-dsl-libui` (GUI), `ruby-llm`, `ohm`, `sequel`, `pgvector`, `rubocop`, `decode`, `rubydex`.

## Forking to Other Harnesses

The plugin is pure Markdown, so forking to another agent harness (mistral-vibe, antigravity, hermes-agent, …) means translating the harness contract, not rewriting content.

**Roadmap direction — harness conversion pipeline.** The hand-written fork procedure below is on its way to being superseded: the plan is a generic converter that takes the base structure and, invoked for a particular harness (Hermes, say), emits that harness's required format. It already exists, implemented and tested in the sibling `python-dev-plugin` repo — `scripts/convert-harness.py`, driven by per-harness adapter TOMLs in `harness-adapters/`, generating committed `harness/<name>/` trees with a `CONVERSION-REPORT.md` and `--check`/`--strict` drift guards (the plan lives in that repo's `goals/python-dev-port/`). The `harness/` trees in this repo are hand-written and predate the converter — its plan cites them as a secondary reference only.

### What ports unchanged

- Skill bodies, domain `references/` files, role-skill task-to-skill loading tables
- Shared conventions in `references/` and the Ruby Code Standards section above
- Prose in `tasks/*.md` and `commands/*.md` (mechanics get re-bound; the workflow text is portable)

### What must be re-mapped per harness

1. **Agent registration** — `.claude-plugin/plugin.json` → the target's manifest/registration mechanism. Some harnesses discover agents by directory convention; others require explicit config.
2. **Frontmatter schema** — `name`/`description` are near-universal; Claude-specific keys (`tools:` allowlist) must be translated or dropped. Never leave a key the target reads with different semantics.
3. **Path variable** — `${CLAUDE_PLUGIN_ROOT}` → the target's equivalent; rewrite every occurrence in agent files.
4. **Dispatch mechanics** — the orchestrator depends on spawning named subagents from the main thread. If the target cannot nested-dispatch, collapse the pipeline into one agent whose prompt carries the five phases sequentially, and delete the subagent files.
5. **Tool gating** — map the `Agent(...)` allowlist plus Read/Grep/Glob/Bash to the target's permission model, preserving the invariant that the orchestrator never edits `.rb` files.
6. **Commands** — `/ruby-development` and `/ruby-gate` → the target's command/slash-command mechanism, or inline them into the orchestrator prompt.

### Fork procedure

1. Copy the repo; delete `.claude-plugin/`.
2. Verify the target's contract for agents, skills, path variables, and subagent dispatch — check the target's docs, do not assume.
3. Translate the thin agent wrappers first, then role skills, then the orchestrator.
4. Grep the result for unported coupling: `${CLAUDE_PLUGIN_ROOT`, `claude --agent`, `/ruby-`, `Agent(`, `SKILL.md` frontmatter keys unique to Claude. Any survivor is untranslated harness coupling.
5. Re-verify the invariants: orchestrator never writes Ruby; each phase loads its own role skill; fixed phase order specifier → implementer → cleaner → hardener → verifier; verify-don't-relay.
6. Keep the fork content-identical to upstream where possible so merges stay clean; isolate harness-specific deltas in one directory (e.g. `harness/<name>/`) instead of forking shared Markdown.

### Per-harness notes

- **mistral-vibe** — ported; see `harness/mistral-vibe/`. Vibe declares subagents as TOML profiles under `ai.mistral.vibe/agents/`, so the pipeline was not collapsed; the `rubyist` orchestrator installs as a user agent profile (`agents/rubyist.toml` + `prompts/rubyist.md`, run with `vibe --agent rubyist`), and the two commands are ported as skills.
- **antigravity** — ported; see `harness/antigravity/`. Agents stay as Markdown under `agents/`; the port adds `rules/AGENTS.md` plus `scripts/install.sh` and `scripts/validate.sh`.
- **hermes-agent** — skills are in-repo `SKILL.md` with frontmatter plus a validator; run the validator after translation and expect stricter frontmatter than Claude's. The realized shape (per the converter in the `python-dev-plugin` sibling repo) is a profile distribution: `distribution.yaml`, a `SOUL.md` orchestrator prompt, `config.yaml` with delegation settings, and one `phase-<name>` skill per phase agent.

## Gotchas

- No tests or CI — this is a prompt-only plugin. Validate changes by reading the Markdown for coherence.
- Agent files use `${CLAUDE_PLUGIN_ROOT}` as the path variable, not relative paths.
- The `tui/` skill has 21 reference files for `tty-*` gems — the most top-level references of any skill; `genai/` has 74 in total, nested under `dspy-ruby/` and `ruby-llm/`.
- Skills cross-reference each other via relative Markdown links (e.g., `../refactor/SKILL.md`).
