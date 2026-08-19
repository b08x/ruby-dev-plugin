# Gem Whitelist — Gemsets & Decision Guide

The approved-gem registry for this plugin's `references/Gemfile` (89 gems, machine-classified
in `references/Gemfile.json`). Not exhaustive — a curated starting point, grown deliberately
rather than by whatever `bundle add` turns up. "Gemset" borrows RVM's term: a named cluster of
gems solving the same problem, so picking a member is a decision you can name and swap later.

Machine-readable form: [`gemsets.yaml`](gemsets.yaml) — same clusters and decision rules as
structured data, for tooling (archetype presets, future semantic gem lookup) to consume without
parsing this file.

## Contents

- [Section 1: Gemset Table](#section-1-gemset-table)
- [Section 2: Decision Rules — Overlapping Gemsets](#section-2-decision-rules--overlapping-gemsets)
- [Section 3: Gaps — Whitelisted but Unowned](#section-3-gaps--whitelisted-but-unowned)

---

## Section 1: Gemset Table

`status`: **owned** — a skill in `skills/` has deep usage guidance. **shared** — foundational,
referenced by many skills rather than owned by one. **gap** — vetted and whitelisted, no skill
owns it yet; verify APIs manually via Context7/DeepWiki per the plugin's standing mandate.

| Gemset | Gems | Owning skill | Status |
|---|---|---|---|
| `llm_client_rubyllm` | ruby_llm, ruby_llm-mcp, ruby_llm-docker, schematist, shared_tools | [ruby-llm](../ruby-llm/SKILL.md) | owned |
| `llm_programs_dspy` | dspy, dspy-openai, dspy-gemini, dspy-ruby_llm, dspy-code_act, dspy-evals, dspy-gepa, dspy-o11y-langfuse, dspy-schema | [dspy-ruby](../dspy-ruby/SKILL.md) | owned |
| `document_intake` | kreuzberg, inkmark, mimemagic | — | **gap** |
| `tokenization_segmentation` | pragmatic_segmenter, pragmatic_tokenizer | [ruby-nlp](../ruby-nlp/SKILL.md) | owned |
| `linguistic_structure` | lingua, ruby-spacy, pycall | [ruby-nlp](../ruby-nlp/SKILL.md) | owned |
| `fuzzy_similarity_ranking` | amatch, bm25f, tf-idf-similarity, pg_search | [ruby-nlp](../ruby-nlp/SKILL.md) | owned |
| `topic_modeling_and_inference` | tomoto, informers, hugging-face | [ruby-nlp](../ruby-nlp/SKILL.md) | owned |
| `vector_storage_retrieval` | pgvector, neighbor | [genai](../genai/SKILL.md) | owned |
| `relational_storage` | sequel, sequel_pg, pg | [multi-db](../multi-db/SKILL.md) | owned |
| `redis_object_storage` | ohm, ohm-contrib, ohm-sorted | [multi-db](../multi-db/SKILL.md) | owned |
| `async_runtime` | async, async-cable, async-http, async-job, async-service, falcon, concurrent-ruby, parallel | — | **gap** |
| `dry_rb_types` | dry-struct, dry-types, dry-schema, dry-monads, dry-container | [references/dry-rb-patterns.md](../../../references/dry-rb-patterns.md) | shared |
| `autoloading_and_boot` | zeitwerk | [scaffold](../SKILL.md) | owned |
| `cli_toolkit` | tty-command, tty-config, tty-editor, tty-file, tty-which | [tui](../../tui/SKILL.md) | owned |
| `code_quality_static_analysis` | rubocop, rubocop-ast, rubocop-md, rubocop-rake, rubocop-sequel, syntax_tree, decode | [refactor](../../refactor/SKILL.md) | owned |
| `process_shell_utilities` | childprocess, open4, terrapin, daemons, os | — | **gap** |
| `workflow_orchestration` | gush, jongleur | — | **gap** |
| `media_image_processing` | image_processing, ruby-vips | — | **gap** |
| `media_subtitle_caption` | srt, webvtt | — | **gap** |
| `structured_data_encoding` | jsonl, yajl-ruby | — | **gap** |
| `resilience_and_observability` | circuit_breaker, journald-logger, dotenv | [logging-patterns.md](../../../references/logging-patterns.md), [environment-variables.md](../../../references/environment-variables.md) | shared |
| `dev_ergonomics` | pry, listen, refinements, faker, chronic | [pry-console.md](../../../references/pry-console.md) (partial) | shared |
| `algorithms_datastructures` | algorithms | — | **gap** |
| `security_crypto_support` | bcrypt_pbkdf | — | **gap** |
| `browser_automation_testing` | selenium-webdriver | — | **gap** |
| `creative_coding_signal` | osc-ruby | — | **gap** |
| `meta_plugin_tooling` | gem-skill | — | **gap** |

---

## Section 2: Decision Rules — Overlapping Gemsets

### kreuzberg vs inkmark

**Problem**: two gems both touch document text, and picking the wrong one either fails on the
input format or drags in a much heavier dependency than the task needs.

**Rule**: use **kreuzberg** when the input format is unknown or non-Markdown — PDF, DOCX, PPTX,
XLSX, HTML, RTF, images needing OCR, email, archives (75+ formats via a Rust core with native
Ruby bindings). It also does chunking, language detection, and keyword extraction, so it can be
the entire intake step, not just extraction. Use **inkmark** only when the input is already
CommonMark/GFM Markdown text and the task is fast, correct parsing — it does not extract from
binary formats. Run **mimemagic** first when the format isn't known ahead of time, to route the
file to whichever of the two actually handles it.

```ruby
# Route by detected type before touching content
mime = MimeMagic.by_magic(File.open(path))

case mime&.subtype
when "markdown"
  Inkmark.parse(File.read(path))
else
  Kreuzberg.extract(path) # PDF, DOCX, images, everything else
end
```

No skill in this plugin currently owns document intake (see [Section 3](#section-3-gaps--whitelisted-but-unowned)).

### ruby_llm vs dspy.rb

**Problem**: both are "the LLM gem," and the plugin already has two skills that each redirect to
the other rather than compete — this entry exists so that redirect is discoverable from the
gemset registry, not just from inside each skill.

**Rule**: use **ruby_llm** for direct, imperative LLM calls — chat, tool calling, RAG glue,
streaming — when the prompt logic is hand-written and owned by the caller. Use **dspy.rb** when
the task should be a typed signature that a compiler/optimizer (MIPROv2, GEPA) can rewrite,
rather than a prompt string tuned by hand. `dspy-ruby_llm` bridges the two: dspy programs running
on a configured `ruby_llm` client, so they compose rather than compete.

Full detail lives in [ruby-llm/SKILL.md](../ruby-llm/SKILL.md)'s and
[dspy-ruby/SKILL.md](../dspy-ruby/SKILL.md)'s own "Don't use for" sections — read this rule as a
pointer, not a replacement.

### ohm vs sequel (+ pg)

**Problem**: two storage layers are both whitelisted, and neither is a default — the choice is
architectural.

**Rule**: Redis (**ohm**) is the source of truth for state-machine-shaped, ephemeral, fast-write
data. Postgres (**sequel**, + `pgvector` for embeddings) is the source of truth for durable,
queryable, joined data. If a project needs both, join by a shared application-level id — never
an ORM relation across the two stores.

Fully covered in [multi-db/SKILL.md](../../multi-db/SKILL.md) — see "Picking Between Ohm and
Sequel" there for the worked model examples; this entry is a pointer.

### Keyword-relevance family: pg_search vs bm25f/tf-idf-similarity vs pgvector/neighbor

**Problem**: four gems all answer "how relevant is this text to this query," but they compute
relevance in different places and by different means.

**Rule**: **pg_search** when the corpus already lives in Postgres and the database should do the
ranking (native full-text search). **bm25f** / **tf-idf-similarity** when ranking must happen
in-process — no DB round trip, or the corpus isn't in Postgres at all. **pgvector** + **neighbor**
when the match is semantic (embedding-space), not lexical. A hybrid retriever typically runs one
keyword arm (`pg_search`, or `bm25f`/`tf-idf-similarity`) alongside one semantic arm
(`pgvector`/`neighbor`) and merges with Reciprocal Rank Fusion — see
[genai/SKILL.md](../../genai/SKILL.md)'s RRF pattern for the merge itself.

### Local vs hosted inference: informers vs hugging-face vs tomoto

**Problem**: three gems all sit in "machine-learning inference," but they trade off latency,
cost, and operational burden differently, and one of them isn't inference at all.

**Rule**: **informers** when the model should run locally via ONNX Runtime with no network call
once downloaded — lower latency, no per-call cost, but the model file and hardware are the
project's problem now. **hugging-face** when a hosted Inference API call is acceptable — no local
model management, but network latency and per-call cost. **tomoto** is a different task entirely
(LDA-style topic modeling, not transformer inference) — reach for it when the goal is clustering
documents by topic, not classifying or embedding them.

### Concurrency model choice: async/falcon vs concurrent-ruby vs parallel

**Problem**: three concurrency primitives are whitelisted and none of them is wrong in the
abstract — the failure mode is picking one that fights the workload's actual shape.

**Rule**: **async** (+ `falcon`, `async-http`, `async-job`, `async-service`, `async-cable`) for
I/O-bound work — many concurrent network calls or connections inside one process, reactor-style.
**concurrent-ruby** for mixed or CPU-light concurrent work using familiar primitives (thread
pools, futures, promises) without adopting the async reactor model wholesale. **parallel** for
CPU-bound work that needs real parallelism across processes — Ruby's GIL makes threads a poor fit
for CPU-bound work, so `parallel` forks instead of threading. Don't run an async reactor and a
thread pool in the same request path without being clear about which one owns the event loop.

No skill currently owns this gemset as a whole (see [Section 3](#section-3-gaps--whitelisted-but-unowned)) — `scaffold`'s convention pass wraps entry points in `Async {}` when it detects
HTTP/network libs, but that's a narrow slice of the decision, not the full picture.

### rubocop vs syntax_tree

**Problem**: both can reformat a Ruby file, and running both as competing auto-formatters on the
same files produces churn — each one "fixing" what the other just wrote.

**Rule**: **rubocop** is the default — style linting with opinionated autocorrect against the
community Ruby Style Guide, plus its cop-package family (`rubocop-md`, `rubocop-rake`,
`rubocop-sequel`) for format- and library-specific rules. **syntax_tree** is an alternative
formatter built on its own parser; it can replace rubocop's *formatting* duties but not its full
lint rule set. Pick one to own formatting; if the other stays in the Gemfile, run it lint-only.

See [refactor/SKILL.md](../../refactor/SKILL.md) and its bundled `rubocop.md` /
`syntax_verification.md`.

### Shelling out safely: terrapin vs childprocess/open4

**Problem**: three gems all run external commands, and the wrong choice for a command line built
from user-supplied or external values is a shell-injection risk, not just a style preference.

**Rule**: **terrapin** whenever any part of the command line is built from a user-supplied or
external value — it exists specifically to escape interpolated arguments safely. **childprocess**
/ **open4** when raw stdin/stdout/stderr handles and finer process lifecycle control are needed
and every argument is a trusted, static value. Default to terrapin; drop to childprocess/open4
only when its interface genuinely can't express what's needed.

### gush vs jongleur

**Problem**: both orchestrate a DAG of tasks as separate processes, but they assume different
stacks underneath.

**Rule**: **gush** when the project already runs Rails + ActiveJob + Redis — it's built directly
on that stack. **jongleur** when there's no Rails/ActiveJob dependency to lean on — it launches
DAG tasks as plain OS processes. Neither replaces the `async_runtime` gemset above; both are
process-orchestration layers sitting above whatever concurrency primitive the individual tasks
use internally.

---

## Section 3: Gaps — Whitelisted but Unowned

These gemsets are vetted (they're in `references/Gemfile` and classified in
`references/Gemfile.json`) but no skill in `skills/` currently carries deep usage guidance,
pitfalls, or a verification checklist for them: `document_intake`, `async_runtime`,
`process_shell_utilities`, `workflow_orchestration`, `media_image_processing`,
`media_subtitle_caption`, `structured_data_encoding`, `algorithms_datastructures`,
`security_crypto_support`, `browser_automation_testing`, `creative_coding_signal`,
`meta_plugin_tooling`.

When a task lands in one of these, treat it like any gem outside a skill's own table: verify the
API inline via Context7/DeepWiki before writing code against it (the plugin's standing mandate),
and don't assume the guidance patterns from an owned gemset (failover tables, common pitfalls)
transfer — they haven't been written for these yet. `document_intake` and `async_runtime` are the
two most likely to earn a dedicated skill first, given how many other owned gemsets touch them
(NLP/RAG pipelines consume document intake; nearly every async-related convention pass step in
`scaffold-patterns.md` touches the async_runtime gemset).

---

**Last updated**: 2026-08-19
**Covers**: 89 gems, 27 gemsets, 9 documented overlaps
**Source**: `references/Gemfile` + `references/Gemfile.json`
