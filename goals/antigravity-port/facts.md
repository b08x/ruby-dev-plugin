# Facts

- harness/antigravity/ contains the complete self-contained Antigravity harness port, while the repository root files and harness/mistral-vibe/ remain untouched.
- harness/antigravity/plugin.json is a valid Antigravity plugin manifest defining ruby-dev metadata that passes `agy plugin validate harness/antigravity` with 0 errors.
- harness/antigravity/agents/ defines the 5 phase subagents (specifier.md, implementer.md, cleaner.md, hardener.md, verifier.md) and the rubyist.md orchestrator with valid YAML frontmatter (name and description).
- harness/antigravity/agents/rubyist.md inlines the workflow execution logic (survey, dispatch-reconcile, quality gates, and synthesis previously in commands/ruby-development.md and commands/ruby-gate.md) with no separate command skills.
- harness/antigravity/agents/rubyist.md enforces the core invariant that the orchestrator never writes or edits .rb files directly, routing all code modifications to phase subagents.
- harness/antigravity/agents/rubyist.md specifies hybrid dispatch: invoking phase subagents via `invoke_subagent` (specifier, implementer, cleaner, hardener, verifier), with explicit fallback to `define_subagent` if subagent types are unmounted.
- harness/antigravity/skills/ contains the 13 domain skills and 5 role skills, and harness/antigravity/references/ contains shared conventions, using relative Markdown links and runtime plugin-root resolution instructions.
- Zero occurrences of untranslated Claude Code coupling tokens (${CLAUDE_PLUGIN_ROOT}, claude --agent, or Agent() exist in harness/antigravity/.
- Non-stdlib gem API verification instructions specify checking Context7 MCP or DeepWiki MCP, with graceful fallback to search_web or codebase discovery if MCP tools are unavailable.
- harness/antigravity/rules/AGENTS.md defines Antigravity workspace rules covering Ruby coding standards, quality gate thresholds, and subagent operational constraints.
- harness/antigravity/scripts/install.sh supports installing the plugin both user-globally (~/.gemini/config/plugins/ruby-dev) and project-locally (.agents/plugins/ruby-dev), and installs rubyist.md into ~/.gemini/agents/ for `agy --agent rubyist`.
- harness/antigravity/README.md provides full documentation of the port layout, harness translation mapping table, installation options, dispatch workflow, and preserved invariants.
- An automated check script harness/antigravity/scripts/validate.sh verifies `agy plugin validate` passes with 0 errors, confirms 0 Claude tokens remain, and verifies internal link paths.
