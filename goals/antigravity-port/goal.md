# Goal: Adapt ruby-dev-plugin for Antigravity CLI (agy)

Port the `ruby-dev-plugin` to Google Antigravity CLI (`agy`) as an isolated, self-contained harness package in `harness/antigravity/` without altering upstream Claude Code root files or `harness/mistral-vibe/`. Provide an Antigravity plugin manifest (`plugin.json`), 5 phase subagents (`specifier`, `implementer`, `cleaner`, `hardener`, `verifier`), an inlined workflow orchestrator (`rubyist`), relative skill/reference links, Antigravity workspace rules (`rules/AGENTS.md`), and automated validation and installation scripts.

- Shared understanding: [facts.md](facts.md) (13 facts; metadata in [facts.meta.json](facts.meta.json))
- Execution plan: [plan.md](plan.md) (8 ordered steps with concrete verification checks)

## Done condition

- All 13 facts in `facts.md` hold and pass automated verification.
- `agy plugin validate harness/antigravity` passes with 0 errors.
- `harness/antigravity/scripts/validate.sh` runs cleanly and reports 0 untranslated Claude tokens (`${CLAUDE_PLUGIN_ROOT}`, `claude --agent`, `Agent(`).
- `git status --porcelain` shows modifications only within `goals/antigravity-port/` and `harness/antigravity/`.
