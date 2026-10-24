# Task: Add the analysis gems to the project Gemfile

Run by the `rubyist` orchestrator once per route, **before** recording the baseline. Because this step runs before the baseline snapshot, its `Gemfile` and `Gemfile.lock` changes are part of the baseline and do not fire scope trigger 3 (protected path).

The phase subagents use three gems from the project bundle:

| Gem | Used by | Commands |
|---|---|---|
| `decode` | implementer (`yardoc` skill), verifier | `bake decode:index:coverage`, `bake decode:index:documentation`, `bake decode:rbs:generate` |
| `bake` | runs the decode tasks | `bundle exec bake ...` |
| `rubydex` | verifier, cleaner, and the rubydex MCP server (registered in `~/.gemini/config/mcp_config.json`; see this port's README) | `rdx lint`, `rdx dead_code`, `rdx query`, `rdx mcp` |

## Steps

1. **Skip when there is no Gemfile.** If the project root has no `Gemfile` (Lite scripts, non-Ruby projects), record `ANALYSIS-GEMS: not applicable: no Gemfile` and stop.

2. **Find the missing gems.** A gem is present when the Gemfile declares it directly:

   ```bash
   missing=()
   for g in decode bake rubydex; do
     grep -qE "^[[:space:]]*gem[[:space:](]+['\"]${g}['\"]" Gemfile || missing+=("$g")
   done
   echo "${missing[@]:-none}"
   ```

   If none are missing, record `ANALYSIS-GEMS: present` and stop.

3. **Save the current files** so a failed install can be undone without touching edits that were already in the tree:

   ```bash
   cp Gemfile "$TMPDIR/Gemfile.pre-analysis"
   [ -f Gemfile.lock ] && cp Gemfile.lock "$TMPDIR/Gemfile.lock.pre-analysis"
   ```

4. **Add the missing gems to the development group and install them:**

   ```bash
   bundle add "${missing[@]}" --group=development
   ```

   `bundle add` writes one `gem "<name>", "~> <version>", group: :development` line per gem, resolves the bundle, and installs it.

5. **On failure, restore and continue.** If `bundle add` exits non-zero (no network, platform without a prebuilt `rubydex` binary, version conflict), copy the saved files back, record `ANALYSIS-GEMS: failed: <first error line>`, and continue the route. Every check that needs a gem that is not installed then reports `not run: <gem> unavailable`.

6. **Record the result** as `ANALYSIS-GEMS: added <gems>` and carry it into the final report, so the user sees that the Gemfile changed.

## Constraints

- Add only `decode`, `bake`, and `rubydex`. Do not change versions of gems already in the Gemfile.
- Do not commit the change.
- The development group keeps the gems out of production bundles (`bundle config set without development`).
