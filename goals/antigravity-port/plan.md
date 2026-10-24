# Plan — Adapt ruby-dev-plugin for Antigravity CLI (agy)

Inputs: `facts.md` (13 facts, F1–F13) and `interview-result.json`.

## Solution Approach

Port the `ruby-dev-plugin` to Google Antigravity CLI (`agy`) as an isolated, self-contained harness directory at `harness/antigravity/`, keeping upstream repository root files and `harness/mistral-vibe/` untouched.

The Antigravity port uses native Antigravity plugin conventions:
1. Manifest `plugin.json` declaring the plugin metadata (`name: "ruby-dev"`), passing `agy plugin validate`.
2. Agent definitions in `agents/`: 5 phase subagents (`specifier`, `implementer`, `cleaner`, `hardener`, `verifier`) plus the main-thread orchestrator `rubyist`.
3. Inlined workflow logic: As requested in the interview, the multi-step development and gating logic (previously in `commands/`) is inlined directly into `rubyist.md` rather than exposing separate command skills.
4. Hybrid dispatch: `rubyist` dispatches phases using Antigravity's native `invoke_subagent` tool, with an explicit instruction fallback to `define_subagent` if running in an environment without pre-registered subagent types.
5. Path independence: Upstream `${CLAUDE_PLUGIN_ROOT}` tokens are replaced with relative Markdown links (`../../references/`, `../role-<name>/SKILL.md`) and runtime plugin-root guidance.
6. Verification tooling: An automated `scripts/validate.sh` checks plugin validity, verifies link integrity, and ensures 0 untranslated Claude tokens. An installer `scripts/install.sh` enables both global (`~/.gemini/config/plugins/ruby-dev`) and project-local (`.agents/plugins/ruby-dev`) installation, plus linking `rubyist.md` to `~/.gemini/agents/`.

---

## Ordered Steps

### 1. Directory Structure & Plugin Manifest (`harness/antigravity/plugin.json`)
- Create directory structure:
  - `harness/antigravity/agents/`
  - `harness/antigravity/skills/`
  - `harness/antigravity/references/`
  - `harness/antigravity/tasks/`
  - `harness/antigravity/rules/`
  - `harness/antigravity/scripts/`
- Create `harness/antigravity/plugin.json` with valid manifest JSON (`name: "ruby-dev"`, `version: "5.0.1"`, `description`).
- **Covers**: F1, F2.
- **Verification**: `agy plugin validate harness/antigravity` runs cleanly.

### 2. Shared Skills & References Port
- Mirror the 13 domain skills from upstream `skills/` to `harness/antigravity/skills/`.
- Mirror the 5 role skills (`skills/role-*/SKILL.md`) to `harness/antigravity/skills/role-*/SKILL.md`.
- Mirror shared conventions from `references/` to `harness/antigravity/references/`.
- Rebind all `${CLAUDE_PLUGIN_ROOT}` occurrences to relative paths (`../../references/...`, `../role-.../SKILL.md`) and plugin-root instructions.
- Update non-stdlib gem API verification guidance in `subagent-mandates.md` and role skills to specify Context7 / DeepWiki MCP with fallback to `search_web` or codebase discovery.
- **Covers**: F7, F8, F9.
- **Verification**: `grep -rn '\${CLAUDE_PLUGIN_ROOT}' harness/antigravity/skills harness/antigravity/references` returns 0 matches.

### 3. Phase Subagent Definitions (`harness/antigravity/agents/`)
- Create `harness/antigravity/agents/`:
  - `specifier.md`: Phase 1 requirements to Gherkin scenarios + QA procedure, loads `skills/role-specifier/SKILL.md`.
  - `implementer.md`: Phase 2 unit tests + code, loads `skills/role-implementer/SKILL.md`.
  - `cleaner.md`: Phase 3 refactoring to CRAP gate, loads `skills/role-cleaner/SKILL.md`.
  - `hardener.md`: Phase 4 mutation testing + security scans, loads `skills/role-hardener/SKILL.md`.
  - `verifier.md`: Phase 5 dependency checker + SIFT audit + Zeitwerk check, loads `skills/role-verifier/SKILL.md`.
- Ensure each agent has YAML frontmatter with `name` and `description`, removes Claude-specific `tools: Agent(...)` syntax, and points to its role skill using relative and plugin-root paths.
- **Covers**: F3, F7, F8.
- **Verification**: Verify YAML frontmatter parses on all 5 subagents; grep for Claude tokens returns 0 matches.

### 4. Orchestrator Agent (`harness/antigravity/agents/rubyist.md`)
- Author `harness/antigravity/agents/rubyist.md` with YAML frontmatter (`name: rubyist`, `description`).
- Inline workflow execution logic (survey, emit dispatch plan, dispatch-reconcile, quality gates, synthesis from `tasks/` and previous `commands/ruby-development.md`).
- Enforce the core invariant that `rubyist` NEVER writes or edits `.rb` files directly.
- Implement hybrid dispatch instructions:
  - Primary dispatch using `invoke_subagent(TypeName="specifier|implementer|cleaner|hardener|verifier", Role=..., Prompt=...)`.
  - Graceful fallback using `define_subagent` if the subagent type is not pre-registered in the current session.
- Rebind all references to relative paths (`../references/quality-gates.md`, `../tasks/gate-check.md`, etc.).
- **Covers**: F3, F4, F5, F6, F8.
- **Verification**: Check `rubyist.md` contains no Claude-specific tokens (`${CLAUDE_PLUGIN_ROOT}`, `claude --agent`, `Agent(`), contains explicit invariant against writing Ruby, and contains `invoke_subagent` dispatch specifications.

### 5. Tasks and Workspace Rules (`harness/antigravity/tasks/` & `rules/AGENTS.md`)
- Copy workflow tasks (`gate-check.md`, `step-1-survey-plan.md`, `step-2-dispatch-reconcile.md`, `step-3-gate-synthesize.md`) into `harness/antigravity/tasks/`, replacing `${CLAUDE_PLUGIN_ROOT}` with relative paths to `references/quality-gates.md`.
- Create `harness/antigravity/rules/AGENTS.md` containing workspace guidelines for Antigravity sessions:
  - Ruby coding standards (`# frozen_string_literal: true`, Zeitwerk conventions, dry-rb patterns, private visibility default).
  - Orchestrator invariants and quality gate thresholds table.
  - Subagent report contract (`CHANGED`, `FINDINGS`, `UNRESOLVED`, `NEXT`).
- **Covers**: F8, F10.
- **Verification**: Verify `harness/antigravity/rules/AGENTS.md` exists and contains rule sections; verify all task files have 0 Claude tokens.

### 6. Installation & Automated Validation Tooling
- Create `harness/antigravity/scripts/install.sh`:
  - Flags for `--global` (installs to `~/.gemini/config/plugins/ruby-dev` and copies `rubyist.md` to `~/.gemini/agents/`) and `--local` (installs to `.agents/plugins/ruby-dev`).
  - Supports `--symlink` or copy/rsync.
  - Executable permissions (`chmod +x`).
- Create `harness/antigravity/scripts/validate.sh`:
  - Runs `agy plugin validate harness/antigravity`.
  - Runs grep check ensuring 0 Claude tokens (`${CLAUDE_PLUGIN_ROOT}`, `claude --agent`, `Agent(`) in `harness/antigravity/`.
  - Validates that internal file references in agents and role skills exist on disk.
  - Returns exit code 0 on success.
- **Covers**: F8, F11, F13.
- **Verification**: Run `bash harness/antigravity/scripts/validate.sh` and ensure it exits with code 0.

### 7. Port Documentation (`harness/antigravity/README.md`)
- Write comprehensive `harness/antigravity/README.md`:
  - Purpose and architecture of the Antigravity port.
  - Directory structure.
  - Installation instructions (global via `scripts/install.sh --global`, local via `scripts/install.sh --local`).
  - Harness translation mapping table (Claude Code vs Antigravity mechanisms).
  - Preserved invariants and usage workflows (`agy --agent rubyist`).
- **Covers**: F1, F12.
- **Verification**: `test -f harness/antigravity/README.md` and check all sections present.

### 8. End-to-End Goal Verification
- Run `agy plugin validate harness/antigravity` directly.
- Run `harness/antigravity/scripts/validate.sh`.
- Confirm repository root files and `harness/mistral-vibe/` have zero git modifications (`git status --porcelain` shows only `goals/` and `harness/antigravity/`).
- **Covers**: F1–F13.

---

## Risks and Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Plugin agent discovery variance across Antigravity CLI versions | `agy` might look for agent files in `~/.gemini/agents/` rather than only within the plugin `agents/` directory | Provide `scripts/install.sh` which copies `rubyist.md` into `~/.gemini/agents/` as well as registering the plugin, and specify fallback `define_subagent` instructions in `rubyist.md`. |
| Broken relative links between subagents and role skills | Phase subagents cannot locate their operational checklists | Use consistent relative paths (`../skills/role-<name>/SKILL.md`) and validate all links in `scripts/validate.sh`. |
| Dirty git status affecting upstream merge tracking | Modifications to upstream files break clean pull/merge | Enforce strict isolation: all created files must reside under `harness/antigravity/` and `goals/antigravity-port/`. |
