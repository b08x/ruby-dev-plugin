# Harness Architecture — `~/WorkspaceV3/ruby-dev-evals`

A standalone Ruby application. Not a gem, not part of the plugin, not shipped to plugin consumers.

## Layout

```
ruby-dev-evals/
├── README.md                  # how to run, what a score means, what it doesn't
├── .ruby-version              # pinned, recorded in the manifest
├── Gemfile
├── bin/
│   ├── eval                   # run | report | calibrate | validate
│   └── generate_fixtures
├── lib/eval/
│   ├── runner.rb              # orchestrates case × arm × repeat
│   ├── sandbox.rb             # temp workdir, plugin checkout at SHA, teardown
│   ├── session.rb             # the one non-deterministic boundary: spawns `claude -p`
│   ├── transcript.rb          # stream-json → typed events
│   ├── manifest.rb            # build + completeness validation
│   ├── scorers/
│   │   ├── end_state.rb       # Tier 1 orchestration
│   │   ├── artifact.rb        # syntax, boot, rspec, rubocop
│   │   ├── truth.rb           # recall / precision / retention / leakage
│   │   ├── determinism.rb     # classify LLM calls in the produced artifact
│   │   ├── protocol.rb        # Tier 2, over transcript events
│   │   └── judge.rb           # Tier 3 via tribunal
│   ├── telemetry.rb           # OTel → Langfuse, optional
│   └── report.rb              # scores.json → report.md
├── suites/<name>/
│   ├── suite.yml
│   └── cases/<id>/{prompt.md,expect.yml}
├── fixtures/<name>/           # committed corpus + truth sidecars + seed + README
└── results/<run_id>/          # manifest.json, transcripts/, artifacts/, scores.json, report.md
```

House conventions, same as the plugin enforces elsewhere: `# frozen_string_literal: true`, Zeitwerk naming, dry-rb for types and validation, methods private by default, `...` for forwarding. The harness should be an artifact this plugin would approve of — that is a free standing check on the conventions themselves.

## Class responsibilities

| Class | Owns | Must not |
|---|---|---|
| `Sandbox` | temp dir, plugin checkout at SHA, `settings.json` with the plugin enabled/disabled per arm, teardown | leak state between runs, read the working tree |
| `Session` | the subprocess: `claude -p <prompt> --output-format stream-json`, timeout, exit capture | interpret anything |
| `Transcript` | parse stream-json into typed events (`ToolCall`, `Message`, `SubagentSpawn`, `Usage`) | call a model |
| `Manifest` | assemble and validate; raises on incompleteness | be optional |
| `Scorers::*` | pure functions of (artifact tree, truth files, transcript) → scores | mutate anything, retry, or call a model — except `Judge` |
| `Telemetry` | OTel setup, trace IDs into the record | fail a run when export fails |
| `Report` | render `scores.json` into markdown | contain any number not present in `scores.json` |

## Arm setup

The difference between arms is a plugin install, nothing else. Same prompt, same corpus, same model, same sandbox shape.

| Arm | Sandbox config |
|---|---|
| `bare` | no plugin installed |
| `plugin` | plugin checked out at SHA and enabled |
| `direct` | same as `plugin`; the case's `prompt_direct.md` variant names the specialist |

## suite.yml

```yaml
name: phi-parser
model: <explicit model id>
repeat: 3
arms: [bare, plugin]
timeout_seconds: 1800
gates:
  recall: 0.95
  decoy_precision: 0.90
  leakage_hits: 0
judge:
  enabled: true
  gating: false
  model: <different family from the model under test>
  dimensions:
    design: 0.3
    idiom: 0.3
    error_posture: 0.25
    docs: 0.15
```

Everything tunable lives here. No thresholds inline in Ruby.

## Gem wiring

```ruby
# Gemfile
gem "ruby_llm"
gem "ruby_llm-tribunal"
gem "ruby_llm-top_secret"
gem "opentelemetry-instrumentation-ruby_llm"
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "dry-struct"; gem "dry-schema"; gem "dry-monads"

group :test do
  gem "ruby_llm-test"
  gem "rspec"
  gem "rubocop"
end
```

**Telemetry** — optional by construction:

```ruby
OpenTelemetry::SDK.configure { |c| c.use "OpenTelemetry::Instrumentation::RubyLLM" }
```

with OTLP env vars pointed at Langfuse. Tag each judge call so a score is one click from its trace:

```ruby
chat.with_otel_attributes(
  "langfuse.trace.tags" => [suite, case_id, arm],
  "langfuse.trace.name" => "#{suite}/#{case_id}/#{arm}/#{repeat_index}"
)
```

Record the resulting trace ID in the result record. Absent env vars ⇒ run proceeds, report notes tracing was off. An export failure never fails a run.

**PHI safety net** — wrap any judge call that touches fixture content:

```ruby
RubyLLM::TopSecret.with_filtering { judge.evaluate(test_case, assertions) }
```

The corpus is synthetic, so this is belt-and-braces. Keep it anyway: it means a future non-synthetic corpus can't leak through a path nobody re-audited. And never expose the gem to the evaluated session — it would hand over the answer to the challenge.

## The harness has its own tests

Non-negotiable, and the reason `ruby_llm-test` is in the Gemfile: stub LLM responses so harness specs run offline and free.

Minimum spec coverage before any real run:

- `Scorers::Truth` against a hand-written **known-good** artifact tree → passes
- `Scorers::Truth` against a hand-written **deliberately leaky** tree → fails, with the right span named
- `Scorers::Protocol` against a captured transcript with, and without, each gateway field
- `Manifest` rejects every individually-missing field
- `Report` renders a run with an `INVALID` in it without crashing

A scorer that has never failed a known-bad input is not evidence.

## Failure handling

| Condition | Result |
|---|---|
| Session timeout | `INVALID`, recorded with elapsed time |
| Session non-zero exit | `INVALID`, stderr captured |
| Manifest incomplete | `INVALID`, raised before any scoring |
| Artifact tree empty | Tier 1 hard fail (not `INVALID` — the session ran and produced nothing) |
| Judge returns unparseable output | retry once unchanged; still bad ⇒ Tier 3 `UNSCORED`, flagged for human review |
| Telemetry export failure | logged, run unaffected |

Every attempt is recorded, including the ones that failed. `results/<run_id>/` is append-only.
