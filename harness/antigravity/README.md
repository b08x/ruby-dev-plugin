# ruby-dev — Google Antigravity CLI (`agy`) Harness Port

This directory contains a complete, self-contained port of `ruby-dev-plugin` for the **Google Antigravity CLI (`agy`)**.

Upstream repository files outside `harness/antigravity/` and other harness ports (such as `harness/mistral-vibe/`) remain completely untouched. This directory holds all harness-specific adapters, subagents, role skills, references, workflow tasks, workspace rules, and validation tooling.

---

## Directory Layout

```text
harness/antigravity/
├── plugin.json               # Antigravity plugin manifest (validated via `agy plugin validate`)
├── README.md                 # This documentation
├── rules/
│   └── AGENTS.md             # Antigravity workspace rules (coding standards, invariants, gates)
├── agents/                   # 6 Antigravity agent definitions:
│   ├── rubyist.md            # Main-thread orchestrator agent (with inlined workflow logic)
│   ├── specifier.md          # Phase 1: Requirements to Gherkin scenarios + QA procedure
│   ├── implementer.md        # Phase 2: Unit tests + code implementation
│   ├── cleaner.md            # Phase 3: Complexity reduction to CRAP threshold
│   ├── hardener.md           # Phase 4: Mutation testing + security scans
│   └── verifier.md           # Phase 5: Dependency checks, Zeitwerk checks, SIFT audit
├── skills/                   # 13 domain skills + 5 role skills (paths rebound to relative):
│   ├── role-specifier/
│   ├── role-implementer/
│   ├── role-cleaner/
│   ├── role-hardener/
│   ├── role-verifier/
│   └── <domain-skills>/      # analyse, data-engineer, genai, gui, multi-db, perf,
│                             # refactor, ruby-nlp, scaffold, sift, tui, yardoc, evals
├── references/               # Shared conventions (dry-rb, quality gates, subagent mandates)
├── tasks/                    # Deterministic workflow tasks (survey, dispatch, gate, synthesize)
└── scripts/
    ├── install.sh            # Global and project-local installer script
    └── validate.sh           # Automated verification test script
```

---

## Installation

The installer `scripts/install.sh` configures the plugin for Antigravity:

### 1. User-Global Installation (Recommended)

Installs the plugin into `~/.gemini/config/plugins/ruby-dev` and copies the `rubyist` orchestrator agent to `~/.gemini/agents/rubyist.md`, making it available across all projects:

```bash
bash harness/antigravity/scripts/install.sh --global
```

To symlink rather than copy (useful during active development):

```bash
bash harness/antigravity/scripts/install.sh --global --symlink
```

### 2. Project-Local Installation

Installs the plugin into `.agents/plugins/ruby-dev` inside the target project workspace:

```bash
bash harness/antigravity/scripts/install.sh --local
```

### Verifying Installation

Verify the plugin is discovered by Antigravity:

```bash
agy plugin list
```

Start the interactive orchestrator:

```bash
agy --agent rubyist
```

---

## Harness Translation Mapping Table

| Claude Code Mechanism | Antigravity CLI (`agy`) Mechanism | Notes |
|---|---|---|
| `.claude-plugin/plugin.json` | `harness/antigravity/plugin.json` | Conforms to Agent Plugins 1.0 schema; passes `agy plugin validate` with 0 errors. |
| `agents/*.md` (with tools allowlist) | `harness/antigravity/agents/*.md` | Frontmatter cleaned of Claude-specific tool lists; uses native `name` and `description`. |
| Subagent Dispatch (Claude Agent tool) | Native `invoke_subagent` tool | Dispatches `specifier`, `implementer`, `cleaner`, `hardener`, `verifier`. Explicit fallback to `define_subagent` if types are unmounted. |
| Orchestrator entry point (`rubyist`) | `agy --agent rubyist` | Installed to `~/.gemini/agents/rubyist.md`. |
| Slash commands (`/ruby-development`, `/ruby-gate`) | Inlined in `rubyist.md` | Survey, dispatch-reconcile, gates, and synthesis are inlined directly into the orchestrator prompt without requiring separate command skills. |
| Claude plugin root path variable | Relative links (`../../references/`, `../skills/`) | Resolves cleanly across both local and global installations. |
| Workspace Rules | `rules/AGENTS.md` | Automatically loaded by Antigravity's hierarchical rule discovery. |
| Gem API lookups (Context7 MCP / DeepWiki) | Context7 MCP / DeepWiki MCP with fallback | Instructs subagents to query MCP tools, falling back to `search_web` or codebase discovery if unmounted. |

---

## Dispatch Workflow & Invariants Preserved

1. **Orchestrator Invariant**: `rubyist` NEVER writes or edits `.rb` files directly. All code edits are delegated to phase subagents via `invoke_subagent`.
2. **Fixed Phase Sequence**: Subagents run strictly in sequence:
   `specifier` → `implementer` → `cleaner` → `hardener` → `verifier`
   (Non-applicable phases are skipped with an explicit rationale in the dispatch plan).
3. **Plan Before Spawning**: The orchestrator outputs a structured dispatch plan before issuing any subagent dispatch.
4. **Pinned Parallel Contracts**: Parallel stages must share a pinned type contract written field-by-field in `CONTRACTS` before dispatch, and results are reconciled before compacting.
5. **Verify, Don't Relay**: Before accepting a subagent's claim (e.g. "all tests pass"), the orchestrator runs the verification check (`bundle exec rspec`, `ruby -c`, etc.) in its own context.
6. **Capped Rollbacks**: A blocking quality gate failure triggers rollback to the target phase, with a hard cap of 2 rollbacks per gate.
7. **Report Compaction**: Every subagent returns a compact `CHANGED` / `FINDINGS` / `UNRESOLVED` / `NEXT` report, keeping orchestrator context lean.

---

## Automated Validation

To run the automated suite verifying plugin validity, link resolution, and zero Claude tokens:

```bash
bash harness/antigravity/scripts/validate.sh
```
