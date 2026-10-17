# Subagent Mandates

Shared by the five phase subagents (`specifier`, `implementer`, `cleaner`, `hardener`, `verifier`). Each subagent file links here instead of repeating this text.

## Core mandates

These apply to every task, regardless of what a skill file says:

1. **Functional-first delivery.** Technical precision and functional correctness. Do not adopt a conversational persona or narrate your process.
2. **Inline gem verification.** When a task touches a non-stdlib gem, query Context7 MCP (or DeepWiki for the gem's GitHub repo) for the API signature at the point of use. Never assume a gem API from memory. (The `verifier` has no MCP tools; it checks gem usage against the code and tests it reads and reports unverified APIs under `FINDINGS`.)
3. **Type safety and error handling.** For complex logic, use `dry-struct` typing and `dry-monads` (Success/Failure) rather than raw Hashes and bare rescues — see `dry-rb-patterns.md`. Scripts under ~50 lines may stay standard-library only (Lite Mode).
4. **Convention locking.** RuboCop/StandardRB compliant, `# frozen_string_literal: true` on the first line of every `.rb` file, Zeitwerk-compliant paths that match class names exactly.
5. **Method visibility and naming discipline.** Default new methods to `private`; promote to `public` only when the method is a deliberate, stable part of the object's interface. Scale name length inversely with call frequency — short names for constantly-called methods, descriptive names for rare setup and configuration. Pure delegation forwards with `...` (`def foo(...) = bar(...)`) rather than re-declaring parameters.
6. **Verify before reporting.** Check syntax with `ruby -c` on every `.rb` file you touched, and run the deterministic check your role owns (see the role skill).
7. **Stay inside the brief.** Change only the paths and concerns named in `TASK` and `PATHS`. Report anything else you notice under `FINDINGS`; do not fix it. A brief that is narrow bounds what you were asked to do, not what you may do, so the limit is yours to hold. The orchestrator verifies this with a scope check after your report.

Shared conventions live in this plugin's `references/` directory: `dry-rb-patterns.md`, `logging-patterns.md`, `environment-variables.md`, `ood-principles.md`, `rubysmith-scaffolding.md`, `pry-console.md`, `quality-gates.md`.

## Reporting back

Subagents run in an isolated context, dispatched by the `rubyist` orchestrator. Return a compact structured report, not a transcript:

```
CHANGED: <file paths, or "none">
FINDINGS: <what you determined, 2-5 bullets>
UNRESOLVED: <what you could not do, and why — or "none">
NEXT: <what the next stage must know — or "none">
```

State your gate name and the measured value in `FINDINGS`. Gate thresholds are in `quality-gates.md`.

Keep the report short enough that the orchestrator can pass it forward without re-summarizing it. Detail belongs in the files you changed, not in the report.
