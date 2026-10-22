# Quality Gates

Single source of truth for gate thresholds, rollback routes, and escalation triggers. Phase skills cite their row here. `tasks/gate-check.md` runs a row. The orchestrator (`rubyist` or `/ruby-development`) executes rollback; phase agents never choose the route.

## Gates

| Phase | Gate command | Threshold | Mode | Rollback target |
|---|---|---|---|---|
| specifier | Read `features/*.feature` and `features/qa-procedure.md` | STRIDE misuse scenarios present: one Gherkin scenario per trust-boundary crossing | blocking | specifier |
| implementer | `bundle exec rspec` (or `bundle exec rake test`); `bundle exec cucumber` when `features/` exists; `gitleaks detect --no-git --source <PATHS>`; CC per method via `bundle exec rubocop --only Metrics/CyclomaticComplexity --format json` with `Max: 1` in a temporary config | Suite green; gitleaks zero findings; CC <= 4 per method | suite and gitleaks blocking; CC report-only | implementer |
| cleaner | `bundle exec rspec` with SimpleCov; CRAP per method (formula in `skills/role-cleaner/SKILL.md`); CC per method | CRAP <= 6 (<= 8 only when the brief states it); CC <= 6 per method; any method with CRAP > 30 escalates to the user | blocking | implementer |
| hardener | `bundle exec mutant run --use rspec -- '<Namespace>*'`; `bundle exec bundler-audit check --update`; `bundle exec brakeman -q --no-pager` (Rails projects only) | Zero unexplained mutant survivors (each equivalent mutant justified in `FINDINGS`); zero high or critical findings from bundler-audit and brakeman (a bundler-audit advisory with no stated criticality counts as high) | blocking | implementer |
| verifier | `bundle exec packwerk check` (Rails projects only); Zeitwerk eager-load check (`bin/rails zeitwerk:check` for Rails; otherwise `bundle exec ruby -Ilib -e 'require "<entrypoint>"; Zeitwerk::Loader.eager_load_all'`, where `<entrypoint>` is the require path of the gemspec, else `lib/<project name>.rb`, else the file the brief names); acceptance tests. The SIFT audit and verdict are not run by the gate: they come from the verifier subagent's report, which the orchestrator passes to the gate | Zero errors from packwerk and Zeitwerk; zero cucumber failures. The Zeitwerk check is attempted on every project: it is `not applicable: project does not use Zeitwerk` when the Gemfile, Gemfile.lock and gemspec all lack `zeitwerk` and the project is not Rails, and `not run: zeitwerk unavailable` when the project declares it but the gem is not installed; no Critical or High SIFT finding and verdict not NO-GO, read from the verifier's report | blocking | implementer |

## Rollback

1. On a blocking failure, the orchestrator re-dispatches the phase named in "Rollback target" with the failure (command, measured value, failing row) as the new `TASK`.
2. After the re-dispatch, the orchestrator runs the scope check, then re-runs the gate.
3. Cap: at most 2 rollbacks per gate. After the second, the orchestrator stops dispatching, shows the failing row and measured values, and asks the user.
4. A rollback to the implementer re-runs every later phase in the route, because the route is linear.
5. If the rollback target is not in the route (for example Fix: cleaner → verifier has no implementer), the orchestrator does not add a phase; it stops and asks the user.
6. A report-only result is recorded in `FINDINGS` and never triggers a rollback.

## Escalation triggers

The orchestrator compares the working tree to the pre-dispatch baseline after every stage, before the stage's gate runs. Any one trigger stops the run:

1. A changed file lies outside `PATHS`.
2. A test file was deleted, or a `skip`, `pending`, `xit`, or `xdescribe` was added.
3. A protected path changed and is not listed in `PATHS`: `*.gemspec`, `Gemfile`, `Gemfile.lock`, `db/schema.rb`, `db/migrate/`, or an authentication or session path.
4. The count of changed files exceeds max(5, 2 x files in `PATHS`).

Baseline: before the first dispatch, record `git rev-parse HEAD` and a content-hash snapshot of every modified, deleted, or untracked file. The tree may already be dirty, so a status listing alone would miss a further edit to a file that was already modified. The snapshot includes staged paths (`git diff --cached --name-only`), because a staged deletion (`git rm`) does not appear in `git ls-files -d`.

```bash
snapshot() {
  { git ls-files -m -o -d --exclude-standard; git diff --cached --name-only; } | sort -u | grep -Ev '^(coverage|tmp|log|\.bundle)/' | while IFS= read -r f; do
    if [ -e "$f" ]; then printf '%s\t%s\n' "$f" "$(git hash-object -- "$f")"; else printf '%s\tdeleted\n' "$f"; fi
  done
}
snapshot > "$BASELINE_SNAPSHOT"   # once, before the first dispatch
```

Procedure: after a stage, run `snapshot` again. The changed set is every path whose hash differs from, or is absent in, the baseline snapshot (`join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,2.2 baseline now | awk -F'\t' '$2!=$3{print $1}'`). A path whose new hash is `deleted` and that lies under `spec/`, `test/`, or `features/` fires trigger 2. For trigger 2's skip scan, search the added lines of `git diff <baseline-hash> -U0` for `\b(skip|pending|xit|xdescribe)\b`, and search each untracked changed file in full. A match in a file that was already dirty before dispatch may predate the stage; show it to the user rather than discarding it. A `PATHS` entry that is a directory covers every file under it. Tool-artifact directories (`coverage/`, `tmp/`, `log/`, `.bundle/`) are filtered out of the snapshot itself, so they never fire triggers 1 or 4. A path that was dirty at baseline and is clean now has been reverted by the stage; it counts as changed, because the stage altered a pre-existing edit. For the skip scan, a match that is not an RSpec or Minitest skip (for example SimpleCov's `skip` filter DSL) is shown to the user as a probable false positive, not counted as a trigger, and the run continues. A skip match in a file that was already dirty before dispatch is likewise shown to the user and does not stop the run.

A trigger stop shows the user the diff stat and the trigger that fired. It does not count against the 2-rollback cap. The cleaner gate's CRAP > 30 escalation is handled the same way.

## Missing tools

When a gate command's tool is not installed, record `not run: <tool> unavailable`. A gate with a `not run` entry does not pass. Its result is `GATE: fail (not run)`, which does not trigger a rollback, because re-dispatching a phase cannot install a tool. The orchestrator continues the route, and the route closes as "done with NOT-RUN gates": the final summary lists every gate that did not run.

A command that does not apply to the project (packwerk outside Rails, cucumber without `features/`, brakeman outside Rails, Zeitwerk in a project whose Gemfile, Gemfile.lock and gemspec lack `zeitwerk`) is recorded as `not applicable: <reason>`. It is neither a pass nor a failure and never blocks. A gate whose every command is not applicable reports `GATE: pass`. For Lite or docs-only work with no test runner, the implementer row's suite command is replaced by `ruby -c` on every touched file.
