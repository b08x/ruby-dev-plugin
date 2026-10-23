---
name: yardoc
description: "Use when generating, adding, or improving documentation comments for Ruby files, including requests phrased as 'YARD docs'. Writes decode-style tags (@parameter, @returns, @raises, @yields, @option, @attribute, @example), converts existing YARD tags to decode tags, and measures documentation coverage with bake decode:index:coverage."
---

# RubyDev Yardoc — decode Documentation Generator

## Overview

This skill writes Ruby documentation comments in the tag format parsed by the [decode](https://github.com/socketry/decode) gem. decode reads the comments into structured nodes (`Decode::Comment::Parameter`, `Returns`, `Attribute`, ...), measures documentation coverage, and generates RBS signatures from them. The skill name stays `yardoc` for routing compatibility; the output is decode syntax, not YARD syntax.

**Core Mandate**: Every public definition in `PATHS` gets a full-sentence description and the tags its signature requires, and `bake decode:index:coverage` reports the before and after counts.

**Format rule**: decode does not parse YARD tags. A `@param` or `@return` line is read as plain text and produces no structured data. Never write YARD tags. Convert YARD tags on every definition the task touches, using the conversion table in [references/decode-tags.md](references/decode-tags.md).

**References**:
- decode tag reference, type notation, YARD-to-decode conversion table, writing rules: [references/decode-tags.md](references/decode-tags.md)
- Dry-struct type definitions for documentation results: [references/type-structures.md](references/type-structures.md)
- Context7 verification workflow for decode syntax and gem APIs: [references/context7-integration.md](references/context7-integration.md)
- Structured logging setup and example log calls: [references/logging.md](references/logging.md)
- Result monad error-handling patterns: [references/error-handling.md](references/error-handling.md)
- Full worked example (dry-struct class, generated `@attribute` comments, decode round-trip check): [references/dry-struct-example.md](references/dry-struct-example.md)

## When to Use

- **Generate documentation comments** for Ruby files or methods
- **Convert YARD comments** to decode tags
- **Improve documentation** quality and completeness
- **Document methods** with precise type annotations
- **Raise documentation coverage** reported by `bake decode:index:coverage`

**Don't use for:**
- README generation or project overview docs (use general writing skills)
- Non-Ruby files
- Code review or quality assessment (use [sift/SKILL.md](../sift/SKILL.md) instead)
- Debugging or root cause analysis (use [analyse/SKILL.md](../analyse/SKILL.md))

## Execution Layers

### Layer 1: Gem Context Check (Prerequisite)

Before writing type annotations, verify gem context:

1. **Check for non-stdlib gems** in the target file
2. **If gem-specific types are detected** (e.g., `RubyLLM::Chat`, `Sequel::Dataset`, `Async::Task`, `Dry::Schema::Result`):
   - Query Context7 MCP (or DeepWiki for the gem's GitHub repo) for each gem involved, inline
   - Use the verified class names and return types verbatim in `@parameter`, `@returns`, and `@attribute` tags
   - If Context7 is unavailable, apply the fallback below and add `# type annotation based on stale cache — verify before publishing`
3. **Skip for**: stdlib-only files, Lite Mode tasks, gems already resolved this session

For tag syntax not covered by [references/decode-tags.md](references/decode-tags.md), query Context7 library `/socketry/decode`. See [references/context7-integration.md](references/context7-integration.md).

### Layer 2: Target and Baseline

#### Target File Validation
- Verify each target file exists and is readable
- Run `ruby -c` on each target file before editing

#### Baseline Measurement
- Run `bundle exec bake decode:index:coverage <dir>` on the directory that holds the targets (usually `lib`). Record the line "N definitions have documentation, out of M public definitions."
- The command exits non-zero while any public definition is undocumented. That exit status is the measurement, not a failure of this skill.
- If `decode` or `bake` is missing from the bundle, the orchestrator did not run its Gemfile step. Report `not run: decode unavailable` and continue without the measurement.

#### Existing Style Assessment
- Count YARD tags (`@param`, `@return`, `@raise`, `@yieldparam`, `@!attribute`) in the target files. Each one on a touched definition is converted.
- Note the file's comment indentation (two spaces or tab) and match it for nested tags and example code.

### Layer 3: Semantic Code Analysis

#### Structure
Extract with Prism, or with the rubydex MCP tools (`get_file_declarations`, `get_declaration`) when the plugin's rubydex server is connected:
- Class and module hierarchies with ancestors
- Method signatures: positional, optional, keyword, splat, and block parameters
- Instance vs singleton method
- Ruby visibility (public, protected, private)
- `yield` and `block.call` sites

#### Type Inference
Infer from the implementation:
- Parameter types from the methods called on each parameter
- Return types from every return path, including early returns
- `| Nil` from paths that return `nil`
- `Interface(:method)` for parameters used only through one or two methods
- `@raises` entries from explicit `raise` statements, not from exceptions that propagate from callees

#### Behavior
Derive the description from control flow, side effects, state mutations, and calls to external dependencies.

### Layer 4: Comment Generation

#### Method Comment Template

```ruby
# [What the method does, as a full sentence in active voice.]
#
# [Optional second paragraph: constraints, side effects, related methods as {links}.]
#
# @parameter name [PreciseType] What the argument is and any constraint on it.
# @parameter optional_arg [Type | Nil] What it is. Defaults to `nil`, which means ...
# @option :key [Type] What the option controls. Defaults to ...
# @yields {|item| ...} When and how often the block is called.
#   @parameter item [Type] What the block receives.
# @returns [SpecificType] What the return value contains.
# @raises [ExceptionClass] The condition that raises it.
#
# @example Typical call
#   result = realistic_call(actual_value)
#   result.size # => 3
```

Omit tags that do not apply. A method with no parameters has no `@parameter` lines. A method whose return value callers do not use gets `@returns [void]`.

#### Class, Module, and Attribute Comments
- Class: one sentence stating what the class is or does.
- Namespace-only module: `# @namespace`.
- `attr_*` and dry-struct `attribute` calls: one `# @attribute [Type] Description.` directly above each call.

#### Type Precision
Use decode notation: `Array(String)`, `Hash(Symbol, Integer)`, `String | Nil`, `Interface(:each)`, `bool`. The full table is in [references/decode-tags.md](references/decode-tags.md).

#### Examples
- Use realistic argument values and show the return shape with `# =>`
- Show the block form for methods that yield
- Skip examples for trivial accessors

### Layer 5: Verification

1. **Syntax**: `ruby -c` on every edited file.
2. **Parse check**: index each edited file with `Decode::Index` and confirm every definition with `@` lines in its comment has structured nodes, not only `Text`. Code: the "Tooling Commands" section of [references/decode-tags.md](references/decode-tags.md).
3. **Name match**: every `@parameter` name matches a parameter in the method signature, and every signature parameter except `&block` has a `@parameter` line.
4. **No YARD tags remain** on touched definitions: `grep -nE '@(param|return|raise|yieldparam|yieldreturn)\b|@!attribute' <files>` returns nothing for those lines.
5. **Coverage**: re-run `bundle exec bake decode:index:coverage <dir>` and record the after count.
6. **RBS (optional, when the project has `sig/`)**: `bundle exec bake decode:rbs:generate <dir>` succeeds.

### Layer 6: Output

#### Comment Insertion
- Insert comments directly above the definition, with no blank line between comment and definition
- Preserve code structure and indentation
- Handle nested classes and metaprogrammed definitions; use `@name` and `@scope` only when decode cannot see the definition

#### Report
- Coverage before and after: "N of M public definitions documented"
- Number of definitions documented and number of YARD tags converted
- Definitions left undocumented, with the reason
- Types marked unverified

## Advanced Features

### Error Handling

Documentation generation uses dry-monads Result types for explicit success/failure propagation, with rescue patterns for partial documentation when type inference fails. See [references/error-handling.md](references/error-handling.md).

### Type-Safe Data Structures

Documentation results are dry-struct types (`MethodDocumentation`, `GenerationResult`, `ParseResult`, etc.) rather than raw hashes. See [references/type-structures.md](references/type-structures.md).

### Logging

Parsing, analysis, generation, and validation emit structured logs via `journald-logger` with correlation IDs. See [references/logging.md](references/logging.md).

## Operational Protocol

### Decision Statement

At the start of every yardoc operation, state:

```
[YARDOC DECISION]
Target: <file_path>
Mode: <standard|lite>
Gems to Verify: <list or none>
Definitions to Document: <count>
YARD Tags to Convert: <count>
Coverage Baseline: <N of M | not run: reason>
[/YARDOC DECISION]
```

### Quality Gates

1. **Syntax Validation**: `ruby -c` passes on every edited file
2. **Type Verification**: every non-stdlib gem type is verified via Context7/DeepWiki or marked unverified
3. **Parse Check**: decode parses every tag on touched definitions into structured nodes
4. **Coverage**: the documented count after the edit is greater than or equal to the count before it

## Failover

| Dependency | If Unavailable | Fallback |
|------------|---------------|----------|
| Context7 / DeepWiki | Both unreachable | Use conservative types (`String`, `Object`) and add `# type annotation based on unverified API — verify before publishing`. |
| `decode` / `bake` in the bundle | Not installed | Skip the coverage and parse checks, record `not run: decode unavailable`, and check tag syntax by hand against [references/decode-tags.md](references/decode-tags.md). |
| rubydex MCP | Server not connected | Extract structure with Prism. |
| [sift/SKILL.md](../sift/SKILL.md) | Quality assessment unavailable | Check each tag against the decode tag table, confirm `@parameter` names match the signature, confirm the `@returns` type is plausible. |
| [analyse/SKILL.md](../analyse/SKILL.md) | Diagnostic unavailable | Mark uncertain types with `# TODO: verify this type`. |

## Common Pitfalls

1. **Writing YARD tags**: `@param`/`@return` parse as plain text in decode
2. **Type before name**: `@parameter name [Type]`, not `@parameter [Type] name`
3. **YARD type notation**: `Array(String)`, not `Array<String>`; `String | Nil`, not `String, nil`
4. **Documenting without gem context**: check non-stdlib gems first
5. **Over-documenting trivial methods**: one-line accessors need an `@attribute` line, not prose
6. **Hallucinating types**: never invent types for unverified gem APIs
7. **Inline comments without a trailing colon**: comments inside method bodies end with `:`
8. **Skipping the coverage measurement**: the report states before and after counts, or `not run` with the reason
